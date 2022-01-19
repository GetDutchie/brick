import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/offline_first_with_graphql/offline_request_queue_graphql.dart';
import 'package:brick_graphql/src/offline_queue/offline_queue_graphql_client.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:graphql/src/graphql_client.dart';
import 'package:meta/meta.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';

import 'package:brick_rest/rest.dart' show RestProvider, RestException;
import 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstGraphQLModel;
import 'package:brick_sqlite_abstract/db.dart' show Migration;
import 'package:brick_offline_first/offline_first.dart';

import 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstWithRestModel;

import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
abstract class OfflineFirstWithGraphQLRespository
    extends OfflineFirstRepository<OfflineFirstGraphQLModel> {
  /// The type declaration is important here for the rare circumstances that
  /// require interfacting with [RestProvider]'s client directly.
  @override
  // ignore: overridden_fields
  final GraphQLProvider remoteProvider;

  @protected
  late OfflineGraphqlRequestQueue offlineRequestQueue;

  OfflineFirstWithGraphQLRespository({
    required GraphQLProvider restProvider,
    required SqliteProvider sqliteProvider,
    MemoryCacheProvider? memoryCacheProvider,
    required Set<Migration> migrations,
    required String queryString,
    bool? autoHydrate,
    String? loggerName,
    RequestSqliteCacheManager? offlineQueueHttpClientRequestSqliteCacheManager,
  })  : remoteProvider = restProvider,
        super(
          autoHydrate: autoHydrate,
          loggerName: loggerName,
          memoryCacheProvider: memoryCacheProvider,
          migrations: migrations,
          sqliteProvider: sqliteProvider,
          remoteProvider: restProvider,
        ) {
    remoteProvider.client = OfflineGraphQLClient(
      restProvider.client,
      offlineQueueHttpClientRequestSqliteCacheManager ??
          RequestSqliteCacheManager(_queueDatabaseName),
    ) as GraphQLClient;
    offlineRequestQueue = OfflineGraphqlRequestQueue(
      client: remoteProvider.client as OfflineGraphQLClient,
      queryString: '',
    );
  }

  @override
  Future<bool> delete<_Model extends OfflineFirstGraphQLModel>(_Model instance,
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
  Future<List<_Model>> get<_Model extends OfflineFirstGraphQLModel>({
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
  Future<_Model> upsert<_Model extends OfflineFirstGraphQLModel>(_Model instance,
      {Query? query, bool throwOnReattemptStatusCodes = false}) async {
    try {
      return await super.upsert<_Model>(instance, query: query);
    } on RestException catch (e) {
      logger.warning('#upsert rest failure: $e');
      if (_ignoreTunnelException(e)) {
        return instance;
      }

      // since we know we'll reattempt this request, an exception does not need to be reported
      if (reattemptForStatusCodes.contains(e.response.statusCode) && !throwOnReattemptStatusCodes) {
        return instance;
      }

      throw OfflineFirstException(e);
    }
  }

  @protected
  @override
  Future<List<_Model>> hydrate<_Model extends OfflineFirstGraphQLModel>({
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

  bool _ignoreTunnelException(RestException exception) =>
      OfflineGraphqlRequestQueue.isATunnelNotFoundResponse(exception.response) &&
      !throwTunnelNotFoundExceptions;
}

const _queueDatabaseName = 'brick_offline_queue.sqlite';
