import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:logging/logging.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('RequestSqliteCache', () {
    final getReq = http.Request('GET', Uri.parse('http://example.com'));
    final getResp = RequestSqliteCache(getReq);

    final postReq = http.Request('POST', Uri.parse('http://example.com'));
    final postResp = RequestSqliteCache(postReq);

    final putReq = http.Request('PUT', Uri.parse('http://example.com'));
    final putResp = RequestSqliteCache(putReq);

    final requestManager = RequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    setUpAll(() async {
      await requestManager.migrate();
    });

    tearDown(() async {
      final requests = await requestManager.unprocessedRequests();
      final requestsToDelete = requests.map((request) {
        return requestManager.deleteUnprocessedRequest(request[HTTP_JOBS_PRIMARY_KEY_COLUMN]);
      });

      await Future.wait(requestsToDelete);
    });

    test('#requestIsPush', () {
      expect(getResp.requestIsPush, isFalse);
      expect(postResp.requestIsPush, isTrue);
      expect(putResp.requestIsPush, isTrue);
    });

    test('#toSqlite', () {
      final request = http.Request('GET', Uri.parse('http://example.com'));
      request.headers.addAll({'Content-Type': 'application/json'});
      final instance = RequestSqliteCache(request);
      final asSqlite = instance.toSqlite();

      expect(asSqlite, containsPair(HTTP_JOBS_ATTEMPTS_COLUMN, 1));
      expect(asSqlite, containsPair(HTTP_JOBS_CREATED_AT_COLUMN, isA<int>()));
      expect(asSqlite, containsPair(HTTP_JOBS_URL_COLUMN, 'http://example.com'));
      expect(
          asSqlite, containsPair(HTTP_JOBS_HEADERS_COLUMN, '{"Content-Type":"application/json"}'));
      expect(asSqlite, containsPair(HTTP_JOBS_UPDATED_AT, isA<int>()));
      expect(asSqlite, containsPair(HTTP_JOBS_CREATED_AT_COLUMN, isA<int>()));
    });

    test('#delete', () async {
      final db = await requestManager.getDb();
      expect(await requestManager.unprocessedRequests(), isEmpty);
      await getResp.insertOrUpdate(db);
      expect(await requestManager.unprocessedRequests(), isNotEmpty);
      await getResp.delete(db);
      expect(await requestManager.unprocessedRequests(), isEmpty);
    });

    group('#insertOrUpdate', () {
      final logger = MockLogger();

      test('insert', () async {
        final uninsertedRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
        final uninserted = RequestSqliteCache(uninsertedRequest);
        final db = await requestManager.getDb();
        expect(await requestManager.unprocessedRequests(), isEmpty);
        await uninserted.insertOrUpdate(db, logger: logger);
        expect(await requestManager.unprocessedRequests(), isNotEmpty);
        verify(logger.fine(any));
      });

      test('update', () async {
        final db = await requestManager.getDb();
        await getResp.insertOrUpdate(db);
        await getResp.insertOrUpdate(db, logger: logger);
        final request = await requestManager.unprocessedRequests();
        verify(logger.warning(any));

        expect(request.first[HTTP_JOBS_ATTEMPTS_COLUMN], 2);
      });
    });

    group('.toRequest', () {
      test('basic', () {
        final request = RequestSqliteCache.sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'POST',
          HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000',
          HTTP_JOBS_BODY_COLUMN: 'POST body'
        });

        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://0.0.0.0:3000');
        expect(request.body, 'POST body');
      });

      test('missing headers', () {
        final request = RequestSqliteCache.sqliteToRequest(
            {HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET', HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000'});

        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://0.0.0.0:3000');
        expect(request.headers, {});
        expect(request.body, '');
      });

      test('with headers', () {
        final request = RequestSqliteCache.sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET',
          HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000',
          HTTP_JOBS_HEADERS_COLUMN: '{"Content-Type": "application/json"}'
        });

        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://0.0.0.0:3000');
        expect(request.headers, {'Content-Type': 'application/json'});
        expect(request.body, '');
      });
    });
  });
}
