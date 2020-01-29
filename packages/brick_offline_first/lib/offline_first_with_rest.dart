import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/offline_first.dart';
import 'package:meta/meta.dart';

import 'package:brick_rest/rest.dart' show RestProvider, RestException, RestAdapter;
import 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstWithRestModel;
import 'package:brick_sqlite_abstract/db.dart' show Migration;
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';

import 'package:brick_sqlite/sqlite.dart';
import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';
import 'package:brick_offline_first/src/offline_queue/offline_request_queue.dart';

export 'package:brick_offline_first/offline_first.dart' hide OfflineFirstRepository;
export 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstWithRestModel;
export 'package:brick_rest/rest.dart' show FieldRename, Rest, RestProvider, RestSerializable;

/// This adapter fetches first from [SqliteProvider] then hydrates with [RestProvider].
abstract class OfflineFirstWithRestAdapter<_Model extends OfflineFirstWithRestModel>
    extends OfflineFirstAdapter<_Model> with RestAdapter<_Model> {
  OfflineFirstWithRestAdapter();
}

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
  final RestProvider remoteProvider;

  /// When the device is connected but the URL is unreachable, the response will
  /// begin with "Tunnel" and ends with "not found".
  ///
  /// As this may be irrelevant to an offline first application, the end implementation may choose
  /// to ignore the warning as the request will eventually be reattempted by the queue.
  /// Defaults `false`.
  final bool throwTunnelNotFoundExceptions;

  OfflineRequestQueue _offlineRequestQueue;

  OfflineFirstWithRestRepository({
    @required RestProvider restProvider,
    @required SqliteProvider sqliteProvider,
    MemoryCacheProvider memoryCacheProvider,
    Set<Migration> migrations,
    bool autoHydrate,
    String loggerName,
    this.throwTunnelNotFoundExceptions = false,

    /// Forwarded to [OfflineQueueHttpClient#reattemptForStatusCodes]
    List<int> reattemptForStatusCodes,
  })  : remoteProvider = RestProvider(
          restProvider.baseEndpoint,
          modelDictionary: restProvider.modelDictionary,
          client: OfflineQueueHttpClient(
            restProvider.client,
            _QUEUE_DATABASE_NAME,
            reattemptForStatusCodes: reattemptForStatusCodes,
          ),
        ),
        super(
          autoHydrate: autoHydrate,
          loggerName: loggerName,
          memoryCacheProvider: memoryCacheProvider,
          migrations: migrations,
          sqliteProvider: sqliteProvider,
        ) {
    _offlineRequestQueue = OfflineRequestQueue(
      client: remoteProvider.client as OfflineQueueHttpClient,
    );
  }

  @override
  Future<bool> delete<_Model extends OfflineFirstWithRestModel>(_Model instance,
      {Query query}) async {
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
  Future<void> initialize() async {
    await super.initialize();

    // Start queue processing
    _offlineRequestQueue.start();
  }

  @override
  Future<void> migrate() async {
    await super.migrate();

    // Migrate cached jobs schema
    await RequestSqliteCache.migrate(_QUEUE_DATABASE_NAME);
  }

  @override
  Future<_Model> upsert<_Model extends OfflineFirstWithRestModel>(_Model instance,
      {Query query}) async {
    try {
      return await super.upsert<_Model>(instance, query: query);
    } on RestException catch (e) {
      logger.warning('#upsert rest failure: $e');
      if (_ignoreTunnelException(e)) {
        return instance;
      }

      throw OfflineFirstException(e);
    }
  }

  @protected
  @override
  Future<List<_Model>> hydrate<_Model extends OfflineFirstWithRestModel>({
    bool deserializeSqlite = true,
    Query query,
  }) async {
    try {
      return await super.hydrate(deserializeSqlite: deserializeSqlite, query: query);
    } on RestException catch (e) {
      logger.warning('#hydrate rest failure: $e');
    }

    return <_Model>[];
  }

  bool _ignoreTunnelException(RestException exception) =>
      OfflineQueueHttpClient.isATunnelNotFoundResponse(exception?.response) &&
      !throwTunnelNotFoundExceptions;
}

const _QUEUE_DATABASE_NAME = 'brick_offline_queue.sqlite';
