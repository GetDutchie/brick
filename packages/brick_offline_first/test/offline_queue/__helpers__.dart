import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';

class MockOfflineClient extends Mock implements OfflineQueueHttpClient {}

MockClient stubResult({String response = 'response', int? statusCode}) {
  return MockClient((req) async {
    return http.Response(response, statusCode ?? 200, request: req);
  });
}
