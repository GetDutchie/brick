import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_queue_client.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_request_sqlite_cache.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '__helpers__.dart';

void main() {
  sqfliteFfiInit();

  group('RestRequestSqliteCacheManager', () {
    final requestManager = RestRequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      processingInterval: Duration.zero,
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

    test('#serialProcessing:false', () async {
      final inner = stubResult(statusCode: 501);
      final requestManager = RestRequestSqliteCacheManager(
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        serialProcessing: false,
        processingInterval: Duration.zero,
      );
      final client = RestOfflineQueueClient(inner, requestManager);

      await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');
      await client.put(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');

      final request = await requestManager.prepareNextRequestToProcess();
      expect(request!.method, 'POST');

      final asCacheItem = RestRequestSqliteCache(request);
      await asCacheItem.insertOrUpdate(await requestManager.getDb());
      final req = await requestManager.prepareNextRequestToProcess();
      expect(req?.method, 'PUT');
    });

    test('#deleteUnprocessedRequest', () async {
      final inner = stubResult(statusCode: 501);
      final client = RestOfflineQueueClient(inner, requestManager);
      expect(await requestManager.unprocessedRequests(), isEmpty);

      await client.put(Uri.parse('http://0.0.0.0:3000/stored-query'), body: 'existing record');
      final unprocessedRequests = await requestManager.unprocessedRequests();
      expect(unprocessedRequests, hasLength(1));

      await requestManager
          .deleteUnprocessedRequest(unprocessedRequests[0][HTTP_JOBS_PRIMARY_KEY_COLUMN]);
      expect(await requestManager.unprocessedRequests(), isEmpty);
    });

    group('#prepareNextRequestToProcess', () {
      test('integration', () async {
        final inner = stubResult(statusCode: 501);
        final client = RestOfflineQueueClient(inner, requestManager);

        await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');
        await client.put(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');

        final request = await requestManager.prepareNextRequestToProcess();
        expect(request?.method, 'POST');

        final asCacheItem = RestRequestSqliteCache(request!);
        await asCacheItem.insertOrUpdate(await requestManager.getDb());
        // Do not retry request if the row is locked and serial processing is active
        final req = await requestManager.prepareNextRequestToProcess();
        expect(req, isNull);
      });

      test('new request is locked and skipped', () async {
        final request = http.Request('POST', Uri.parse('http://localhost:3000/locked_request'));

        // prepare unlocked request
        final asCacheItem = RestRequestSqliteCache(request);
        await asCacheItem.insertOrUpdate(await requestManager.getDb());

        final requests = await requestManager.unprocessedRequests(onlyLocked: true);
        expect(requests, hasLength(1));

        final req = await requestManager.prepareNextRequestToProcess();
        expect(req, isNull);
      });

      test('unlocked request is locked', () async {
        final request = http.Request('POST', Uri.parse('http://localhost:3000/unlocked_request'));

        // prepare unlocked request
        final asCacheItem = RestRequestSqliteCache(request);
        await asCacheItem.insertOrUpdate(await requestManager.getDb());
        await asCacheItem.unlock(await requestManager.getDb());

        final requests = await requestManager.unprocessedRequests();
        expect(requests, hasLength(1));

        final lockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
        expect(lockedRequests, isEmpty);

        final req = await requestManager.prepareNextRequestToProcess();
        expect(req?.url, Uri.parse('http://localhost:3000/unlocked_request'));

        final newLockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
        expect(newLockedRequests, hasLength(1));
      });

      test('locked request older than 2 minutes is unlocked', () async {
        final request = http.Request('POST', Uri.parse('http://localhost:3000/old_request'));
        final db = await requestManager.getDb();
        // prepare unlocked request
        final asCacheItem = RestRequestSqliteCache(request);
        await asCacheItem.insertOrUpdate(await requestManager.getDb());
        expect(await requestManager.prepareNextRequestToProcess(), isNull);

        // ignore: invalid_use_of_protected_member
        final response = await asCacheItem.findRequestInDatabase(db);
        await db.update(
          HTTP_JOBS_TABLE_NAME,
          {
            HTTP_JOBS_UPDATED_AT:
                DateTime.now().subtract(const Duration(seconds: 122)).millisecondsSinceEpoch,
          },
          where: '$HTTP_JOBS_PRIMARY_KEY_COLUMN = ?',
          whereArgs: [response![HTTP_JOBS_PRIMARY_KEY_COLUMN]],
        );

        expect(await requestManager.unprocessedRequests(onlyLocked: true), hasLength(1));
        expect(await requestManager.unprocessedRequests(), hasLength(1));

        expect(await requestManager.prepareNextRequestToProcess(), isNull);

        final updatedReq = await requestManager.prepareNextRequestToProcess();
        expect(updatedReq?.url, Uri.parse('http://localhost:3000/old_request'));

        expect(await requestManager.unprocessedRequests(onlyLocked: true), hasLength(1));
      });
    });
  });
}
