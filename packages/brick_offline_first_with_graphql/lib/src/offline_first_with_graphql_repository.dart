import 'dart:async';

import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_offline_request_queue.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_offline_first_with_graphql/src/models/offline_first_with_graphql_model.dart';
import 'package:brick_offline_first_with_graphql/src/offline_first_graphql_policy.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:meta/meta.dart';
import 'package:gql_exec/gql_exec.dart';

/// Ensures the [remoteProvider] is a [GraphqlProvider]. All requests to and
/// from the [remoteProvider] pass through a seperate SQLite queue. If the app
/// is unable to make contact with the [remoteProvider], the queue automatically retries in
/// sequence until it receives a response.
///
/// OfflineFirstWithGraphqlRepository should accept a type argument such as
/// <_RepositoryModel extends OfflineFirstWithGraphqlModel>, however, this causes a type bound
/// error on runtime. The argument should be reintroduced with a future version of the
/// compiler/analyzer.
abstract class OfflineFirstWithGraphqlRepository
    extends OfflineFirstRepository<OfflineFirstWithGraphqlModel> {
  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [GraphqlProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final GraphqlProvider remoteProvider;

  @protected
  late final GraphqlOfflineRequestQueue offlineRequestQueue;

  @protected
  @visibleForTesting
  final Map<Type, Map<Query?, StreamController<List<OfflineFirstWithGraphqlModel>>>> subscriptions =
      {};

  OfflineFirstWithGraphqlRepository({
    bool? autoHydrate,
    required GraphqlProvider graphqlProvider,
    required SqliteProvider sqliteProvider,
    String? loggerName,
    MemoryCacheProvider? memoryCacheProvider,
    required Set<Migration> migrations,
    required GraphqlRequestSqliteCacheManager offlineRequestManager,
  })  : remoteProvider = graphqlProvider,
        offlineRequestQueue = GraphqlOfflineRequestQueue(
          link: graphqlProvider.link,
          requestManager: offlineRequestManager,
        ),
        super(
          autoHydrate: autoHydrate,
          loggerName: loggerName,
          memoryCacheProvider: memoryCacheProvider,
          migrations: migrations,
          sqliteProvider: sqliteProvider,
          remoteProvider: graphqlProvider,
        );

  /// As some links may consume [OfflineFirstGraphqlPolicy] from the request's
  /// context, this adds the policy to the `providerArgs#context`
  @override
  Query? applyPolicyToQuery(
    Query? query, {
    OfflineFirstDeletePolicy? delete,
    OfflineFirstGetPolicy? get,
    OfflineFirstUpsertPolicy? upsert,
  }) {
    return query?.copyWith(providerArgs: {
      ...query.providerArgs,
      'context': <String, ContextEntry>{
        'OfflineFirstGraphqlPolicy': OfflineFirstGraphqlPolicy(
          delete: delete,
          get: get,
          upsert: upsert,
        ),
        ...?query.providerArgs['context'] as Map<String, ContextEntry>?,
      }
    });
  }

  @override
  Future<bool> delete<_Model extends OfflineFirstWithGraphqlModel>(
    _Model instance, {
    Query? query,
    OfflineFirstDeletePolicy policy = OfflineFirstDeletePolicy.optimisticLocal,
  }) async {
    try {
      final result = await super.delete<_Model>(instance, policy: policy, query: query);
      await notifySubscriptionsWithLocalData<_Model>(notifyWhenEmpty: true);
      return result;
    } on GraphQLError catch (e) {
      logger.warning('#delete graphql failure: $e');

      throw OfflineFirstException(_GraphqlException(e));
    }
  }

  @override
  Future<List<_Model>> get<_Model extends OfflineFirstWithGraphqlModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    query,
    bool seedOnly = false,
  }) async {
    try {
      return await super.get<_Model>(
        policy: policy,
        query: query,
        seedOnly: seedOnly,
      );
    } on GraphQLError catch (e) {
      logger.warning('#get graphql failure: $e');

      throw OfflineFirstException(_GraphqlException(e));
    }
  }

  @override
  Future<bool> exists<_Model extends OfflineFirstWithGraphqlModel>({Query? query}) {
    try {
      return super.exists<_Model>(query: query);
    } on GraphQLError catch (e) {
      logger.warning('#get graphql failure: $e');

      throw OfflineFirstException(_GraphqlException(e));
    }
  }

  @protected
  @override
  Future<List<_Model>> hydrate<_Model extends OfflineFirstWithGraphqlModel>({
    bool deserializeSqlite = true,
    Query? query,
  }) async {
    try {
      return await super.hydrate<_Model>(deserializeSqlite: deserializeSqlite, query: query);
    } on GraphQLError catch (e) {
      logger.warning('#hydrate graphql failure: $e');
    }

    return <_Model>[];
  }

  @override
  @mustCallSuper
  Future<void> initialize() async {
    await super.initialize();

    // Start queue processing
    offlineRequestQueue.start();
  }

  @override
  @mustCallSuper
  Future<void> migrate() async {
    await super.migrate();

    // Migrate cached jobs schema
    await offlineRequestQueue.requestManager.migrate();
  }

  /// Iterate through subscriptions after an upsert and notify any [subscribe] listeners.
  @protected
  @visibleForTesting
  Future<void> notifySubscriptionsWithLocalData<_Model extends OfflineFirstWithGraphqlModel>(
      {bool notifyWhenEmpty = true}) async {
    final queriesControllers = subscriptions[_Model]?.entries;
    if (queriesControllers?.isEmpty ?? true) return;

    for (final queryController in queriesControllers!) {
      final query = queryController.key;
      final controller = queryController.value;
      if (controller.isClosed || controller.isPaused) continue;

      if (query == null || memoryCacheProvider.canFind<_Model>(query)) {
        final results = memoryCacheProvider.get<_Model>(query: query);
        if (!controller.isClosed && (results?.isNotEmpty ?? false)) controller.add(results!);
      }

      final existsInSqlite = await sqliteProvider.exists<_Model>(query: query, repository: this);
      if (existsInSqlite) {
        final results = await sqliteProvider.get<_Model>(query: query, repository: this);
        if (!controller.isClosed) controller.add(results);
      } else if (notifyWhenEmpty) {
        if (!controller.isClosed) controller.add(<_Model>[]);
      }
    }
  }

  @override
  Future<List<_Model>> storeRemoteResults<_Model extends OfflineFirstWithGraphqlModel>(
    List<_Model> models, {
    bool shouldNotify = true,
  }) async {
    final results = await super.storeRemoteResults<_Model>(models);
    if (shouldNotify) await notifySubscriptionsWithLocalData<_Model>();
    return results;
  }

  /// Listen for streaming changes from the [remoteProvider]. Data is returned in complete batches.
  /// [get] is invoked on the [memoryCacheProvider] and [sqliteProvider] following an [upsert]
  /// invocation. For more, see [notifySubscriptionsWithLocalData].
  ///
  /// It is **strongly recommended** that this invocation be immediately `.listen`ed assigned
  /// with the assignment/subscription `.cancel()`'d as soon as the data is no longer needed.
  /// The stream will not close naturally.
  Stream<List<_Model>> subscribe<_Model extends OfflineFirstWithGraphqlModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
  }) {
    query ??= Query();
    if (subscriptions[_Model]?[query] != null) {
      return subscriptions[_Model]![query]!.stream as Stream<List<_Model>>;
    }

    final withPolicy = applyPolicyToQuery(query, get: policy);

    StreamSubscription<List<_Model>>? remoteSubscription;
    final adapter = remoteProvider.modelDictionary.adapterFor[_Model];
    if (adapter?.queryOperationTransformer != null &&
        adapter?.queryOperationTransformer!(query, null).subscribe != null) {
      remoteSubscription = remoteProvider
          .subscribe<_Model>(query: withPolicy, repository: this)
          .listen((modelsFromRemote) async {
        // Remote results are never returned directly;
        // after the remote results are fetched they're stored
        // and memory/SQLite is reported to the subscribers
        final modelsIntoSqlite =
            await storeRemoteResults<_Model>(modelsFromRemote, shouldNotify: false);
        memoryCacheProvider.hydrate<_Model>(modelsIntoSqlite);
      });
    }

    final controller = StreamController<List<_Model>>(
      onCancel: () async {
        remoteSubscription?.cancel();
        subscriptions[_Model]?[query]?.close();
        subscriptions[_Model]?.remove(query);
        if (subscriptions[_Model]?.isEmpty ?? false) {
          subscriptions.remove(_Model);
        }
      },
    );

    subscriptions[_Model] ??= {};
    subscriptions[_Model]?[query] = controller;

    // Seed initial data from local when opening a new subscription
    get<_Model>(query: query, policy: OfflineFirstGetPolicy.localOnly).then((results) {
      if (!controller.isClosed) controller.add(results);
    });

    return controller.stream;
  }

  @override
  Future<_Model> upsert<_Model extends OfflineFirstWithGraphqlModel>(
    _Model instance, {
    OfflineFirstUpsertPolicy policy = OfflineFirstUpsertPolicy.optimisticLocal,
    Query? query,
  }) async {
    try {
      final result = await super.upsert<_Model>(instance, policy: policy, query: query);
      await notifySubscriptionsWithLocalData<_Model>();
      return result;
    } on GraphQLError catch (e) {
      logger.warning('#upsert graphql failure: $e');

      throw OfflineFirstException(_GraphqlException(e));
    }
  }
}

/// Subclass [GraphQLError] as an [Exception]
class _GraphqlException implements Exception {
  final GraphQLError error;

  final String message;

  _GraphqlException(this.error) : message = error.message;
}
