import 'package:brick_offline_first/src/offline_queue/rest_request_sqlite_cache.dart';
import 'package:brick_offline_first/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('RequestSqliteCache', () {
    final getReq = http.Request('GET', Uri.parse('http://example.com'));
    final getResp = RestRequestSqliteCache(request: getReq);

    final postReq = http.Request('POST', Uri.parse('http://example.com'));
    final postResp = RestRequestSqliteCache(request: postReq);

    final putReq = http.Request('PUT', Uri.parse('http://example.com'));
    final putResp = RestRequestSqliteCache(request: putReq);

    final requestManager = RestRequestSqliteCacheManager(
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
      final instance = RestRequestSqliteCache(request: request);
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
        final uninserted = RestRequestSqliteCache(request: uninsertedRequest);
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

    test('#unlock', () async {
      final logger = MockLogger();
      final uninsertedRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
      final uninserted = RestRequestSqliteCache(request: uninsertedRequest);
      final db = await requestManager.getDb();
      expect(await requestManager.unprocessedRequests(), isEmpty);
      await uninserted.insertOrUpdate(db, logger: logger);
      await uninserted.unlock(db);
      final request = await requestManager.unprocessedRequests();
      expect(request.first[HTTP_JOBS_LOCKED_COLUMN], 0);
    });

    test('.lockRequest', () async {
      final uninsertedRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
      final uninserted = RestRequestSqliteCache(request: uninsertedRequest);
      final db = await requestManager.getDb();
      await uninserted.insertOrUpdate(db);
      final lockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
      await uninserted.unlockRequest(lockedRequests.first, await requestManager.getDb());

      var requests = await requestManager.unprocessedRequests();
      expect(requests.first[HTTP_JOBS_LOCKED_COLUMN], 0);
      await uninserted.lockRequest(requests.first, await requestManager.getDb());

      requests = await requestManager.unprocessedRequests();
      expect(requests.first[HTTP_JOBS_LOCKED_COLUMN], 1);
    });
    group('.toRequest', () {
      test('basic', () {
        final request = http.Request('GET', Uri.parse('http://localhost:3000'));
        final sqliteCache = RestRequestSqliteCache(request: request);
        final result = sqliteCache.sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'POST',
          HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000',
          HTTP_JOBS_BODY_COLUMN: 'POST body'
        });

        expect(result.method, 'POST');
        expect(result.url.toString(), 'http://0.0.0.0:3000');
        expect(result.body, 'POST body');
      });

      test('missing headers', () {
        final request = http.Request('GET', Uri.parse('http://localhost:3000'));
        final sqliteCache = RestRequestSqliteCache(request: request);
        final result = sqliteCache.sqliteToRequest(
            {HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET', HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000'});

        expect(result.method, 'GET');
        expect(result.url.toString(), 'http://0.0.0.0:3000');
        expect(result.headers, {});
        expect(result.body, '');
      });

      test('with headers', () {
        final request = http.Request('GET', Uri.parse('http://localhost:3000'));
        final sqliteCache = RestRequestSqliteCache(request: request);
        final result = sqliteCache.sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET',
          HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000',
          HTTP_JOBS_HEADERS_COLUMN: '{"Content-Type": "application/json"}'
        });

        expect(result.method, 'GET');
        expect(result.url.toString(), 'http://0.0.0.0:3000');
        expect(result.headers, {'Content-Type': 'application/json'});
        expect(result.body, '');
      });
    });

    test('.unlockRequest', () async {
      final uninsertedRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
      final uninserted = RestRequestSqliteCache(request: uninsertedRequest);
      final db = await requestManager.getDb();
      await uninserted.insertOrUpdate(db);
      final requests = await requestManager.unprocessedRequests(onlyLocked: true);
      expect(requests, hasLength(1));
      await uninserted.unlockRequest(requests.first, await requestManager.getDb());
      final newLockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
      expect(newLockedRequests, isEmpty);
    });
  });
}
