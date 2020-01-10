import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:brick_offline_first/src/testing/stub_offline_first_with_rest_model.dart';
import 'package:brick_sqlite/testing.dart';

class MockClient extends Mock implements http.Client {}

/// Manages multiple stubbed [OfflineFirstWithRestModel]s.
class StubOfflineFirstWithRest {
  @protected
  String get baseUrl => repository?.remoteProvider?.baseEndpoint;

  final List<StubOfflineFirstWithRestModel> modelStubs;

  final OfflineFirstWithRestRepository repository;

  static final client = MockClient();

  /// Saves all logs for all tests in the current execution.
  /// Running `StubOfflineFirstWithRest.sqliteLogs.clear()` during `setUp`
  /// is advisable to ensure a clean test environment.
  static final sqliteLogs = List<MethodCall>();

  StubOfflineFirstWithRest({
    @required this.modelStubs,
    @required this.repository,
  }) {
    initialize();
  }

  /// Invoked immediately after instantiation
  void initialize() {
    repository?.remoteProvider?.client = StubOfflineFirstWithRest.client;
    forRest();
    forSqlite();
  }

  /// Stub a response
  void forRest({int statusCode = 200}) {
    for (final modelStub in modelStubs) {
      modelStub.endpoints.forEach((endpoint) {
        when(StubOfflineFirstWithRest.client.get('$baseUrl/$endpoint'))
            .thenAnswer((_) async => http.Response(modelStub.apiResponse, statusCode));

        when(StubOfflineFirstWithRest.client.post('$baseUrl/$endpoint',
                headers: anyNamed('headers'),
                body: anyNamed('body'),
                encoding: anyNamed('encoding')))
            .thenAnswer((_) async => http.Response(modelStub.apiResponse, 201));

        when(StubOfflineFirstWithRest.client
                .delete('$baseUrl/$endpoint', headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"status": "OK"}', 204));
      });
    }
  }

  void forSqlite() {
    StubSqlite.sqliteChannel.setMockMethodCallHandler((methodCall) async {
      sqliteLogs.add(methodCall);

      if (methodCall.method == 'getDatabasesPath') {
        return Future.value('db');
      }

      if (methodCall.method == 'openDatabase') {
        return Future.value(null);
      }

      for (final modelStub in modelStubs) {
        final isRelevantModel =
            StubSqlite.statementIncludesModel(modelStub.adapter.tableName, methodCall);
        if (isRelevantModel) {
          final responses = await modelStub.sqliteResponse();
          return StubSqlite.returnFromResponses(
            responses: responses,
            tableName: modelStub.adapter.tableName,
            methodCall: methodCall,
          );
        }
      }

      if (methodCall.method == 'delete') {
        return 0;
      }

      if (methodCall.method == 'insert' || methodCall.method == 'update') {
        return 1;
      }

      return [{}];
    });
  }
}
