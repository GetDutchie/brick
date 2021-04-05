import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '__helpers__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('RequestSqliteCacheManager', () {
    final requestManager = RequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      processingInterval: Duration(seconds: 0),
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
      final _requestManager = RequestSqliteCacheManager(
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        serialProcessing: false,
        processingInterval: Duration(seconds: 0),
      );
      final client = OfflineQueueHttpClient(inner, _requestManager);

      await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');
      await client.put(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');

      final request = await _requestManager.prepareNextRequestToProcess();
      expect(request!.method, 'POST');

      final asCacheItem = RequestSqliteCache(request);
      await asCacheItem.insertOrUpdate(await _requestManager.getDb());
      final req = await _requestManager.prepareNextRequestToProcess();
      expect(req!.method, 'PUT');
    });

    test('#prepareNextRequestToProcess', () async {
      final inner = stubResult(statusCode: 501);
      final client = OfflineQueueHttpClient(inner, requestManager);

      await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');
      await client.put(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');

      final request = await requestManager.prepareNextRequestToProcess();
      expect(request!.method, 'POST');

      final asCacheItem = RequestSqliteCache(request);
      await asCacheItem.insertOrUpdate(await requestManager.getDb());
      final req = await requestManager.prepareNextRequestToProcess();
      expect(req!.method, 'POST');
    });

    test('#deleteUnprocessedRequest', () async {
      final inner = stubResult(statusCode: 501);
      final client = OfflineQueueHttpClient(inner, requestManager);
      expect(await requestManager.unprocessedRequests(), isEmpty);

      await client.put(Uri.parse('http://0.0.0.0:3000/stored-query'), body: 'existing record');
      final unprocessedRequests = await requestManager.unprocessedRequests();
      expect(unprocessedRequests, hasLength(1));

      await requestManager
          .deleteUnprocessedRequest(unprocessedRequests[0][HTTP_JOBS_PRIMARY_KEY_COLUMN]);
      expect(await requestManager.unprocessedRequests(), isEmpty);
    });
  });
}
