import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:logging/logging.dart';
import '../../lib/src/offline_queue/request_sqlite_cache.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('RequestSqliteCache', () {
    final getReq = http.Request('GET', Uri.parse('http://example.com'));
    final getResp = RequestSqliteCache(
      getReq,
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    final postReq = http.Request('POST', Uri.parse('http://example.com'));
    final postResp = RequestSqliteCache(
      postReq,
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    final putReq = http.Request('PUT', Uri.parse('http://example.com'));
    final putResp = RequestSqliteCache(
      putReq,
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    setUpAll(() async {
      final manager = RequestSqliteCacheManager(
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
      );

      await manager.migrate();
    });

    test('#requestIsPush', () {
      expect(getResp.requestIsPush, isFalse);
      expect(postResp.requestIsPush, isTrue);
      expect(putResp.requestIsPush, isTrue);
    });

    test('#toSqlite', () {
      final request = http.Request('GET', Uri.parse('http://example.com'));
      request.headers.addAll({'Content-Type': 'application/json'});
      final instance = RequestSqliteCache(
        request,
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
      );
      final asSqlite = instance.toSqlite();

      expect(asSqlite, containsPair(HTTP_JOBS_ATTEMPTS_COLUMN, 1));
      expect(asSqlite, containsPair(HTTP_JOBS_URL_COLUMN, 'http://example.com'));
      expect(
          asSqlite, containsPair(HTTP_JOBS_HEADERS_COLUMN, '{"Content-Type":"application/json"}'));
      expect(asSqlite, containsPair(HTTP_JOBS_UPDATED_AT, isA<int>()));
    });

    test('#delete', () async {
      await getResp.insertOrUpdate();
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
        final uninserted = RequestSqliteCache(
          uninsertedRequest,
          inMemoryDatabasePath,
          databaseFactory: databaseFactoryFfi,
        );

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
