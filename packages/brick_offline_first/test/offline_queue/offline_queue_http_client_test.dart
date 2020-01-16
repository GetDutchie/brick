import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import '../../lib/src/offline_queue/offline_queue_http_client.dart';

class MockOfflineClient extends Mock implements OfflineQueueHttpClient {}

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineQueueHttpClient', () {
    var sqliteLogs = List<String>();
    const SQLITE_INSERT_STATEMENT =
        'INSERT INTO HttpJobs (attempts, body, encoding, headers, request_method, updated_at, url) VALUES (?, ?, ?, ?, ?, ?, ?)';
    const SQLITE_UPDATE_STATEMENT =
        'UPDATE HttpJobs SET attempts = ?, updated_at = ?, locked = ? WHERE id = ?';

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
          if (methodCall.arguments['arguments'].contains('existing record')) {
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

    test('#send forwards to inner client', () async {
      final inner = stubResult(response: 'hello from inner');
      final client = OfflineQueueHttpClient(inner, 'test_db');

      final resp = await client.get('http://localhost:3000');
      expect(resp.body, 'hello from inner');
    });

    test('GET requests are not tracked', () async {
      final inner = stubResult();
      final client = OfflineQueueHttpClient(inner, 'test_db');
      await client.get('http://localhost:3000');

      expect(sqliteLogs, isEmpty);
    });

    test('request is stored in SQLite', () async {
      final inner = stubResult();
      final client = OfflineQueueHttpClient(inner, 'test_db');
      final resp = await client.post('http://localhost:3000', body: 'new record');

      expect(
        sqliteLogs,
        contains(SQLITE_INSERT_STATEMENT),
      );
      expect(resp.statusCode, 200);
    });

    test('request increments and deletes after a successful response', () async {
      final inner = stubResult(requestBody: 'existing record');
      final client = OfflineQueueHttpClient(inner, 'test_db');
      final resp = await client.post('http://localhost:3000', body: 'existing record');

      expect(
        sqliteLogs,
        containsAllInOrder([
          SQLITE_UPDATE_STATEMENT,
          'COMMIT',
          'BEGIN IMMEDIATE',
          'DELETE FROM HttpJobs WHERE id = ?',
        ]),
      );
      expect(resp.statusCode, 200);
    });

    test('request creates and does not delete after an unsuccessful response', () async {
      final inner = MockClient();
      when(inner.send(any)).thenThrow(StateError('server not found'));

      final client = OfflineQueueHttpClient(inner, 'test_db');
      final resp = await client.post('http://localhost:3000', body: 'existing record');

      expect(sqliteLogs[sqliteLogs.length - 2], SQLITE_UPDATE_STATEMENT);
      expect(resp.statusCode, 501);
    });

    test('request is not deleted after sending to a misconfigured client', () async {
      final inner = MockClient();

      final client = OfflineQueueHttpClient(inner, 'test_db');
      final resp = await client.post('http://localhost:3000', body: 'existing record');

      expect(sqliteLogs[sqliteLogs.length - 2], SQLITE_UPDATE_STATEMENT);
      expect(resp.statusCode, 501);
    });

    test('request is not deleted after sending to an inaccessible endpoint', () async {
      final body = 'Tunnel http://localhost:3000 not found';
      final inner = stubResult(response: body, statusCode: 404);
      final client = OfflineQueueHttpClient(inner, 'test_db');

      final resp = await client.post('http://localhost:3000', body: 'new record');
      expect(sqliteLogs[sqliteLogs.length - 2], SQLITE_INSERT_STATEMENT);
      expect(resp.statusCode, 404);
      expect(resp.body, body);

      await client.put('http://localhost:3000', body: 'new record');
      expect(sqliteLogs[sqliteLogs.length - 2], SQLITE_INSERT_STATEMENT);

      await client.delete('http://localhost:3000');
      expect(sqliteLogs[sqliteLogs.length - 2], SQLITE_INSERT_STATEMENT);

      await client.patch('http://localhost:3000', body: 'new record');
      expect(sqliteLogs[sqliteLogs.length - 2], SQLITE_INSERT_STATEMENT);
    });
  });
}

MockClient stubResult({String response = 'response', int statusCode, String requestBody}) {
  final inner = MockClient();

  when(inner.send(any)).thenAnswer((_) {
    return Future.value(_buildStreamedResponse(response, statusCode, requestBody));
  });

  return inner;
}

/// Useful for mocking a response to [http.Client]'s `#send` method
http.StreamedResponse _buildStreamedResponse(String response,
    [int statusCode, String requestBody]) {
  statusCode ??= 200;

  // args don't matter,
  final request = http.Request("POST", Uri.parse("http://localhost:3000"));
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
