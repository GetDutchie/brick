import 'dart:io';
import 'package:http/http.dart' as http;

/// Gzip all incoming requests and mutate them so that the payload is encoded.
/// Additionally, (over)writes the header `{'Content-Encoding': 'gzip'}` to all requests.
class GzipHttpClient extends http.BaseClient {
  final GZipCodec _encoder;

  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  final http.Client _inner;

  GzipHttpClient(
    this._inner, {
    int level = 6,
  }) : _encoder = GZipCodec(level: level);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request is! http.Request) return _inner.send(request);

    final httpRequest = request as http.Request;
    if (httpRequest.body == null || httpRequest.body.isEmpty) return _inner.send(request);
    httpRequest.bodyBytes = _encoder.encode(httpRequest.body.codeUnits);
    httpRequest.headers['Content-Encoding'] = 'gzip';

    return _inner.send(httpRequest);
  }
}
