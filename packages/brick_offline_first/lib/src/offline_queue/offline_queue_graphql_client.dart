import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache.dart';
import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:graphql/client.dart';

/// Stores all requests in a SQLite database
class OfflineQueueGraphqlClient {
  /// A DocumentNode GraphQL execution interface
  /// https://pub.dev/documentation/gql_link/latest/link/Link-class.html
  final Link _inner;

  final RequestGraphqlSqliteCacheManager requestManager;

  final Logger _logger;

  OfflineQueueGraphqlClient(
    this._inner,
    this.requestManager, {
    List<int>? reattemptForStatusCodes,
  }) : _logger = Logger('OfflineQueueHttpClient#${requestManager.databaseName}');

  @override
  Future<Response> send(Request request) async {
    final cacheItem = RequestGraphqlSqliteCache(request);
    _logger.finest('sending: ${cacheItem.toSqlite()}');

    final db = await requestManager.getDb();
    // Log immediately before we make the request
    await cacheItem.insertOrUpdate(db, logger: _logger);

    /// When the request is null a generic Graphql error needs to be generated
    final _genericErrorResponse =
        Response(errors: const [GraphQLError(message: 'Unknown error')], data: null);

    try {
      // Attempt to make Graphql Request
      final resp = await _inner.request(request).first;

      if (!(resp.errors == [])) {
        final db = await requestManager.getDb();
        // request was successfully sent and can be removed
        _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
        await cacheItem.delete(db);
      }

      return resp;
    } catch (e) {
      _logger.warning('#send: $e');
    } finally {
      final db = await requestManager.getDb();
      await cacheItem.unlock(db);
    }

    return _genericErrorResponse;
  }

  /// This method checks if there are any Graphql errors present
  static bool isAGraphqlErrorsEmpty(Response response) {
    return response.errors == [];
  }
}
