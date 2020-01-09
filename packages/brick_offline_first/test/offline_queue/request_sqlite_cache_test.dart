import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:logging/logging.dart';
import '../../lib/src/offline_queue/request_sqlite_cache.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  group("RequestSqliteCache", () {
    final getReq = http.Request("GET", Uri.parse("http://example.com"));
    final getResp = RequestSqliteCache(getReq, 'db');

    final postReq = http.Request("POST", Uri.parse("http://example.com"));
    final postResp = RequestSqliteCache(postReq, 'db');

    final putReq = http.Request("PUT", Uri.parse("http://example.com"));
    final putResp = RequestSqliteCache(putReq, 'db');
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
          if (methodCall.arguments['arguments'] != null &&
              methodCall.arguments['arguments'].contains('http://uninserted.com')) {
            return Future.value([]);
          }

          return Future.value([
            {
              HTTP_JOBS_REQUEST_METHOD_COLUMN: "PUT",
              HTTP_JOBS_URL_COLUMN: "http://localhost:3000/stored-query",
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

    test("#requestIsPush", () {
      expect(getResp.requestIsPush, isFalse);
      expect(postResp.requestIsPush, isTrue);
      expect(putResp.requestIsPush, isTrue);
    });

    test("#toSqlite", () {
      var request = http.Request("GET", Uri.parse("http://example.com"));
      request.headers.addAll({'Content-Type': 'application/json'});
      final instance = RequestSqliteCache(request, 'db');
      final asSqlite = instance.toSqlite();

      expect(asSqlite, containsPair(HTTP_JOBS_ATTEMPTS_COLUMN, 1));
      expect(asSqlite, containsPair(HTTP_JOBS_URL_COLUMN, 'http://example.com'));
      expect(
          asSqlite, containsPair(HTTP_JOBS_HEADERS_COLUMN, '{"Content-Type":"application/json"}'));
      expect(asSqlite, containsPair(HTTP_JOBS_UPDATED_AT, isA<int>()));
    });

    test("#delete", () async {
      await getResp.delete();

      expect(
        sqliteLogs,
        [
          "SELECT * FROM HttpJobs WHERE body = ? AND encoding = ? AND headers = ? AND request_method = ? AND url = ?",
          "BEGIN IMMEDIATE",
          "DELETE FROM HttpJobs WHERE id = ?",
          "COMMIT",
        ],
      );
    });

    group("#insertOrUpdate", () {
      final logger = MockLogger();

      test("insert", () async {
        final uninsertedRequest = http.Request("GET", Uri.parse("http://uninserted.com"));
        final uninserted = RequestSqliteCache(uninsertedRequest, 'db');

        await uninserted.insertOrUpdate(logger);

        verify(logger.fine(any));
        expect(
          sqliteLogs,
          [
            "SELECT * FROM HttpJobs WHERE body = ? AND encoding = ? AND headers = ? AND request_method = ? AND url = ?",
            "BEGIN IMMEDIATE",
            "INSERT INTO HttpJobs (attempts, body, encoding, headers, request_method, updated_at, url) VALUES (?, ?, ?, ?, ?, ?, ?)",
            "COMMIT",
          ],
        );
      });

      test("update", () async {
        await getResp.insertOrUpdate(logger);

        verify(logger.warning(any));
        expect(
          sqliteLogs,
          [
            "SELECT * FROM HttpJobs WHERE body = ? AND encoding = ? AND headers = ? AND request_method = ? AND url = ?",
            "BEGIN IMMEDIATE",
            "UPDATE HttpJobs SET attempts = ?, updated_at = ?, locked = ? WHERE id = ?",
            "COMMIT",
          ],
        );
      });
    });

    test(".migrate", () async {
      await RequestSqliteCache.migrate('fake_db');

      expect(sqliteLogs.first, contains("CREATE TABLE IF NOT EXISTS `HttpJobs`"));
      expect(sqliteLogs.first, contains("`id` INTEGER PRIMARY KEY AUTOINCREMENT,"));
      expect(sqliteLogs.first, contains("`updated_at` INTEGER DEFAULT 0,"));
    });

    test(".unprocessedRequests", () async {
      final requests = await RequestSqliteCache.unproccessedRequests('fake_db');
      expect(
        sqliteLogs,
        [
          "BEGIN IMMEDIATE",
          "UPDATE HttpJobs SET locked = 1 WHERE locked IN (SELECT DISTINCT locked FROM HttpJobs WHERE locked = 0 ORDER BY updated_at ASC LIMIT 1);",
          "SELECT DISTINCT * FROM HttpJobs WHERE locked = 1 ORDER BY updated_at ASC LIMIT 1;",
          "COMMIT"
        ],
      );

      expect(requests, isNotEmpty);
      expect(requests.first.method, "PUT");
      expect(requests.first.url.toString(), "http://localhost:3000/stored-query");
    });

    group(".toRequest", () {
      test("basic", () {
        final request = RequestSqliteCache.toRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'POST',
          HTTP_JOBS_URL_COLUMN: 'http://localhost:3000',
          HTTP_JOBS_BODY_COLUMN: 'POST body'
        });

        expect(request.method, "POST");
        expect(request.url.toString(), "http://localhost:3000");
        expect(request.body, 'POST body');
      });

      test("missing headers", () {
        final request = RequestSqliteCache.toRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET',
          HTTP_JOBS_URL_COLUMN: 'http://localhost:3000'
        });

        expect(request.method, "GET");
        expect(request.url.toString(), "http://localhost:3000");
        expect(request.headers, {});
        expect(request.body, '');
      });

      test("with headers", () {
        final request = RequestSqliteCache.toRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET',
          HTTP_JOBS_URL_COLUMN: 'http://localhost:3000',
          HTTP_JOBS_HEADERS_COLUMN: '{"Content-Type": "application/json"}'
        });

        expect(request.method, "GET");
        expect(request.url.toString(), "http://localhost:3000");
        expect(request.headers, {"Content-Type": "application/json"});
        expect(request.body, '');
      });
    });
  });
}
