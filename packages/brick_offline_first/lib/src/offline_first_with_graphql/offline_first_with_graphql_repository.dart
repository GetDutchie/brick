import 'package:brick_offline_first/src/offline_queue/graphql/graphql_offline_request_queue.dart';
import 'package:brick_offline_first/src/offline_queue/graphql/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/offline_first.dart';
import 'package:meta/meta.dart';
import 'package:gql_exec/gql_exec.dart';

import 'package:brick_graphql/graphql.dart' show GraphqlProvider;
import 'package:brick_sqlite_abstract/db.dart' show Migration;

import 'package:brick_offline_first/src/offline_queue/graphql/graphql_offline_queue_link.dart';

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

  OfflineFirstWithGraphqlRepository({
    required GraphqlProvider graphqlProvider,
    required SqliteProvider sqliteProvider,
    MemoryCacheProvider? memoryCacheProvider,
    required Set<Migration> migrations,
    bool? autoHydrate,
    String? loggerName,
    GraphqlRequestSqliteCacheManager? offlineQueueLinkSqliteCacheManager,
  })  : remoteProvider = graphqlProvider,
        super(
          autoHydrate: autoHydrate,
          loggerName: loggerName,
          memoryCacheProvider: memoryCacheProvider,
          migrations: migrations,
          sqliteProvider: sqliteProvider,
          remoteProvider: graphqlProvider,
        ) {
    remoteProvider.link = GraphqlOfflineQueueLink(
      graphqlProvider.link,
      offlineQueueLinkSqliteCacheManager ?? GraphqlRequestSqliteCacheManager(_queueDatabaseName),
    );
    offlineRequestQueue = GraphqlOfflineRequestQueue(
      link: remoteProvider.link as GraphqlOfflineQueueLink,
    );
  }

  @override
  Future<bool> delete<_Model extends OfflineFirstWithGraphqlModel>(_Model instance,
      {Query? query}) async {
    try {
      return await super.delete<_Model>(instance, query: query);
    } on GraphQLError catch (e) {
      logger.warning('#delete graphql failure: $e');

      throw OfflineFirstException(_GraphqlException(e));
    }
  }

  @override
  Future<List<_Model>> get<_Model extends OfflineFirstWithGraphqlModel>({
    query,
    bool alwaysHydrate = false,
    bool hydrateUnexisting = true,
    bool requireRemote = false,
    bool seedOnly = false,
  }) async {
    try {
      return await super.get(
        alwaysHydrate: alwaysHydrate,
        hydrateUnexisting: hydrateUnexisting,
        query: query,
        requireRemote: requireRemote,
        seedOnly: seedOnly,
      );
    } on GraphQLError catch (e) {
      logger.warning('#get graphql failure: $e');

      throw OfflineFirstException(_GraphqlException(e));
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
    await offlineRequestQueue.link.requestManager.migrate();
  }

  @override
  Future<_Model> upsert<_Model extends OfflineFirstWithGraphqlModel>(_Model instance,
      {Query? query, bool throwOnReattemptStatusCodes = false}) async {
    try {
      return await super.upsert<_Model>(instance, query: query);
    } on GraphQLError catch (e) {
      logger.warning('#upsert graphql failure: $e');

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
      return await super.hydrate(deserializeSqlite: deserializeSqlite, query: query);
    } on GraphQLError catch (e) {
      logger.warning('#hydrate graphql failure: $e');
    }

    return <_Model>[];
  }
}

const _queueDatabaseName = 'brick_offline_queue.sqlite';

/// Subclass [GraphQLError] as an [Exception]
class _GraphqlException implements Exception {
  final GraphQLError error;

  final String message;

  _GraphqlException(this.error) : message = error.message;
}
