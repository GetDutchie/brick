import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Gzip all incoming requests and mutate them so that the payload is encoded.
/// Additionally, (over)writes the header `{'Content-Encoding': 'gzip'}` and
/// `{'Accept-Encoding': 'gzip'}` to all requests.
class GZipHttpClient extends http.BaseClient {
  final GZipCodec _encoder;

  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  ///
  /// By default, a new [http.Client] will be instantiated and used.
  @protected
  final http.Client innerClient;

  GZipHttpClient({
    http.Client innerClient,

    /// The higher the level, the smaller the output at the expense of memory.
    /// Defaults to [GZipCodec]'s default `6`.
    int level = 6,
  })  : innerClient = innerClient ?? http.Client(),
        _encoder = GZipCodec(level: level);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request is! http.Request) return innerClient.send(request);

    final httpRequest = request as http.Request;
    if (httpRequest.body == null || httpRequest.body.isEmpty) return innerClient.send(request);
    httpRequest.bodyBytes = _encoder.encode(httpRequest.body.codeUnits);
    httpRequest.headers['Content-Encoding'] = 'gzip';

    return innerClient.send(httpRequest);
  }
}
