import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'request_sqlite_cache.dart';

/// Stores all requests in a SQLite database
class OfflineQueueHttpClient extends http.BaseClient {
  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  final http.Client _inner;

  /// Use separate databases for unrelated functions. For example, your app code should not use
  /// the same client as the one sending analytics to a 3rd party.
  final String databaseName;

  final Logger _logger;

  OfflineQueueHttpClient(
    this._inner,
    this.databaseName,
  ) : _logger = Logger('OfflineQueueHttpClient#$databaseName');

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final cacheItem = RequestSqliteCache(request as http.Request, databaseName);
    _logger.finest('sending: ${cacheItem.toSqlite()}');

    // "Pull" requests are ignored. See documentation of `RequestSqliteCache#requestIsPush`.
    if (cacheItem.requestIsPush) {
      // Log immediately before we make the request
      await cacheItem.insertOrUpdate(_logger);
    }

    /// When the request is null or an error has occurred, an error-like
    /// response is required because null is unacceptable in [BaseClient]
    final _genericErrorResponse = http.StreamedResponse(
      Stream.fromFuture(Future.value('unknown internal error'.codeUnits)),
      501,
    );

    try {
      // Attempt to make HTTP Request
      final resp = await _inner.send(request);

      // if a response was delivered back to the device and this is not a fetch request
      final receivedResponseFromPushRequest = cacheItem.requestIsPush && resp != null;

      if (receivedResponseFromPushRequest) {
        // request was successfully sent and can be removed
        _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
        await cacheItem.delete();
      }

      return resp ?? _genericErrorResponse;
    } catch (e) {
      _logger.warning(e);
    }

    return _genericErrorResponse;
  }

  Future<void> reattemptUnprocessedJobs() async {
    final requests = await RequestSqliteCache.unproccessedRequests(databaseName);
    requests.forEach(send);
  }
}
