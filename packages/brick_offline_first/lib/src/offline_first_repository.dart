import 'dart:async';
import 'dart:io';

import 'package:brick_core/core.dart' show Query, ModelRepository, QueryAction, Provider;
import 'package:brick_offline_first/src/models/offline_first_model.dart';
import 'package:brick_offline_first/src/offline_first_policy.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
// ignore: implementation_imports
import 'package:http/src/exception.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// A [ModelRepository] that interacts with a [SqliteProvider] first before using a [Provider] from a remote source.
///
/// The `OfflineFirstRepository` should be extended by an implementation in the end class.
/// The implementation can then be accessed via singleton or [InheritedWidget].
/// For example:
/// ```dart
/// class MyRepository extends OfflineFirstRepository {
///   const MyRepository._(
///     RestProvider _restProvider,
///     SqliteProvider _sqliteProvider,
///   ) : super(
///         remoteProvider: _restProvider,
///         sqliteProvider: _sqliteProvider,
///       );
///   factory MyRepository() => _singleton!;
///
///   /// The singleton could be configured on the first call of `MyRepository()` or it can
///   /// be set by calling `configure` during app initialization.
///   static void configure({
///     required RestProvider restProvider,
///     required SqliteProvider sqliteProvider,
///   }) {
///     _singleton = MyRepository._(
///       restProvider,
///       sqliteProvider,
///     );
///   }
/// }
/// ```
abstract class OfflineFirstRepository<RepositoryModel extends OfflineFirstModel>
    implements ModelRepository<RepositoryModel> {
  /// Refetch results in the background from remote source when any request is made.
  /// Defaults to [false].
  final bool autoHydrate;

  /// Required to maintain the same policy for [getAssociation] requests.
  /// This is a stateful variable that should be cleared immediately after
  /// it is no longer necessary.
  ///
  /// See discussion: https://github.com/GetDutchie/brick/issues/371
  OfflineFirstGetPolicy? _latestGetPolicy;

  /// The first data source to speed up otherwise taxing queries. Only caches specified models.
  final MemoryCacheProvider memoryCacheProvider;

  final MigrationManager migrationManager;

  /// The data source that data is pushed to and from.
  final Provider remoteProvider;

  /// The local data source utilized before every operation.
  final SqliteProvider sqliteProvider;

  @protected
  @visibleForTesting
  final Map<Type, Map<Query?, StreamController<List<RepositoryModel>>>> subscriptions = {};

  /// User for low-level debugging. The logger name can be defined in the default constructor;
  /// it defaults to `OfflineFirstRepository`.
  @protected
  final Logger logger;

  OfflineFirstRepository({
    required this.remoteProvider,
    required this.sqliteProvider,
    bool? autoHydrate,
    MemoryCacheProvider? memoryCacheProvider,
    required Set<Migration> migrations,
    String? loggerName,
  })  : autoHydrate = autoHydrate ?? false,
        logger = Logger(loggerName ?? 'OfflineFirstRepository'),
        migrationManager = MigrationManager(migrations),
        memoryCacheProvider = memoryCacheProvider ?? MemoryCacheProvider();

  /// As some remote provider's may utilize an `OfflineFirstPolicy` from the request,
  /// this composes the policy to the query (such as in the `providerArgs`).
  @protected
  @visibleForOverriding
  @visibleForTesting
  Query? applyPolicyToQuery(
    Query? query, {
    OfflineFirstDeletePolicy? delete,
    OfflineFirstGetPolicy? get,
    OfflineFirstUpsertPolicy? upsert,
  }) =>
      query;

  /// Remove a model from SQLite and the [remoteProvider]
  @override
  Future<bool> delete<TModel extends RepositoryModel>(
    TModel instance, {
    OfflineFirstDeletePolicy policy = OfflineFirstDeletePolicy.optimisticLocal,
    Query? query,
  }) async {
    final withPolicy = applyPolicyToQuery(query, delete: policy);
    query = (withPolicy ?? Query()).copyWith(action: QueryAction.delete);
    logger.finest('#delete: $query');

    final optimisticLocal = policy == OfflineFirstDeletePolicy.optimisticLocal;
    final requireRemote = policy == OfflineFirstDeletePolicy.requireRemote;

    var rowsDeleted = 0;

    if (optimisticLocal) {
      rowsDeleted = await _deleteLocal<TModel>(instance, query: query);
      await notifySubscriptionsWithLocalData<TModel>(notifyWhenEmpty: true);
    }

    try {
      await remoteProvider.delete<TModel>(instance, query: query, repository: this);
      if (requireRemote) {
        rowsDeleted = await _deleteLocal<TModel>(instance, query: query);
        await notifySubscriptionsWithLocalData<TModel>(notifyWhenEmpty: true);
      }
    } on ClientException catch (e) {
      logger.warning('#delete client failure: $e');
      if (requireRemote) rethrow;
    } on SocketException catch (e) {
      logger.warning('#delete socket failure: $e');
      if (requireRemote) rethrow;
    }

    // ignore: unawaited_futures
    if (autoHydrate) hydrate<TModel>(query: query);

    return rowsDeleted > 0;
  }

  Future<int> _deleteLocal<TModel extends RepositoryModel>(TModel instance, {Query? query}) async {
    final rowsDeleted = await sqliteProvider.delete<TModel>(
      instance,
      query: query,
      repository: this,
    );
    memoryCacheProvider.delete<TModel>(instance, query: query);
    return rowsDeleted;
  }

  /// Check if a [TModel] is accessible locally.
  /// First checks if there's a matching query in [memoryCacheProvider] and then check [sqliteProvider].
  /// Does **not** query [remoteProvider].
  Future<bool> exists<TModel extends RepositoryModel>({
    Query? query,
  }) async {
    if (memoryCacheProvider.canFind<TModel>(query)) {
      final results = memoryCacheProvider.get<TModel>(query: query, repository: this);

      return results?.isNotEmpty ?? false;
    }

    return await sqliteProvider.exists<TModel>(query: query, repository: this);
  }

  /// Load association from SQLite first; if the [TModel] hasn't been loaded previously,
  /// fetch it from [remoteProvider] and hydrate SQLite.
  /// For available query providerArgs see [remoteProvider#get] [SqliteProvider.get].
  ///
  /// [seedOnly] does not load data from SQLite after inserting records. Association queries
  /// can be expensive for large datasets, making deserialization a significant hit when the result
  /// is ignorable (e.g. eager loading). Defaults to `false`.
  @override
  Future<List<TModel>> get<TModel extends RepositoryModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
    bool seedOnly = false,
  }) async {
    final withPolicy = applyPolicyToQuery(query, get: policy);
    query = (withPolicy ?? Query()).copyWith(action: QueryAction.get);
    logger.finest('#get: $TModel $query');

    final requireRemote = policy == OfflineFirstGetPolicy.awaitRemote;
    final hydrateUnexisting = policy == OfflineFirstGetPolicy.awaitRemoteWhenNoneExist;
    final alwaysHydrate = policy == OfflineFirstGetPolicy.alwaysHydrate;

    try {
      _latestGetPolicy = policy;

      if (memoryCacheProvider.canFind<TModel>(query) && !requireRemote) {
        final memoryCacheResults = memoryCacheProvider.get<TModel>(query: query, repository: this);

        if (alwaysHydrate) {
          // start round trip for fresh data
          // ignore: unawaited_futures
          hydrate<TModel>(query: query, deserializeSqlite: !seedOnly);
        }

        if (memoryCacheResults?.isNotEmpty ?? false) return memoryCacheResults!;
      }

      final modelExists = await exists<TModel>(query: query);

      if (requireRemote || (hydrateUnexisting && !modelExists)) {
        return await hydrate<TModel>(query: query, deserializeSqlite: !seedOnly);
      } else if (alwaysHydrate) {
        // start round trip for fresh data
        // ignore: unawaited_futures
        hydrate<TModel>(query: query, deserializeSqlite: !seedOnly);
      }

      return await sqliteProvider
          .get<TModel>(query: query, repository: this)
          // cache this query
          .then((m) => memoryCacheProvider.hydrate<TModel>(m));
    } finally {
      _latestGetPolicy = null;
    }
  }

  /// Used exclusively by the [OfflineFirstAdapter]. If there are no results, returns `null`.
  Future<List<TModel>?> getAssociation<TModel extends RepositoryModel>(Query query) async {
    logger.finest('#getAssociation: $TModel $query');
    final results = await get<TModel>(
      query: query,
      policy: _latestGetPolicy ?? OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    );
    if (results.isEmpty) return null;
    return results;
  }

  /// Get all results in series of [batchSize]s (defaults to `50`).
  /// Useful for large queries or remote results.
  ///
  /// [batchSize] will map to the [query]'s `limit`, and the [query]'s pagination number will be
  /// incremented in `query.providerArgs['offset']`. The endpoint for [TModel] should expect these
  /// arguments. The stream will recurse until the return size does not equal [batchSize].
  ///
  /// [seedOnly] does not load data from SQLite after inserting records. Association queries
  /// can be expensive for large datasets, making deserialization a significant hit when the result
  /// is ignorable (e.g. eager loading). Defaults to `false`.
  Future<List<TModel>> getBatched<TModel extends RepositoryModel>({
    int batchSize = 50,
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
    bool seedOnly = false,
  }) async {
    final withPolicy = applyPolicyToQuery(query, get: policy);
    query = withPolicy ?? Query();
    final queryWithLimit = query.copyWith(
      providerArgs: {...query.providerArgs, 'limit': batchSize},
    );
    final total = <TModel>[];

    /// Retrieve up to [batchSize] starting at [offset]. Recursively retrieves the next
    /// [batchSize] until no more results are retrieved.
    Future<List<TModel>> getFrom(int offset) async {
      // add offset to the existing query
      final recursiveQuery = queryWithLimit.copyWith(
        providerArgs: {...queryWithLimit.providerArgs, 'offset': offset},
      );

      final results = await get<TModel>(
        query: recursiveQuery,
        policy: policy,
        seedOnly: seedOnly,
      );
      total.addAll(results);

      // if results match the batchSize, increase offset and get again
      if (results.length == batchSize) {
        return await getFrom(offset + batchSize);
      }

      return total;
    }

    return await getFrom(0);
  }

  /// Prepare the environment for future repository functions. It is recommended to call this
  /// method within a `StatefulWidget`'s `initState` to ensure it is only invoked once. It is
  /// **not** automatically invoked.
  ///
  /// If this method is overriden in the sub class, [migrate] must be called before using
  /// SQLite features.
  @override
  Future<void> initialize() async {
    await migrate();
  }

  /// Update SQLite structure with only new migrations.
  Future<void> migrate() async {
    final lastVersion = await sqliteProvider.lastMigrationVersion();
    final migrations = migrationManager.migrationsSince(lastVersion);

    return await sqliteProvider.migrate(migrations);
  }

  /// Iterate through subscriptions after an upsert and notify any [subscribe] listeners.
  @protected
  @visibleForTesting
  Future<void> notifySubscriptionsWithLocalData<TModel extends RepositoryModel>({
    bool notifyWhenEmpty = true,
  }) async {
    final queriesControllers = subscriptions[TModel]?.entries;
    if (queriesControllers?.isEmpty ?? true) return;

    // create a copy of the controllers to avoid concurrent modification while looping
    final cachedControllers =
        List<MapEntry<Query?, StreamController<List<RepositoryModel>>>>.from(queriesControllers!);
    for (final queryController in cachedControllers) {
      final query = queryController.key;
      final controller = queryController.value;
      if (controller.isClosed || controller.isPaused) continue;

      if (query == null || memoryCacheProvider.canFind<TModel>(query)) {
        final results = memoryCacheProvider.get<TModel>(query: query);
        if (!controller.isClosed && (results?.isNotEmpty ?? false)) controller.add(results!);
      }

      final existsInSqlite = await sqliteProvider.exists<TModel>(query: query, repository: this);
      if (existsInSqlite) {
        final results = await sqliteProvider.get<TModel>(query: query, repository: this);
        if (!controller.isClosed) controller.add(results);
      } else if (notifyWhenEmpty) {
        if (!controller.isClosed) controller.add(<TModel>[]);
      }
    }
  }

  /// Destroys all local records - specifically, memoryCache and sqliteProvider's
  /// data sources.
  Future<void> reset() async {
    await sqliteProvider.resetDb();
    memoryCacheProvider.reset();
  }

  /// Listen for streaming changes when the [sqliteProvider] is `upsert`ed. This method utilizes [remoteProvider]'s [get].
  ///
  /// [get] is invoked on the [memoryCacheProvider] and [sqliteProvider] following an [upsert]
  /// invocation. For more, see [notifySubscriptionsWithLocalData].
  ///
  /// [policy] is only applied to the initial population of the stream. Only local data is supplied
  /// on subsequent events to [notifySubscriptionsWithLocalData].
  ///
  /// It is **strongly recommended** that this invocation be immediately `.listen`ed assigned
  /// with the assignment/subscription `.cancel()`'d as soon as the data is no longer needed.
  /// The stream will not close naturally.
  Stream<List<TModel>> subscribe<TModel extends RepositoryModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.localOnly,
    Query? query,
  }) {
    query ??= Query();
    if (subscriptions[TModel]?[query] != null) {
      return subscriptions[TModel]![query]!.stream as Stream<List<TModel>>;
    }

    final controller = StreamController<List<TModel>>(
      onCancel: () async {
        await subscriptions[TModel]?[query]?.close();
        subscriptions[TModel]?.remove(query);
        if (subscriptions[TModel]?.isEmpty ?? false) {
          subscriptions.remove(TModel);
        }
      },
    );

    subscriptions[TModel] ??= {};
    subscriptions[TModel]?[query] = controller;

    // ignore: discarded_futures
    get<TModel>(query: query, policy: policy).then((results) {
      if (!controller.isClosed) controller.add(results);
    });

    return controller.stream;
  }

  /// Send a model to [remoteProvider] and [hydrate].
  @override
  Future<TModel> upsert<TModel extends RepositoryModel>(
    TModel instance, {
    Query? query,
    OfflineFirstUpsertPolicy policy = OfflineFirstUpsertPolicy.optimisticLocal,
  }) async {
    final withPolicy = applyPolicyToQuery(query, upsert: policy);
    if (query?.action == null) {
      query = (withPolicy ?? Query()).copyWith(action: QueryAction.upsert);
    }
    logger.finest('#upsert: $query $instance');

    final optimisticLocal = policy == OfflineFirstUpsertPolicy.optimisticLocal;
    final requireRemote = policy == OfflineFirstUpsertPolicy.requireRemote;

    if (optimisticLocal) {
      instance.primaryKey = await _upsertLocal<TModel>(instance, query: query);
      await notifySubscriptionsWithLocalData<TModel>();
    }

    try {
      await remoteProvider.upsert<TModel>(instance, query: query, repository: this);

      if (requireRemote) {
        instance.primaryKey = await _upsertLocal<TModel>(instance, query: query);
        await notifySubscriptionsWithLocalData<TModel>();
      }
    } on ClientException catch (e) {
      logger.warning('#upsert client failure: $e');
      if (requireRemote) rethrow;
    } on SocketException catch (e) {
      logger.warning('#upsert socket failure: $e');
      if (requireRemote) rethrow;
    }

    // ignore: unawaited_futures
    if (autoHydrate) hydrate<TModel>(query: query);

    return instance;
  }

  Future<int?> _upsertLocal<TModel extends RepositoryModel>(TModel instance, {Query? query}) async {
    final modelId = await sqliteProvider.upsert<TModel>(
      instance,
      query: query,
      repository: this,
    );
    instance.primaryKey = modelId;
    memoryCacheProvider.upsert<TModel>(instance, query: query);
    return modelId;
  }

  /// Fetch and store results from [remoteProvider] into SQLite and the memory cache.
  ///
  /// [deserializeSqlite] loads data from SQLite after they've been inserted. Association queries
  /// can be expensive for large datasets, making deserialization a significant hit when the result
  /// is ignorable. Defaults to `true`.
  @protected
  Future<List<TModel>> hydrate<TModel extends RepositoryModel>({
    bool deserializeSqlite = true,
    Query? query,
  }) async {
    try {
      logger.finest('#hydrate: $TModel $query');
      final modelsFromRemote = await remoteProvider.get<TModel>(query: query, repository: this);

      if (modelsFromRemote != null) {
        final modelsIntoSqlite = await storeRemoteResults<TModel>(modelsFromRemote);
        final modelsIntoMemory = memoryCacheProvider.hydrate<TModel>(modelsIntoSqlite);

        if (!deserializeSqlite) return modelsIntoMemory;
      }

      return await sqliteProvider
          .get<TModel>(query: query, repository: this)
          .then((d) => memoryCacheProvider.hydrate<TModel>(d));
    } on ClientException catch (e) {
      logger.warning('#hydrate client failure: $e');
    } on SocketException catch (e) {
      logger.warning('#hydrate socket failure: $e');
    }

    return <TModel>[];
  }

  /// Save response results to SQLite.
  ///
  /// When `true`, [shouldNotify] will check if any subscribers of [TModel] are affected by
  /// the new [models]. See [notifySubscriptionsWithLocalData].
  @protected
  @visibleForTesting
  Future<List<TModel>> storeRemoteResults<TModel extends RepositoryModel>(
    List<TModel> models, {
    bool shouldNotify = true,
  }) async {
    final modelIds = models.map((m) => sqliteProvider.upsert<TModel>(m, repository: this));
    final results = await Future.wait<int?>(modelIds, eagerError: true);

    MapEntry modelWithPrimaryKey(index, id) {
      final model = models[index];
      model.primaryKey = id;
      return MapEntry(index, model);
    }

    final savedResults = results.asMap().map(modelWithPrimaryKey).values.toList().cast<TModel>();
    if (shouldNotify) await notifySubscriptionsWithLocalData<TModel>();
    return savedResults;
  }
}
