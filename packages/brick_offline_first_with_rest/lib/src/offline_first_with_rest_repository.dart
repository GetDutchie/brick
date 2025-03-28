import 'dart:async';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first/offline_queue.dart';
import 'package:brick_offline_first_with_rest/src/models/offline_first_with_rest_model.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_queue_client.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_request_queue.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Ensures the [remoteProvider] is a [RestProvider]. All requests to and
/// from the [remoteProvider] pass through a seperate SQLite queue. If the app
/// is unable to make contact with the [remoteProvider], the queue automatically retries in
/// sequence until it receives a response. Please note that a response may still be an error
/// code such as `404` or `500`. The queue is **only** concerned with connectivity.
abstract class OfflineFirstWithRestRepository<TRepositoryModel extends OfflineFirstWithRestModel>
    extends OfflineFirstRepository<TRepositoryModel> {
  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [RestProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final RestProvider remoteProvider;

  /// If the app is unable to make contact with the [remoteProvider], the queue automatically
  /// retries in sequence until it receives a response. Please note that a response may still
  /// be an error code such as `404` or `500`. The queue is **only** concerned with connectivity.
  @protected
  late RestOfflineRequestQueue offlineRequestQueue;

  /// Ensures the [remoteProvider] is a [RestProvider]. All requests to and
  /// from the [remoteProvider] pass through a seperate SQLite queue. See [offlineRequestQueue].
  OfflineFirstWithRestRepository({
    super.autoHydrate,
    super.loggerName,
    super.memoryCacheProvider,
    required super.migrations,

    /// This property was added in 2.0.0
    ///
    /// To migrate without creating a new the queue database,
    /// import `package:sqflite/sqflite.dart' show databaseFactory;` and
    /// pass `RestRequestSqliteCacheManager('brick_offline_queue.sqlite', databaseFactory)`
    /// as the value for `offlineQueueManager`
    required RequestSqliteCacheManager<http.Request> offlineQueueManager,

    /// This property is forwarded to `RestOfflineQueueClient` and assumes
    /// its defaults
    List<int>? reattemptForStatusCodes,

    /// A callback triggered when the response of a request has a status code
    /// which is present in the `reattemptForStatusCodes` list.
    ///
    /// Forwarded to [RestOfflineQueueClient].
    void Function(http.Request request, int statusCode)? onReattempt,

    /// A callback triggered when a request throws an exception during execution.
    ///
    /// Forwarded to [RestOfflineQueueClient].
    void Function(http.Request, Object)? onRequestException,
    required RestProvider restProvider,
    required super.sqliteProvider,
  })  : remoteProvider = restProvider,
        super(
          remoteProvider: restProvider,
        ) {
    remoteProvider.client = RestOfflineQueueClient(
      restProvider.client,
      offlineQueueManager,
      onReattempt: onReattempt,
      onRequestException: onRequestException,
      reattemptForStatusCodes: reattemptForStatusCodes,
    );
    offlineRequestQueue = RestOfflineRequestQueue(
      client: remoteProvider.client as RestOfflineQueueClient,
    );
  }

  @override
  Query? applyPolicyToQuery(
    Query? query, {
    OfflineFirstDeletePolicy? delete,
    OfflineFirstGetPolicy? get,
    OfflineFirstUpsertPolicy? upsert,
  }) {
    // The header value must be stringified because of how `http.Client` accepts the `headers` Map
    final headerValue = delete?.name ?? get?.name ?? upsert?.name;
    final existingProviderQuery = query?.providerQueries[RestProvider] as RestProviderQuery?;
    final existingProviderQueryRequest = existingProviderQuery?.request;

    return query?.copyWith(
      forProviders: [
        ...query.forProviders,
        if (existingProviderQuery != null)
          existingProviderQuery.copyWith(
            request: existingProviderQueryRequest?.copyWith(
              headers: {
                // This header is removed by the [RestOfflineQueueClient]
                if (headerValue != null) RestOfflineQueueClient.policyHeader: headerValue,
                ...?existingProviderQueryRequest.headers,
              },
            ),
          ),
      ],
    );
  }

  @override
  Future<bool> delete<TModel extends TRepositoryModel>(
    TModel instance, {
    OfflineFirstDeletePolicy policy = OfflineFirstDeletePolicy.optimisticLocal,
    Query? query,
  }) async {
    try {
      return await super.delete<TModel>(instance, policy: policy, query: query);
    } on RestException catch (e) {
      logger.warning('#delete rest failure: $e');

      if (RestOfflineQueueClient.isATunnelNotFoundResponse(e.response) &&
          policy == OfflineFirstDeletePolicy.requireRemote) {
        throw OfflineFirstException(e);
      }

      return false;
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
    } on RestException catch (e) {
      logger.warning('#get rest failure: $e');

      if (RestOfflineQueueClient.isATunnelNotFoundResponse(e.response) &&
          policy != OfflineFirstGetPolicy.awaitRemote) {
        return <TModel>[];
      }

      throw OfflineFirstException(e);
    }
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
    await offlineRequestQueue.client.requestManager.migrate();
  }

  /// [throwOnReattemptStatusCodes] - when `true`, the repository will throw an
  /// [OfflineFirstException] for responses that include a code within `reattemptForStatusCodes`.
  /// Defaults `false`.
  @override
  Future<TModel> upsert<TModel extends TRepositoryModel>(
    TModel instance, {
    OfflineFirstUpsertPolicy policy = OfflineFirstUpsertPolicy.optimisticLocal,
    Query? query,
    bool throwOnReattemptStatusCodes = false,
  }) async {
    try {
      return await super.upsert<TModel>(instance, policy: policy, query: query);
    } on RestException catch (e) {
      logger.warning('#upsert rest failure: $e');
      // since we know we'll reattempt this request, an exception does not need to be reported
      if (policy == OfflineFirstUpsertPolicy.requireRemote) {
        throw OfflineFirstException(e);
      }

      return instance;
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
    } on RestException catch (e) {
      logger.warning('#hydrate rest failure: $e');
    }

    return <TModel>[];
  }
}
