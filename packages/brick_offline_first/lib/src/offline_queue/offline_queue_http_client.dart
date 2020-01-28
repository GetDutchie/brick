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

  /// If the response returned from the client is one of these error codes, the request
  /// **will not** be removed from the queue. For example, if the result of a request produces a
  /// 404 status code response (such as in a Tunnel not found exception), the request will
  /// be reattempted.
  ///
  /// Defaults to `[404, 502, 503, 504]`.
  final List<int> reattemptForStatusCodes;

  final Logger _logger;

  OfflineQueueHttpClient(
    this._inner,
    this.databaseName, {
    List<int> reattemptForStatusCodes,
  })  : _logger = Logger('OfflineQueueHttpClient#$databaseName'),
        reattemptForStatusCodes = reattemptForStatusCodes ?? [404, 502, 503, 504];

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

      if (cacheItem.requestIsPush &&
          resp != null &&
          !reattemptForStatusCodes.contains(resp.statusCode)) {
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

  /// Parse the returned response and determine if it needs to be removed from the queue.
  /// As a device with connectivity will still return a response if the endpoint is unreachable,
  /// false positives need to be filtered after the [response] is available.
  static bool isATunnelNotFoundResponse(http.Response response) {
    return response?.body != null &&
        response.statusCode == 404 &&
        response.body.startsWith("Tunnel") &&
        response.body.endsWith("not found");
  }
}
