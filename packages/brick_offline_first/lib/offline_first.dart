import 'dart:async';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:meta/meta.dart';
import 'package:logging/logging.dart';

import 'package:brick_core/core.dart' show Query, ModelRepository, QueryAction, Provider;
import 'package:brick_sqlite_abstract/db.dart' show MigrationManager, Migration;
import 'package:brick_offline_first_abstract/abstract.dart';

import 'package:brick_sqlite/sqlite.dart';
import 'package:http/src/exception.dart'; // ignore: implementation_imports

export 'package:brick_core/query.dart';
export 'package:brick_offline_first_abstract/abstract.dart' hide OfflineFirstWithRestModel;
export 'package:brick_offline_first_abstract/annotations.dart';
export 'package:brick_sqlite/sqlite.dart' show SqliteProvider;
export 'package:brick_offline_first/src/offline_first_exception.dart';

/// This adapter fetches first from [SqliteProvider] then hydrates with from a remote provider..
abstract class OfflineFirstAdapter<_Model extends OfflineFirstModel> extends SqliteAdapter<_Model> {
  OfflineFirstAdapter();
}

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
///   factory MyRepository() => _singleton;
///
///   /// The singleton could be configured on the first call of `MyRepository()` or it can
///   /// be set by calling `configure` during app initialization.
///   static void configure({
///     RestProvider restProvider,
///     SqliteProvider sqliteProvider,
///   }) {
///     _singleton = MyRepository._(
///       restProvider,
///       sqliteProvider,
///     );
///   }
/// }
/// ```
abstract class OfflineFirstRepository<_RepositoryModel extends OfflineFirstModel>
    implements ModelRepository<_RepositoryModel> {
  /// Refetch results in the background from remote source when any request is made.
  /// Defaults to [false].
  final bool autoHydrate;

  /// The first data source to speed up otherwise taxing queries. Only caches specified models.
  final MemoryCacheProvider memoryCacheProvider;

  final MigrationManager migrationManager;

  /// The data source that data is pushed to and from.
  final Provider remoteProvider;

  /// The local data source utilized before every operation.
  final SqliteProvider sqliteProvider;

  /// User for low-level debugging. The logger name can be defined in the default constructor;
  /// it defaults to `OfflineFirstRepository`.
  @protected
  final Logger logger;

  OfflineFirstRepository({
    this.remoteProvider,
    @required this.sqliteProvider,
    bool autoHydrate,
    MemoryCacheProvider memoryCacheProvider,
    Set<Migration> migrations,
    String loggerName,
  })  : autoHydrate = autoHydrate ?? false,
        logger = Logger(loggerName ?? 'OfflineFirstRepository'),
        migrationManager = MigrationManager(migrations),
        memoryCacheProvider = memoryCacheProvider ?? MemoryCacheProvider(),
        assert(sqliteProvider != null) {
    // assert after as remoteProvider may
    // not come as an argument (i.e. defined final or assigned in the child class)
    assert(remoteProvider != null);
  }

  /// Remove a model from SQLite and the [remoteProvider]
  @override
  Future<bool> delete<_Model extends _RepositoryModel>(
    _Model instance, {
    Query query,
  }) async {
    query = (query ?? Query()).copyWith(action: QueryAction.delete);
    logger.finest('#delete: $query');

    final rowsDeleted = await sqliteProvider.delete<_Model>(
      instance,
      query: query,
      repository: this,
    );
    memoryCacheProvider.delete<_Model>(instance, query: query);

    try {
      await remoteProvider.delete<_Model>(instance, query: query, repository: this);
    } on ClientException catch (e) {
      logger.warning('#delete client failure: $e');
    }

    if (autoHydrate) hydrate<_Model>(query: query);

    return rowsDeleted > 0;
  }

  /// Check if a [_Model] is accessible locally.
  /// First checks if there's a matching query in [memoryCacheProvider] and then check [sqliteProvider].
  /// Does **not** query [remoteProvider].
  Future<bool> exists<_Model extends _RepositoryModel>({
    Query query,
  }) async {
    if (memoryCacheProvider.canFind<_Model>(query)) {
      final results = memoryCacheProvider.get<_Model>(query: query, repository: this);

      return results?.isNotEmpty ?? false;
    }

    return await sqliteProvider.exists<_Model>(query: query, repository: this);
  }

  /// Load association from SQLite first; if the [_Model] hasn't been loaded previously,
  /// fetch it from [remoteProvider] and hydrate SQLite.
  /// For available query providerArgs see [remoteProvider#get] [SqliteProvider.get].
  ///
  /// [alwaysHydrate] ensures data is fetched from the [remoteProvider] for each invocation.
  /// This often **negatively affects performance** when enabled. Defaults to `false`.
  ///
  /// [hydrateUnexisting] retrieves from the [remoteProvider] if the query returns no results from SQLite.
  /// If an empty response can be expected (such as a search page), set to `false`. Defaults to `true`.
  ///
  /// [requireRemote] ensures data must be updated from the [remoteProvider] before returning if the app is online.
  /// Cached SQLite data will be returned if the app is offline. Defaults to `false`.
  ///
  /// [seedOnly] does not load data from SQLite after inserting records. Association queries
  /// can be expensive for large datasets, making deserialization a significant hit when the result
  /// is ignorable (e.g. eager loading). Defaults to `false`.
  @override
  Future<List<_Model>> get<_Model extends _RepositoryModel>({
    Query query,
    bool alwaysHydrate = false,
    bool hydrateUnexisting = true,
    bool requireRemote = false,
    bool seedOnly = false,
  }) async {
    query = (query ?? Query()).copyWith(action: QueryAction.get);
    logger.finest('#get: $_Model $query');

    final modelExists = await exists<_Model>(query: query);
    if (memoryCacheProvider.canFind<_Model>(query)) {
      final memoryCacheResults = memoryCacheProvider.get<_Model>(query: query, repository: this);

      if (memoryCacheResults?.isNotEmpty ?? false) return memoryCacheResults;
    }

    if (requireRemote || (hydrateUnexisting && !modelExists)) {
      return await hydrate<_Model>(query: query, deserializeSqlite: !seedOnly);
    } else if (alwaysHydrate) {
      // start round trip for fresh data
      hydrate<_Model>(query: query, deserializeSqlite: !seedOnly);
    }

    return await sqliteProvider
        .get<_Model>(query: query, repository: this)
        // cache this query
        .then((m) => memoryCacheProvider.hydrate<_Model>(m));
  }

  /// Used exclusively by the [OfflineFirstAdapter]. If there are no results, returns `null`.
  Future<List<_Model>> getAssociation<_Model extends _RepositoryModel>(Query query) async {
    logger.finest('#getAssociation: $_Model $query');
    final results = await get<_Model>(query: query, alwaysHydrate: false);
    if (results?.isEmpty ?? true) return null;
    return results;
  }

  /// Get all results in series of [batchSize]s (defaults to `50`).
  /// Useful for large queries or remote results.
  ///
  /// [batchSize] will map to the [query]'s `limit`, and the [query]'s pagination number will be
  /// incremented in `query.providerArgs['offset']`. The endpoint for [_Model] should expect these
  /// arguments. The stream will recurse until the return size does not equal [batchSize].
  ///
  /// [requireRemote] ensures the data is fresh at the expense of increased execution time.
  /// Defaults to `false`.
  ///
  /// [seedOnly] does not load data from SQLite after inserting records. Association queries
  /// can be expensive for large datasets, making deserialization a significant hit when the result
  /// is ignorable (e.g. eager loading). Defaults to `false`.
  Future<List<_Model>> getBatched<_Model extends _RepositoryModel>({
    Query query,
    int batchSize = 50,
    bool requireRemote = false,
    bool seedOnly = false,
  }) async {
    query = (query ?? Query()).copyWith(providerArgs: {'limit': batchSize});
    final total = <_Model>[];

    /// Retrieve up to [batchSize] starting at [offset]. Recursively retrieves the next
    /// [batchSize] until no more results are retrieved.
    Future<List<_Model>> getFrom(int offset) async {
      // add offset to the existing query
      final recursiveQuery = query.copyWith(
        providerArgs: (query.providerArgs ?? {})..addAll({'offset': offset}),
      );

      final results = await get<_Model>(
        query: recursiveQuery,
        requireRemote: requireRemote,
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
  Future<void> initialize() async {
    await migrate();
  }

  /// Update SQLite structure with only new migrations.
  Future<void> migrate() async {
    final lastVersion = await sqliteProvider.lastMigrationVersion();
    final migrations = migrationManager.migrationsSince(lastVersion);

    return await sqliteProvider.migrate(migrations);
  }

  /// Destroys all local records - specifically, memoryCache and sqliteProvider's
  /// data sources.
  Future<void> reset() async {
    await sqliteProvider.resetDb();
    memoryCacheProvider.reset();
  }

  /// Send a model to [remoteProvider] and [hydrate].
  @override
  Future<_Model> upsert<_Model extends _RepositoryModel>(
    _Model instance, {
    Query query,
  }) async {
    if (query?.action == null) {
      query = (query ?? Query()).copyWith(action: QueryAction.upsert);
    }
    logger.finest('#upsert: $query $instance');

    final modelId = await sqliteProvider.upsert<_Model>(
      instance,
      query: query,
      repository: this,
    );
    instance.primaryKey = modelId;
    memoryCacheProvider.upsert<_Model>(instance, query: query);

    try {
      await remoteProvider.upsert<_Model>(instance, query: query, repository: this);
    } on ClientException catch (e) {
      logger.warning('#upsert client failure: $e');
    }

    if (autoHydrate) hydrate<_Model>(query: query);

    return instance;
  }

  /// Fetch and store results from [remoteProvider] into SQLite and the memory cache.
  ///
  /// [deserializeSqlite] loads data from SQLite after they've been inserted. Association queries
  /// can be expensive for large datasets, making deserialization a significant hit when the result
  /// is ignorable. Defaults to `true`.
  @protected
  Future<List<_Model>> hydrate<_Model extends _RepositoryModel>({
    bool deserializeSqlite = true,
    Query query,
  }) async {
    try {
      logger.finest('#hydrate: $_Model $query');
      final modelsFromRemote = await remoteProvider.get<_Model>(query: query, repository: this);

      if (modelsFromRemote != null) {
        final modelsIntoSqlite = await storeRemoteResults<_Model>(modelsFromRemote);
        final modelsIntoMemory = memoryCacheProvider.hydrate<_Model>(modelsIntoSqlite);

        if (!deserializeSqlite) return modelsIntoMemory;
      }

      return await sqliteProvider
          .get<_Model>(query: query, repository: this)
          .then((d) => memoryCacheProvider.hydrate<_Model>(d));
    } on ClientException catch (e) {
      logger.warning('#hydrate client failure: $e');
    }

    return <_Model>[];
  }

  /// Save response results to SQLite.
  @protected
  @visibleForTesting
  Future<List<_Model>> storeRemoteResults<_Model extends _RepositoryModel>(
      List<_Model> models) async {
    final modelIds = models
        .where((m) => m != null)
        .map((m) => sqliteProvider.upsert<_Model>(m, repository: this));
    final results = await Future.wait<int>(modelIds, eagerError: true);

    MapEntry modelWithPrimaryKey(index, id) {
      final model = models[index];
      model.primaryKey = id;
      return MapEntry(index, model);
    }

    return results.asMap().map(modelWithPrimaryKey).values.toList().cast<_Model>();
  }
}
