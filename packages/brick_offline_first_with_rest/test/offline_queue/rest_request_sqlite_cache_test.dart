import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_request_sqlite_cache.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  sqfliteFfiInit();

  group('RestRequestSqliteCache', () {
    final getReq = http.Request('GET', Uri.parse('http://example.com'));
    final getResp = RestRequestSqliteCache(getReq);

    final postReq = http.Request('POST', Uri.parse('http://example.com'));
    final postResp = RestRequestSqliteCache(postReq);

    final putReq = http.Request('PUT', Uri.parse('http://example.com'));
    final putResp = RestRequestSqliteCache(putReq);

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
      final instance = RestRequestSqliteCache(request);
      final asSqlite = instance.toSqlite();

      expect(asSqlite, containsPair(HTTP_JOBS_ATTEMPTS_COLUMN, 1));
      expect(asSqlite, containsPair(HTTP_JOBS_CREATED_AT_COLUMN, isA<int>()));
      expect(asSqlite, containsPair(HTTP_JOBS_URL_COLUMN, 'http://example.com'));
      expect(
        asSqlite,
        containsPair(HTTP_JOBS_HEADERS_COLUMN, '{"Content-Type":"application/json"}'),
      );
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
        final uninserted = RestRequestSqliteCache(uninsertedRequest);
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
      final uninserted = RestRequestSqliteCache(uninsertedRequest);
      final db = await requestManager.getDb();
      expect(await requestManager.unprocessedRequests(), isEmpty);
      await uninserted.insertOrUpdate(db, logger: logger);
      await uninserted.unlock(db);
      final request = await requestManager.unprocessedRequests();
      expect(request.first[HTTP_JOBS_LOCKED_COLUMN], 0);
    });

    test('.lockRequest', () async {
      final uninsertedRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
      final uninserted = RestRequestSqliteCache(uninsertedRequest);
      final db = await requestManager.getDb();
      await uninserted.insertOrUpdate(db);
      final lockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
      await RequestSqliteCache.unlockRequest(
        data: lockedRequests.first,
        db: await requestManager.getDb(),
        lockedColumn: HTTP_JOBS_LOCKED_COLUMN,
        primaryKeyColumn: HTTP_JOBS_PRIMARY_KEY_COLUMN,
        tableName: HTTP_JOBS_TABLE_NAME,
      );

      var requests = await requestManager.unprocessedRequests();
      expect(requests.first[HTTP_JOBS_LOCKED_COLUMN], 0);
      await RequestSqliteCache.lockRequest(
        data: requests.first,
        db: await requestManager.getDb(),
        lockedColumn: HTTP_JOBS_LOCKED_COLUMN,
        primaryKeyColumn: HTTP_JOBS_PRIMARY_KEY_COLUMN,
        tableName: HTTP_JOBS_TABLE_NAME,
      );

      requests = await requestManager.unprocessedRequests();
      expect(requests.first[HTTP_JOBS_LOCKED_COLUMN], 1);
    });
    group('.toRequest', () {
      test('basic', () {
        final tempRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
        final request = RestRequestSqliteCache(tempRequest).sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'POST',
          HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000',
          HTTP_JOBS_BODY_COLUMN: 'POST body',
        });

        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://0.0.0.0:3000');
        expect(request.body, 'POST body');
      });

      test('missing headers', () {
        final tempRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
        final request = RestRequestSqliteCache(tempRequest).sqliteToRequest(
          {HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET', HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000'},
        );

        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://0.0.0.0:3000');
        expect(request.headers, {});
        expect(request.body, '');
      });

      test('with headers', () {
        final tempRequest = http.Request('GET', Uri.parse('http://uninserted.com'));

        final request = RestRequestSqliteCache(tempRequest).sqliteToRequest({
          HTTP_JOBS_REQUEST_METHOD_COLUMN: 'GET',
          HTTP_JOBS_URL_COLUMN: 'http://0.0.0.0:3000',
          HTTP_JOBS_HEADERS_COLUMN: '{"Content-Type": "application/json"}',
        });

        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://0.0.0.0:3000');
        expect(request.headers, {'Content-Type': 'application/json'});
        expect(request.body, '');
      });
    });

    test('.unlockRequest', () async {
      final uninsertedRequest = http.Request('GET', Uri.parse('http://uninserted.com'));
      final uninserted = RestRequestSqliteCache(uninsertedRequest);
      final db = await requestManager.getDb();
      await uninserted.insertOrUpdate(db);
      final requests = await requestManager.unprocessedRequests(onlyLocked: true);
      expect(requests, hasLength(1));
      await RequestSqliteCache.unlockRequest(
        data: requests.first,
        db: await requestManager.getDb(),
        lockedColumn: HTTP_JOBS_LOCKED_COLUMN,
        primaryKeyColumn: HTTP_JOBS_PRIMARY_KEY_COLUMN,
        tableName: HTTP_JOBS_TABLE_NAME,
      );
      final newLockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
      expect(newLockedRequests, isEmpty);
    });
  });
}
