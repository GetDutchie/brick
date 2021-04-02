import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';

class MockOfflineClient extends Mock implements OfflineQueueHttpClient {}

class MockClient extends Mock implements http.Client {}

MockClient stubResult({String response = 'response', int? statusCode, String? requestBody}) {
  final inner = MockClient();

  // when(inner.send(any)).thenAnswer((_) {
  //   return Future.value(_buildStreamedResponse(response, statusCode, requestBody));
  // });

  return inner;
}

/// Useful for mocking a response to [http.Client]'s `#send` method
http.StreamedResponse _buildStreamedResponse(String response,
    [int? statusCode, String? requestBody]) {
  statusCode ??= 200;

  // args don't matter,
  final request = http.Request('POST', Uri.parse('http://localhost:3000'));
  request.body = requestBody ?? response;

  final resp = http.Response(response, statusCode, request: request);
  final stream = Stream.fromFuture(Future.value(resp.bodyBytes));
  return http.StreamedResponse(
    stream,
    resp.statusCode,
    request: resp.request,
    headers: resp.headers,
    isRedirect: resp.isRedirect,
    reasonPhrase: resp.reasonPhrase,
  );
}
