import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:logging/logging.dart';
import '../../lib/src/offline_queue/request_sqlite_cache.dart';
import '../../lib/src/offline_queue/request_sqlite_cache_manager.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RequestSqliteCache', () {
    final getReq = http.Request('GET', Uri.parse('http://example.com'));
    final getResp = RequestSqliteCache(getReq, 'db');

    final postReq = http.Request('POST', Uri.parse('http://example.com'));
    final postResp = RequestSqliteCache(postReq, 'db');

    final putReq = http.Request('PUT', Uri.parse('http://example.com'));
    final putResp = RequestSqliteCache(putReq, 'db');
    var sqliteLogs = <String>[];

    setUpAll(() {
      const MethodChannel('com.tekartik.sqflite').setMockMethodCallHandler((methodCall) async {
        if (methodCall.method == 'getDatabasesPath') {
          return Future.value('db');
        }

        if (methodCall.method == 'openDatabase') {
          return Future.value(null);
        }

        sqliteLogs.add(methodCall.arguments['sql']);
        if (methodCall.method == 'query') {
          if (methodCall.arguments['arguments'] != null &&
              methodCall.arguments['arguments'].contains('http://uninserted.com')) {
            return Future.value([]);
          }

          return Future.value([
            {
              HTTP_JOBS_REQUEST_METHOD_COLUMN: 'PUT',
              HTTP_JOBS_URL_COLUMN: 'http://localhost:3000/stored-query',
              HTTP_JOBS_ATTEMPTS_COLUMN: 1,
            }
          ]);
        }

        if (methodCall.method == 'insert' || methodCall.method == 'update') {
          return 1;
        }

        return Future.value(null);
      });
    });

    tearDown(sqliteLogs.clear);

    test('#requestIsPush', () {
      expect(getResp.requestIsPush, isFalse);
      expect(postResp.requestIsPush, isTrue);
      expect(putResp.requestIsPush, isTrue);
    });

    test('#toSqlite', () {
      final request = http.Request('GET', Uri.parse('http://example.com'));
      request.headers.addAll({'Content-Type': 'application/json'});
      final instance = RequestSqliteCache(request, 'db');
      final asSqlite = instance.toSqlite();

      expect(asSqlite, containsPair(HTTP_JOBS_ATTEMPTS_COLUMN, 1));
      expect(asSqlite, containsPair(HTTP_JOBS_CREATED_AT_COLUMN, isA<int>()));
      expect(asSqlite, containsPair(HTTP_JOBS_URL_COLUMN, 'http://example.com'));
      expect(
          asSqlite, containsPair(HTTP_JOBS_HEADERS_COLUMN, '{"Content-Type":"application/json"}'));
      expect(asSqlite, containsPair(HTTP_JOBS_UPDATED_AT, isA<int>()));
    });

    test('#delete', () async {
      await getResp.delete();

      expect(
        sqliteLogs,
        [
          'SELECT * FROM HttpJobs WHERE body = ? AND encoding = ? AND headers = ? AND request_method = ? AND url = ?',
          'BEGIN IMMEDIATE',
          'DELETE FROM HttpJobs WHERE id = ?',
          'COMMIT',
        ],
      );
    });

    group('#insertOrUpdate', () {
      final logger = MockLogger();

      test('insert', () async {
        final uninsertedRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
        final uninserted = RequestSqliteCache(uninsertedRequest, 'db');

        await uninserted.insertOrUpdate(logger);

        verify(logger.fine(any));
        expect(
          sqliteLogs,
          [
            'SELECT * FROM HttpJobs WHERE body = ? AND encoding = ? AND headers = ? AND request_method = ? AND url = ?',
            'BEGIN IMMEDIATE',
            'INSERT INTO HttpJobs (attempts, body, encoding, headers, request_method, updated_at, url) VALUES (?, ?, ?, ?, ?, ?, ?)',
            'COMMIT',
          ],
        );
      });

      test('update', () async {
        await getResp.insertOrUpdate(logger);

        verify(logger.warning(any));
        expect(
          sqliteLogs,
          [
            'SELECT * FROM HttpJobs WHERE body = ? AND encoding = ? AND headers = ? AND request_method = ? AND url = ?',
            'BEGIN IMMEDIATE',
            'UPDATE HttpJobs SET attempts = ?, updated_at = ?, locked = ? WHERE id = ?',
            'COMMIT',
          ],
        );
      });
    });

    group('.toRequest', () {
      test('basic', () {
        final request = RequestSqliteCache.sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'POST',
          HTTP_JOBS_URL_COLUMN: 'http://localhost:3000',
          HTTP_JOBS_BODY_COLUMN: 'POST body'
        });

        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://localhost:3000');
        expect(request.body, 'POST body');
      });

      test('missing headers', () {
        final request = RequestSqliteCache.sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET',
          HTTP_JOBS_URL_COLUMN: 'http://localhost:3000'
        });

        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://localhost:3000');
        expect(request.headers, {});
        expect(request.body, '');
      });

      test('with headers', () {
        final request = RequestSqliteCache.sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET',
          HTTP_JOBS_URL_COLUMN: 'http://localhost:3000',
          HTTP_JOBS_HEADERS_COLUMN: '{"Content-Type": "application/json"}'
        });

        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://localhost:3000');
        expect(request.headers, {'Content-Type': 'application/json'});
        expect(request.body, '');
      });
    });
  });
}
