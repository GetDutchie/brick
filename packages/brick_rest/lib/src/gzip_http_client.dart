import 'dart:io';
import 'package:http/http.dart' as http;

class GzipHttpClient extends http.BaseClient {
  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  final http.Client _inner;

  GzipHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request is! http.Request) return _inner.send(request);

    final httpRequest = request as http.Request;
    if (httpRequest.body == null || httpRequest.body.isEmpty) return _inner.send(request);
    httpRequest.bodyBytes = gzip.encode(httpRequest.body.codeUnits);
    httpRequest.headers['Content-Encoding'] = 'gzip';

    return _inner.send(httpRequest);
  }
}
