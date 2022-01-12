import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/offline_first.dart';
import 'package:meta/meta.dart';

import 'package:brick_rest/rest.dart' show RestProvider, RestException;
import 'package:brick_offline_first_abstract/abstract.dart'
    show OfflineFirstWithRestModel;
import 'package:brick_sqlite_abstract/db.dart' show Migration;

import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';
import 'package:brick_offline_first/src/offline_queue/offline_request_queue.dart';

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
    extends OfflineFirstRepository<OfflineFirst> {
  /// If the response returned from the client is one of these error codes, the request
  /// **will not** be removed from the queue. For example, if the result of a request produces a
  /// 404 status code response (such as in a Tunnel not found exception), the request will
  /// be reattempted. If [upsert] response matches this status code, it **will not** throw
  /// an exception.
  ///
  /// Defaults to `[404, 501, 502, 503, 504]`.
  @protected
  final List<int> reattemptForStatusCodes;

  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [RestProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final RestProvider remoteProvider;

  /// When the device is connected but the URL is unreachable, the response will
  /// begin with "Tunnel" and ends with "not found".
  ///
  /// As this may be irrelevant to an offline first application, the end implementation may choose
  /// to ignore the warning as the request will eventually be reattempted by the queue.
  /// Defaults `false`.
  final bool throwTunnelNotFoundExceptions;

  @protected
  late OfflineRequestQueue offlineRequestQueue;

  OfflineFirstWithRestRepository({
    required RestProvider restProvider,
    required SqliteProvider sqliteProvider,
    MemoryCacheProvider? memoryCacheProvider,
    required Set<Migration> migrations,
    bool? autoHydrate,
    String? loggerName,
    RequestSqliteCacheManager? offlineQueueHttpClientRequestSqliteCacheManager,
    this.throwTunnelNotFoundExceptions = false,
    this.reattemptForStatusCodes = const [404, 501, 502, 503, 504],
  })  : remoteProvider = restProvider,
        super(
          autoHydrate: autoHydrate,
          loggerName: loggerName,
          memoryCacheProvider: memoryCacheProvider,
          migrations: migrations,
          sqliteProvider: sqliteProvider,
          remoteProvider: restProvider,
        ) {
    remoteProvider.client = OfflineQueueHttpClient(
      restProvider.client,
      offlineQueueHttpClientRequestSqliteCacheManager ??
          RequestSqliteCacheManager(_queueDatabaseName),
      reattemptForStatusCodes: reattemptForStatusCodes,
    );
    offlineRequestQueue = OfflineRequestQueue(
      client: remoteProvider.client as OfflineQueueHttpClient,
    );
  }

  @override
  Future<bool> delete<_Model extends OfflineFirstWithRestModel>(_Model instance,
      {Query? query}) async {
    try {
      return await super.delete<_Model>(instance, query: query);
    } on RestException catch (e) {
      logger.warning('#delete rest failure: $e');
      if (_ignoreTunnelException(e)) {
        return false;
      }

      throw OfflineFirstException(e);
    }
  }

  @override
  Future<List<_Model>> get<_Model extends OfflineFirstWithRestModel>({
    query,
    bool alwaysHydrate = false,
    bool hydrateUnexisting = true,
    bool requireRemote = false,
    bool seedOnly = false,
  }) async {
    try {
      return await super.get(
        query: query,
        alwaysHydrate: alwaysHydrate,
        hydrateUnexisting: hydrateUnexisting,
        requireRemote: requireRemote,
        seedOnly: seedOnly,
      );
    } on RestException catch (e) {
      logger.warning('#get rest failure: $e');
      if (_ignoreTunnelException(e)) {
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
      _Model instance,
      {Query? query,
      bool throwOnReattemptStatusCodes = false}) async {
    try {
      return await super.upsert<_Model>(instance, query: query);
    } on RestException catch (e) {
      logger.warning('#upsert rest failure: $e');
      if (_ignoreTunnelException(e)) {
        return instance;
      }

      // since we know we'll reattempt this request, an exception does not need to be reported
      if (reattemptForStatusCodes.contains(e.response.statusCode) &&
          !throwOnReattemptStatusCodes) {
        return instance;
      }

      throw OfflineFirstException(e);
    }
  }

  @protected
  @override
  Future<List<_Model>> hydrate<_Model extends OfflineFirstWithRestModel>({
    bool deserializeSqlite = true,
    Query? query,
  }) async {
    try {
      return await super
          .hydrate(deserializeSqlite: deserializeSqlite, query: query);
    } on RestException catch (e) {
      logger.warning('#hydrate rest failure: $e');
    }

    return <_Model>[];
  }

  bool _ignoreTunnelException(RestException exception) =>
      OfflineQueueHttpClient.isATunnelNotFoundResponse(exception.response) &&
      !throwTunnelNotFoundExceptions;
}

const _queueDatabaseName = 'brick_offline_queue.sqlite';
