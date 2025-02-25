import 'dart:async';

import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_offline_request_queue.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_offline_first_with_graphql/src/models/offline_first_with_graphql_model.dart';
import 'package:brick_offline_first_with_graphql/src/offline_first_graphql_policy.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:meta/meta.dart';

/// Ensures the [remoteProvider] is a [GraphqlProvider]. All requests to and
/// from the [remoteProvider] pass through a seperate SQLite queue. If the app
/// is unable to make contact with the [remoteProvider], the queue automatically retries in
/// sequence until it receives a response.
abstract class OfflineFirstWithGraphqlRepository<
        TRepositoryModel extends OfflineFirstWithGraphqlModel>
    extends OfflineFirstRepository<TRepositoryModel> {
  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [GraphqlProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final GraphqlProvider remoteProvider;

  ///
  @protected
  late final GraphqlOfflineRequestQueue offlineRequestQueue;

  /// Ensures the [remoteProvider] is a [GraphqlProvider]. All requests to and
  /// from the [remoteProvider] pass through a seperate SQLite queue. If the app
  /// is unable to make contact with the [remoteProvider], the queue automatically retries in
  /// sequence until it receives a response.
  OfflineFirstWithGraphqlRepository({
    super.autoHydrate,
    required GraphqlProvider graphqlProvider,
    required super.sqliteProvider,
    super.loggerName,
    super.memoryCacheProvider,
    required super.migrations,
    required GraphqlRequestSqliteCacheManager offlineRequestManager,
  })  : remoteProvider = graphqlProvider,
        offlineRequestQueue = GraphqlOfflineRequestQueue(
          link: graphqlProvider.link,
          requestManager: offlineRequestManager,
        ),
        super(
          remoteProvider: graphqlProvider,
        );

  /// As some links may consume [OfflineFirstGraphqlPolicy] from the request's
  /// context, this adds the policy to [Query.providerQueries].
  @override
  Query? applyPolicyToQuery(
    Query? query, {
    OfflineFirstDeletePolicy? delete,
    OfflineFirstGetPolicy? get,
    OfflineFirstUpsertPolicy? upsert,
  }) {
    final queryContext =
        (query?.providerQueries[GraphqlProvider] as GraphqlProviderQuery?)?.context;
    final context = (queryContext ?? const Context()).withEntry(
      OfflineFirstGraphqlPolicy(
        delete: delete,
        get: get,
        upsert: upsert,
      ),
    );

    return query?.copyWith(
      forProviders: [
        ...query.forProviders,
        GraphqlProviderQuery(
          operation: (query.providerQueries[GraphqlProvider] as GraphqlProviderQuery?)?.operation,
          context: context,
        ),
      ],
    );
  }

  @override
  Future<bool> delete<TModel extends TRepositoryModel>(
    TModel instance, {
    Query? query,
    OfflineFirstDeletePolicy policy = OfflineFirstDeletePolicy.optimisticLocal,
  }) async {
    try {
      return await super.delete<TModel>(instance, policy: policy, query: query);
    } on GraphQLError catch (e) {
      logger.warning('#delete graphql failure: $e');

      throw OfflineFirstException(_GraphqlException(e));
    }
  }

  @override
  Future<List<TModel>> get<TModel extends TRepositoryModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
    bool seedOnly = false,
  }) async {
    try {
      return await super.get<TModel>(
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
  Future<bool> exists<TModel extends TRepositoryModel>({Query? query}) {
    try {
      return super.exists<TModel>(query: query);
    } on GraphQLError catch (e) {
      logger.warning('#get graphql failure: $e');

      throw OfflineFirstException(_GraphqlException(e));
    }
  }

  @protected
  @override
  Future<List<TModel>> hydrate<TModel extends TRepositoryModel>({
    bool deserializeSqlite = true,
    Query? query,
  }) async {
    try {
      return await super.hydrate<TModel>(deserializeSqlite: deserializeSqlite, query: query);
    } on GraphQLError catch (e) {
      logger.warning('#hydrate graphql failure: $e');
    }

    return <TModel>[];
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

  /// Listen for streaming changes from the [remoteProvider]. Data is returned in complete batches.
  /// [get] is invoked on the [memoryCacheProvider] and [sqliteProvider] following an [upsert]
  /// invocation. For more, see [notifySubscriptionsWithLocalData].
  ///
  /// It is **strongly recommended** that this invocation be immediately `.listen`ed assigned
  /// with the assignment/subscription `.cancel()`'d as soon as the data is no longer needed.
  /// The stream will not close naturally.
  @override
  Stream<List<TModel>> subscribe<TModel extends TRepositoryModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    Query? query,
  }) {
    query ??= const Query();
    if (subscriptions[TModel]?[query] != null) {
      return subscriptions[TModel]![query]!.stream as Stream<List<TModel>>;
    }

    final withPolicy = applyPolicyToQuery(query, get: policy);

    StreamSubscription<List<TModel>>? remoteSubscription;
    final adapter = remoteProvider.modelDictionary.adapterFor[TModel];
    if (adapter?.queryOperationTransformer != null &&
        adapter?.queryOperationTransformer!(query, null).subscribe != null) {
      remoteSubscription = remoteProvider
          .subscribe<TModel>(query: withPolicy, repository: this)
          .listen((modelsFromRemote) async {
        // Remote results are never returned directly;
        // after the remote results are fetched they're stored
        // and memory/SQLite is reported to the subscribers
        final modelsIntoSqlite =
            await storeRemoteResults<TModel>(modelsFromRemote, shouldNotify: false);
        memoryCacheProvider.hydrate<TModel>(modelsIntoSqlite);
      });
    }

    final controller = StreamController<List<TModel>>(
      onCancel: () async {
        await remoteSubscription?.cancel();
        await subscriptions[TModel]?[query]?.close();
        subscriptions[TModel]?.remove(query);
        if (subscriptions[TModel]?.isEmpty ?? false) {
          subscriptions.remove(TModel);
        }
      },
    );

    subscriptions[TModel] ??= {};
    subscriptions[TModel]?[query] = controller;

    // Seed initial data from local when opening a new subscription
    // ignore: discarded_futures
    get<TModel>(query: query, policy: OfflineFirstGetPolicy.localOnly).then((results) {
      if (!controller.isClosed) controller.add(results);
    });

    return controller.stream;
  }

  @override
  Future<TModel> upsert<TModel extends TRepositoryModel>(
    TModel instance, {
    OfflineFirstUpsertPolicy policy = OfflineFirstUpsertPolicy.optimisticLocal,
    Query? query,
  }) async {
    try {
      return await super.upsert<TModel>(instance, policy: policy, query: query);
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
