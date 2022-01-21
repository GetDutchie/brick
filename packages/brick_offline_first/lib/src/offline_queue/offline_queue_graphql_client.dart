import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache_manager.dart';
import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:logging/logging.dart';

/// Stores all requests in a SQLite database
class OfflineQueueGraphqlClient extends Link {
  /// A DocumentNode GraphQL execution interface
  /// https://pub.dev/documentation/gql_link/latest/link/Link-class.html
  final Link _inner;

  final RequestGraphqlSqliteCacheManager requestManager;

  final Logger _logger;

  OfflineQueueGraphqlClient(this._inner, this.requestManager)
      : _logger = Logger('OfflineQueueHttpClient#${requestManager.databaseName}');

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final cacheItem = RequestGraphqlSqliteCache(request: request);
    _logger.finest('sending: ${cacheItem.toSqlite()}');

    final db = await requestManager.getDb();
    // Log immediately before we make the request
    await cacheItem.insertOrUpdate(db, logger: _logger);

    /// When the request is null a generic Graphql error needs to be generated
    final _genericErrorResponse = Stream.fromIterable([
      const Response(errors: [GraphQLError(message: 'Unknown error')], data: null)
    ]);

    try {
      // Attempt to make Graphql Request, handle it as a traditional response to do check
      final response = await _inner.request(request).first;
      // get it back as a stream so that it can be return
      final streamAsStream = _inner.request(request).asBroadcastStream();

      if (!areGraphqlErrorsEmpty(response)) {
        final db = await requestManager.getDb();
        // request was successfully sent and can be removed
        _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
        await cacheItem.delete(db);
      }

      yield* streamAsStream;
    } catch (e) {
      _logger.warning('#send: $e');
    } finally {
      final db = await requestManager.getDb();
      await cacheItem.unlock(db);
    }

    yield* _genericErrorResponse;
  }

  /// This method checks if there are any Graphql errors present
  /// TODO need to find a better way to find out how a Link determines a request is offline
  /// Similar to the _ignoreTunnelException
  static bool areGraphqlErrorsEmpty(Response response) {
    return response.errors == [];
  }
}
