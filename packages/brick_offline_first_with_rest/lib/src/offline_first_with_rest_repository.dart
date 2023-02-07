import 'dart:async';

import 'package:brick_offline_first_with_rest/src/models/offline_first_with_rest_model.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_queue_client.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_request_queue.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first/offline_queue.dart';
import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'package:brick_rest/brick_rest.dart' show RestProvider, RestException;

/// Ensures the [remoteProvider] is a [RestProvider]. All requests to and
/// from the [remoteProvider] pass through a seperate SQLite queue. If the app
/// is unable to make contact with the [remoteProvider], the queue automatically retries in
/// sequence until it receives a response. Please note that a response may still be an error
/// code such as `404` or `500`. The queue is **only** concerned with connectivity.
///
/// OfflineFirstWithRestRepository should accept a type argument such as
/// <_RepositoryModel extends OfflineFirstWithRestModel>, however, this causes a type bound
/// error on runtime. The argument should be reintroduced with a future version of the
/// compiler/analyzer.
abstract class OfflineFirstWithRestRepository
    extends OfflineFirstRepository<OfflineFirstWithRestModel> {
  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [RestProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final RestProvider remoteProvider;

  @protected
  late RestOfflineRequestQueue offlineRequestQueue;

  OfflineFirstWithRestRepository({
    bool? autoHydrate,
    String? loggerName,
    MemoryCacheProvider? memoryCacheProvider,
    required Set<Migration> migrations,

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
    required RestProvider restProvider,
    required SqliteProvider sqliteProvider,
  })  : remoteProvider = restProvider,
        super(
          autoHydrate: autoHydrate,
          loggerName: loggerName,
          memoryCacheProvider: memoryCacheProvider,
          migrations: migrations,
          sqliteProvider: sqliteProvider,
          remoteProvider: restProvider,
        ) {
    remoteProvider.client = RestOfflineQueueClient(
      restProvider.client,
      offlineQueueManager,
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
    final headerValue = delete?.toString().split('.').last ??
        get?.toString().split('.').last ??
        upsert?.toString().split('.').last;
    return query?.copyWith(providerArgs: {
      ...query.providerArgs,
      'headers': {
        // This header is removed by the [RestOfflineQueueClient]
        if (headerValue != null) RestOfflineQueueClient.policyHeader: headerValue,
        ...?query.providerArgs['headers'] as Map<String, String>?,
      }
    });
  }

  @override
  Future<bool> delete<_Model extends OfflineFirstWithRestModel>(
    _Model instance, {
    OfflineFirstDeletePolicy policy = OfflineFirstDeletePolicy.optimisticLocal,
    Query? query,
  }) async {
    try {
      return await super.delete<_Model>(instance, policy: policy, query: query);
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
  Future<List<_Model>> get<_Model extends OfflineFirstWithRestModel>({
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
    query,
    bool seedOnly = false,
  }) async {
    try {
      return await super.get(
        policy: policy,
        query: query,
        seedOnly: seedOnly,
      );
    } on RestException catch (e) {
      logger.warning('#get rest failure: $e');

      if (RestOfflineQueueClient.isATunnelNotFoundResponse(e.response) &&
          policy != OfflineFirstGetPolicy.awaitRemote) {
        return <_Model>[];
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
  Future<_Model> upsert<_Model extends OfflineFirstWithRestModel>(
    _Model instance, {
    OfflineFirstUpsertPolicy policy = OfflineFirstUpsertPolicy.optimisticLocal,
    Query? query,
    bool throwOnReattemptStatusCodes = false,
  }) async {
    try {
      return await super.upsert<_Model>(instance, policy: policy, query: query);
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
  Future<List<_Model>> hydrate<_Model extends OfflineFirstWithRestModel>({
    bool deserializeSqlite = true,
    Query? query,
  }) async {
    try {
      return await super.hydrate(deserializeSqlite: deserializeSqlite, query: query);
    } on RestException catch (e) {
      logger.warning('#hydrate rest failure: $e');
    }

    return <_Model>[];
  }
}
