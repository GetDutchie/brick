import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:graphql/client.dart';

import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';

/// Stores all requests in a SQLite database
class OfflineGraphQLClient extends GraphQLClient {
  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  final GraphQLClient _inner;

  final RequestSqliteCacheManager requestManager;

  OfflineGraphQLClient(this._inner, this.requestManager);

  @override
  // ignore: avoid_renaming_method_parameters
  Future<QueryResult> send(QueryOptions option) async {
    final _logger = Logger('OfflineGraphQLClient#${requestManager.databaseName}');
    final request = option.asRequest;
    final cacheItem = RequestSqliteCache(request as http.Request);
    _logger.finest('sending: ${cacheItem.toSqlite()}');

    // "Pull" requests are ignored. See documentation of `RequestSqliteCache#requestIsPush`.
    if (cacheItem.requestIsPush) {
      final db = await requestManager.getDb();
      // Log immediately before we make the request
      await cacheItem.insertOrUpdate(db, logger: _logger);
    }

    /// When the request is null or an error has occurred, an error-like
    /// response is required because null is unacceptable in [BaseClient]
    final _genericErrorResponse = QueryResult.unexecuted;

    try {
      // Attempt to make HTTP Request
      final resp = await _inner.query(option);

      if (cacheItem.requestIsPush && !resp.hasException) {
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
}
