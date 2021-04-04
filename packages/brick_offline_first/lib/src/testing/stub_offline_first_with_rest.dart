import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:http/testing.dart';
import 'package:brick_offline_first/src/testing/stub_offline_first_with_rest_model.dart';

/// Manages multiple stubbed [OfflineFirstWithRestModel]s.
class StubOfflineFirstWithRest {
  @protected
  String get baseUrl => repository.remoteProvider.baseEndpoint;

  final List<StubOfflineFirstWithRestModel> modelStubs;

  final OfflineFirstWithRestRepository repository;

  StubOfflineFirstWithRest({
    required this.modelStubs,
    required this.repository,
  });

  /// Invoked immediately after instantiation
  Future<void> initialize() async {
    await repository.migrate();
    repository.remoteProvider.client = restClient();
  }

  /// Stub REST responses
  MockClient restClient() {
    return MockClient((req) async {
      for (final modelStub in modelStubs) {
        for (final endpoint in modelStub.endpoints) {
          if (req.method == 'GET' && req.url == Uri.parse('$baseUrl/$endpoint')) {
            return http.Response(modelStub.apiResponse, 200);
          }

          if (req.method == 'POST' && req.url == Uri.parse('$baseUrl/$endpoint')) {
            return http.Response(modelStub.apiResponse, 201);
          }

          if (req.method == 'DELETE' && req.url == Uri.parse('$baseUrl/$endpoint')) {
            return http.Response('{"status": "OK"}', 204);
          }
        }
      }

      return http.Response('endpoint is not stubbed', 422);
    });
  }
}
