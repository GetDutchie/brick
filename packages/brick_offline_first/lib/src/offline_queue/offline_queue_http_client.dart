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

  Future<http.Response> post(url, {headers, body, encoding}) async {
    final resp = await super.post(url, headers: headers, body: body, encoding: encoding);
    await _ignoreOrRemoveFromQueue(resp);
    return resp;
  }

  Future<http.Response> put(url, {headers, body, encoding}) async {
    final resp = await super.put(url, headers: headers, body: body, encoding: encoding);
    await _ignoreOrRemoveFromQueue(resp);
    return resp;
  }

  Future<http.Response> delete(url, {headers}) async {
    final resp = await super.delete(url, headers: headers);
    await _ignoreOrRemoveFromQueue(resp);
    return resp;
  }

  Future<http.Response> patch(url, {headers, body, encoding}) async {
    final resp = await super.patch(url, headers: headers, body: body, encoding: encoding);
    await _ignoreOrRemoveFromQueue(resp);
    return resp;
  }

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

  /// Parse the returned response and determine if it needs to be removed from the queue.
  /// As a device with connectivity will still return a response if the endpoint is unreachable,
  /// false positives need to be filtered after the [response] is available.
  Future<void> _ignoreOrRemoveFromQueue(http.Response response) async {
    if (response == null || response.request == null) return;
    final cacheItem = RequestSqliteCache(response.request as http.Request, databaseName);

    // The device is connected but the url is unavailable
    final tunnelNotFound = response.body != null &&
        response.statusCode == 404 &&
        response.body.startsWith("Tunnel") &&
        response.body.endsWith("not found");

    if (tunnelNotFound) return;

    // request was successfully sent and can be removed
    _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
    await cacheItem.delete();
  }
}
