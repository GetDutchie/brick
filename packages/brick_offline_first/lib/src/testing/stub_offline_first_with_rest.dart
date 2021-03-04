import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:brick_offline_first/src/testing/stub_offline_first_with_rest_model.dart';

class MockClient extends Mock implements http.Client {}

/// Manages multiple stubbed [OfflineFirstWithRestModel]s.
class StubOfflineFirstWithRest {
  @protected
  String get baseUrl => repository.remoteProvider.baseEndpoint;

  final List<StubOfflineFirstWithRestModel> modelStubs;

  final OfflineFirstWithRestRepository repository;

  static final client = MockClient();

  StubOfflineFirstWithRest({
    required this.modelStubs,
    required this.repository,
  });

  /// Invoked immediately after instantiation
  Future<void> initialize() async {
    await repository.migrate();
    repository.remoteProvider.client = StubOfflineFirstWithRest.client;
    forRest();
  }

  /// Stub a response
  void forRest({int statusCode = 200}) {
    for (final modelStub in modelStubs) {
      for (final endpoint in modelStub.endpoints) {
        when(StubOfflineFirstWithRest.client.get(Uri.parse('$baseUrl/$endpoint')))
            .thenAnswer((_) async => http.Response(modelStub.apiResponse, statusCode));

        when(StubOfflineFirstWithRest.client.post(Uri.parse('$baseUrl/$endpoint'),
                headers: anyNamed('headers'),
                body: anyNamed('body'),
                encoding: anyNamed('encoding')))
            .thenAnswer((_) async => http.Response(modelStub.apiResponse, 201));

        when(StubOfflineFirstWithRest.client
                .delete(Uri.parse('$baseUrl/$endpoint'), headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"status": "OK"}', 204));
      }
    }
  }
}
