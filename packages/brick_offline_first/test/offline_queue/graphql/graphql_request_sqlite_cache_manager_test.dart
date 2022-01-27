import 'package:brick_offline_first/src/offline_queue/graphql/graphql_offline_queue_link.dart';
import 'package:brick_offline_first/src/offline_queue/graphql/graphql_request_sqlite_cache.dart';
import 'package:brick_offline_first/src/offline_queue/graphql/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_offline_first/src/offline_queue/rest/rest_offline_queue_client.dart';
import 'package:brick_offline_first/src/offline_queue/rest/rest_request_sqlite_cache.dart';
import 'package:brick_offline_first/src/offline_queue/rest/rest_request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;
import 'package:gql/language.dart';
import '../__helpers__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('GraphqlRequestSqliteCacheManager', () {
    MockLink? mockLink;

    final requestManager = GraphqlRequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      processingInterval: const Duration(seconds: 0),
    );

    setUpAll(() async {
      mockLink = MockLink();
      await requestManager.migrate();
    });

    tearDown(() async {
      final requests = await requestManager.unprocessedRequests();
      final requestsToDelete = requests.map((request) {
        return requestManager.deleteUnprocessedRequest(request[GRAPHQL_JOBS_PRIMARY_KEY_COLUMN]);
      });

      await Future.wait(requestsToDelete);
    });

    test('#serialProcessing:false', () async {
      final _requestManager = GraphqlRequestSqliteCacheManager(
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        serialProcessing: false,
        processingInterval: const Duration(seconds: 0),
      );
      final client = GraphqlOfflineQueueLink(mockLink!, _requestManager);

      const query = '''mutation UpsertPerson {
        upsertPerson {
          firstName
        }
      }''';

      const mutation = '''mutation DeletePerson {
        deletePerson {
          firstName
        }
      }''';

      final request1 = Request(
        operation: Operation(document: parseString(query), operationName: 'UpsertPerson'),
        variables: const <String, dynamic>{'firstName': 'Beavis'},
      );

      final request2 = Request(
        operation: Operation(document: parseString(mutation), operationName: 'DeletePerson'),
        variables: const <String, dynamic>{'firstName': 'Beavis'},
      );

      await client.request(request1).first;
      await client.request(request2).first;

      final preparedNextRequest = await _requestManager.prepareNextRequestToProcess();
      expect(preparedNextRequest!.operation.operationName, 'UpsertPerson');

      final asCacheItem = GraphqlRequestSqliteCache(preparedNextRequest);
      await asCacheItem.insertOrUpdate(await _requestManager.getDb());
      final req = await _requestManager.prepareNextRequestToProcess();
      expect(req?.operation.operationName, 'DeletePerson');
    });

    // test('#deleteUnprocessedRequest', () async {
    //   final inner = stubResult(statusCode: 501);
    //   final client = RestOfflineQueueClient(inner, requestManager);
    //   expect(await requestManager.unprocessedRequests(), isEmpty);

    //   await client.put(Uri.parse('http://0.0.0.0:3000/stored-query'), body: 'existing record');
    //   final unprocessedRequests = await requestManager.unprocessedRequests();
    //   expect(unprocessedRequests, hasLength(1));

    //   await requestManager
    //       .deleteUnprocessedRequest(unprocessedRequests[0][GRAPHQL_JOBS_PRIMARY_KEY_COLUMN]);
    //   expect(await requestManager.unprocessedRequests(), isEmpty);
    // });

    // group('#prepareNextRequestToProcess', () {
    //   test('integration', () async {
    //     final inner = stubResult(statusCode: 501);
    //     final client = RestOfflineQueueClient(inner, requestManager);

    //     await client.post(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');
    //     await client.put(Uri.parse('http://0.0.0.0:3000'), body: 'existing record');

    //     final request = await requestManager.prepareNextRequestToProcess();
    //     expect(request?.method, 'POST');

    //     final asCacheItem = RestRequestSqliteCache(request!);
    //     await asCacheItem.insertOrUpdate(await requestManager.getDb());
    //     // Do not retry request if the row is locked and serial processing is active
    //     final req = await requestManager.prepareNextRequestToProcess();
    //     expect(req, isNull);
    //   });

    //   test('new request is locked and skipped', () async {
    //     final request = http.Request('POST', Uri.parse('http://localhost:3000/locked_request'));

    //     // prepare unlocked request
    //     final asCacheItem = RestRequestSqliteCache(request);
    //     await asCacheItem.insertOrUpdate(await requestManager.getDb());

    //     final requests = await requestManager.unprocessedRequests(onlyLocked: true);
    //     expect(requests, hasLength(1));

    //     final req = await requestManager.prepareNextRequestToProcess();
    //     expect(req, isNull);
    //   });

    //   test('unlocked request is locked', () async {
    //     final request = http.Request('POST', Uri.parse('http://localhost:3000/unlocked_request'));

    //     // prepare unlocked request
    //     final asCacheItem = RestRequestSqliteCache(request);
    //     await asCacheItem.insertOrUpdate(await requestManager.getDb());
    //     await asCacheItem.unlock(await requestManager.getDb());

    //     final requests = await requestManager.unprocessedRequests(onlyLocked: false);
    //     expect(requests, hasLength(1));

    //     final lockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
    //     expect(lockedRequests, isEmpty);

    //     final req = await requestManager.prepareNextRequestToProcess();
    //     expect(req?.url, Uri.parse('http://localhost:3000/unlocked_request'));

    //     final newLockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
    //     expect(newLockedRequests, hasLength(1));
    //   });

    //   test('locked request older than 2 minutes is unlocked', () async {
    //     final request = http.Request('POST', Uri.parse('http://localhost:3000/old_request'));
    //     final db = await requestManager.getDb();
    //     // prepare unlocked request
    //     final asCacheItem = RestRequestSqliteCache(request);
    //     await asCacheItem.insertOrUpdate(await requestManager.getDb());
    //     expect(await requestManager.prepareNextRequestToProcess(), isNull);

    //     // ignore: invalid_use_of_protected_member
    //     final response = await asCacheItem.findRequestInDatabase(db);
    //     await db.update(
    //       HTTP_JOBS_TABLE_NAME,
    //       {
    //         HTTP_JOBS_UPDATED_AT:
    //             DateTime.now().subtract(const Duration(seconds: 122)).millisecondsSinceEpoch,
    //       },
    //       where: '$GRAPHQL_JOBS_PRIMARY_KEY_COLUMN = ?',
    //       whereArgs: [response![GRAPHQL_JOBS_PRIMARY_KEY_COLUMN]],
    //     );

    //     expect(await requestManager.unprocessedRequests(onlyLocked: true), hasLength(1));
    //     expect(await requestManager.unprocessedRequests(onlyLocked: false), hasLength(1));

    //     expect(await requestManager.prepareNextRequestToProcess(), isNull);

    //     final updatedReq = await requestManager.prepareNextRequestToProcess();
    //     expect(updatedReq?.url, Uri.parse('http://localhost:3000/old_request'));

    //     expect(await requestManager.unprocessedRequests(onlyLocked: true), hasLength(1));
    //   });
    // });
  });
}
