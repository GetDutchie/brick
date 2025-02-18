import 'package:brick_offline_first/offline_queue.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_request_sqlite_cache.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

/// Stores all requests in a SQLite database
class RestOfflineQueueClient extends http.BaseClient {
  /// Any request URI that begins with one of these paths will not be
  /// handled by the offline queue and will be forwarded to [_inner].
  ///
  /// For example, if an ignore path is `/v1/ignored-path`, a request
  /// to `http://0.0.0.0:3000/v1/ignored-path/endpoint` will not be
  /// cached and retried on failure.
  final RegExp? _ignorePattern;

  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  final http.Client _inner;

  /// A callback triggered when the response of a request has a status code
  /// which is present in the [reattemptForStatusCodes] list.
  void Function(http.Request request, int statusCode)? onReattempt;

  /// A callback triggered when a request throws an exception during execution.
  ///
  /// `SocketException`s (errors thrown due to missing connectivity) will also be forwarded to this callback.
  void Function(http.Request request, Object error)? onRequestException;

  ///
  final RequestSqliteCacheManager<http.Request> requestManager;

  /// If the response returned from the client is one of these error codes, the request
  /// **will not** be removed from the queue. For example, if the result of a request produces a
  /// 404 status code response (such as in a Tunnel not found exception), the request will
  /// be reattempted.
  ///
  /// Defaults to `[404, 501, 502, 503, 504]`.
  final List<int> reattemptForStatusCodes;

  final Logger _logger;

  /// Describes the type of policy that came from the request, stringified
  /// from the `OfflineFirstPolicy` enum. The property will be removed before
  /// forwarding the request to [_inner].
  static const policyHeader = 'X-Brick-OfflineFirstPolicy';

  /// Stores all requests in a SQLite database
  RestOfflineQueueClient(
    this._inner,
    this.requestManager, {
    this.onReattempt,
    this.onRequestException,
    List<int>? reattemptForStatusCodes,

    /// Any request URI that begins with one of these paths will not be
    /// handled by the offline queue and will be forwarded to [_inner].
    ///
    /// For example, if an ignore path is `/v1/ignored-path`, a request
    /// to `http://0.0.0.0:3000/v1/ignored-path/endpoint` will not be
    /// cached and retried on failure.
    Set<String>? ignorePaths,
  })  : _logger = Logger('OfflineQueueHttpClient#${requestManager.databaseName}'),
        reattemptForStatusCodes = reattemptForStatusCodes ?? [404, 501, 502, 503, 504],
        _ignorePattern = ignorePaths == null ? null : RegExp(ignorePaths.join('|'));

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_ignorePattern != null && request.url.path.startsWith(_ignorePattern)) {
      return await _inner.send(request);
    }

    // Only handle http Requests
    // https://github.com/GetDutchie/brick/issues/440#issuecomment-2357547961
    if (request is! http.Request) {
      return await _inner.send(request);
    }

    final cachePolicy = request.headers.remove(policyHeader);
    final skipCache = cachePolicy == 'requireRemote';
    final cacheItem = RestRequestSqliteCache(request);
    _logger.finest('sending: ${cacheItem.toSqlite()}');

    // Process the request immediately and forward any warnings to the caller
    if (skipCache) return await _inner.send(request);

    // "Pull" requests are ignored. See documentation of `RequestSqliteCache#requestIsPush`.
    if (cacheItem.requestIsPush) {
      final db = await requestManager.getDb();
      // Log immediately before we make the request
      await cacheItem.insertOrUpdate(db, logger: _logger);
    }

    /// When the request is null or an error has occurred, an error-like
    /// response is required because null is unacceptable in [BaseClient]
    final genericErrorResponse = http.StreamedResponse(
      Stream.fromFuture(Future.value('unknown internal error'.codeUnits)),
      501,
      request: request,
    );

    try {
      // Attempt to make HTTP Request
      final resp = await _inner.send(request);

      if (cacheItem.requestIsPush) {
        if (!reattemptForStatusCodes.contains(resp.statusCode)) {
          final db = await requestManager.getDb();
          // request was successfully sent and can be removed
          _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
          await cacheItem.delete(db);
        } else if (onReattempt != null) {
          _logger.finest(
            'request failed, will be reattempted: ${cacheItem.toSqlite()}',
          );
          onReattempt?.call(request, resp.statusCode);
        }
      }

      return resp;
    } catch (e) {
      // e.g. SocketExceptions will be caught here
      onRequestException?.call(request, e);
      _logger.warning('#send: $e');
    } finally {
      // unlock the request for a later a reattempt
      final db = await requestManager.getDb();
      await cacheItem.unlock(db);
    }

    return genericErrorResponse;
  }

  /// Parse the returned response and determine if it needs to be removed from the queue.
  /// As a device with connectivity will still return a response if the endpoint is unreachable,
  /// false positives need to be filtered after the [response] is available.
  static bool isATunnelNotFoundResponse(http.Response response) {
    return response.statusCode == 404 &&
        response.body.startsWith('Tunnel') &&
        response.body.endsWith('not found');
  }
}
