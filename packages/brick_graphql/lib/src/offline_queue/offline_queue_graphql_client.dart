import 'package:brick_graphql/src/offline_queue/request_sqlite_cache_graphql.dart';
import 'package:brick_graphql/src/offline_queue/request_sqlite_cache_manager_graphql.dart';
import 'package:logging/logging.dart';
import 'package:graphql/client.dart';

/// Stores all requests in a SQLite database
class OfflineQueueGraphqlClient {
  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  final GraphQLClient _inner;

  final RequestGrapqQLSqliteCacheManager requestManager;

  final Logger _logger;

  OfflineQueueGraphqlClient(
    this._inner,
    this.requestManager, {
    List<int>? reattemptForStatusCodes,
  }) : _logger = Logger('OfflineQueueHttpClient#${requestManager.databaseName}');

  @override
  Future<Response> send(Request request) async {
    final cacheItem = RequestGraphQLSqliteCache(request);
    _logger.finest('sending: ${cacheItem.toSqlite()}');

    final db = await requestManager.getDb();
    // Log immediately before we make the request
    await cacheItem.insertOrUpdate(db, logger: _logger);

    /// When the request is null or an error has occurred, an error-like
    /// response is required because null is unacceptable in [BaseClient]
    // ignore: prefer_const_constructors
    final _genericErrorResponse =
        // ignore: prefer_const_literals_to_create_immutables
        Response(errors: const [GraphQLError(message: 'Unknown error')], data: null);

    try {
      // Attempt to make HTTP Request
      final resp = await _inner.link.request(request).first;

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

  /// Parse the returned response and determine if it needs to be removed from the queue.
  /// As a device with connectivity will still return a response if the endpoint is unreachable,
  /// false positives need to be filtered after the [response] is available.
  static bool isATunnelNotFoundResponse(Response response) {
    return response.errors == [];
  }
}
