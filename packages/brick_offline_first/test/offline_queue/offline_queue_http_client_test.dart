import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import '../../lib/src/offline_queue/offline_queue_http_client.dart';

class MockOfflineClient extends Mock implements OfflineQueueHttpClient {}

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("OfflineQueueHttpClient", () {
    var sqliteLogs = List<String>();

    setUpAll(() {
      MethodChannel('com.tekartik.sqflite').setMockMethodCallHandler((methodCall) async {
        if (methodCall.method == 'getDatabasesPath') {
          return Future.value('db');
        }

        if (methodCall.method == 'openDatabase') {
          return Future.value(null);
        }

        sqliteLogs.add(methodCall.arguments['sql']);
        if (methodCall.method == 'query') {
          if (methodCall.arguments['arguments'].contains("existing record")) {
            return Future.value([
              {'id': 1, 'attempts': 1}
            ]);
          }

          return Future.value([]);
        }

        if (methodCall.method == 'insert' || methodCall.method == 'update') {
          return 1;
        }

        return Future.value(null);
      });
    });

    tearDown(sqliteLogs.clear);

    test("#send forwards to inner client", () async {
      final inner = stubClient('hello from inner');
      final client = OfflineQueueHttpClient(inner, "test_db");

      final resp = await client.get('http://localhost:3000');
      expect(resp.body, 'hello from inner');
    });

    test("#send does not track GET requests", () async {
      final inner = stubClient();
      final client = OfflineQueueHttpClient(inner, "test_db");
      await client.get('http://localhost:3000');

      expect(sqliteLogs, isEmpty);
    });

    test("#send stores in SQLite", () async {
      final inner = stubClient();
      final client = OfflineQueueHttpClient(inner, "test_db");
      final resp = await client.post('http://localhost:3000', body: "new record");

      expect(
        sqliteLogs,
        contains(
          "INSERT INTO HttpJobs (attempts, body, encoding, headers, request_method, updated_at, url) VALUES (?, ?, ?, ?, ?, ?, ?)",
        ),
      );
      expect(resp.statusCode, 200);
    });

    test("#send increments and deletes for a successful request", () async {
      final inner = stubClient();
      final client = OfflineQueueHttpClient(inner, "test_db");
      final resp = await client.post('http://localhost:3000', body: "existing record");

      expect(
        sqliteLogs,
        containsAllInOrder([
          "UPDATE HttpJobs SET attempts = ?, updated_at = ?, locked = ? WHERE id = ?",
          "COMMIT",
          "BEGIN IMMEDIATE",
          "DELETE FROM HttpJobs WHERE id = ?",
        ]),
      );
      expect(resp.statusCode, 200);
    });

    test("#send creates and does not delete for an unsuccessful request", () async {
      final inner = MockClient();
      when(inner.send(any)).thenThrow(StateError('server not found'));

      final client = OfflineQueueHttpClient(inner, "test_db");
      final resp = await client.post('http://localhost:3000', body: "existing record");

      expect(
        sqliteLogs[sqliteLogs.length - 2],
        "UPDATE HttpJobs SET attempts = ?, updated_at = ?, locked = ? WHERE id = ?",
      );
      expect(resp.statusCode, 501);
    });

    test("#send does not delete for a missing endpoint", () async {
      final inner = MockClient();

      final client = OfflineQueueHttpClient(inner, "test_db");
      final resp = await client.post('http://localhost:3000', body: "existing record");

      expect(
        sqliteLogs[sqliteLogs.length - 2],
        "UPDATE HttpJobs SET attempts = ?, updated_at = ?, locked = ? WHERE id = ?",
      );
      expect(resp.statusCode, 501);
    });
  });
}

MockClient stubClient([String response = 'response']) {
  final inner = MockClient();

  when(inner.send(any)).thenAnswer((_) {
    return Future.value(_buildStreamedResponse(response));
  });

  return inner;
}

/// Useful for mocking a response to [http.Client]'s `#send` method
http.StreamedResponse _buildStreamedResponse(String response, [int statusCode = 200]) {
  final resp = http.Response(response, statusCode);
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
