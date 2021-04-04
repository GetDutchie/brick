import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:brick_offline_first/src/testing/stub_offline_first_with_rest_model.dart';

/// Manages multiple stubbed [OfflineFirstWithRestModel]s.
MockClient stubRestClient(String baseUrl, List<StubOfflineFirstWithRestModel> modelStubs) {
  final endpoints = modelStubs.fold<Map<Uri, String>>({}, (acc, modelStub) {
    for (final endpoint in modelStub.apiResponses.keys) {
      acc[Uri.parse('$baseUrl/$endpoint')] = modelStub.responseForEndpoint(endpoint);
    }
    return acc;
  });

  return MockClient((req) async {
    final statusCode = _statusCodeForMethod(req.method);

    if (endpoints[req.url] != null) {
      return http.Response(endpoints[req.url]!, statusCode);
    }

    return http.Response('endpoint ${req.method} ${req.url} is not stubbed', 422);
  });
}

int _statusCodeForMethod(String method) {
  switch (method) {
    case 'GET':
      return 200;
    case 'POST':
      return 201;
    case 'DELETE':
      return 204;
    default:
      return 422;
  }
}
