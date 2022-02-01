import 'package:brick_offline_first_with_graphql/src/graphql_offline_queue_link.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql/language.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../__helpers__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('GraphqlRequestSqliteCacheManager', () {
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

    final deleteMutation = Request(
      operation: Operation(document: parseString(mutation), operationName: 'DeletePerson'),
      variables: const <String, dynamic>{'firstName': 'Guy'},
    );

    final upsertMutation = Request(
      operation: Operation(document: parseString(query), operationName: 'UpsertPerson'),
      variables: const <String, dynamic>{'firstName': 'Guy'},
    );

    final requestManager = GraphqlRequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
      processingInterval: const Duration(seconds: 0),
    );

    setUpAll(() async {
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
      final client = GraphqlOfflineQueueLink(
        stubGraphqlLink({}, errors: ['Unable to connect']),
        _requestManager,
      );

      await client.request(upsertMutation).first;
      await client.request(deleteMutation).first;

      final preparedNextRequest = await _requestManager.prepareNextRequestToProcess();
      expect(preparedNextRequest!.operation.operationName, 'UpsertPerson');

      final asCacheItem = GraphqlRequestSqliteCache(preparedNextRequest);
      await asCacheItem.insertOrUpdate(await _requestManager.getDb());
      final req = await _requestManager.prepareNextRequestToProcess();
      expect(req?.operation.operationName, 'DeletePerson');
    });

    test('#deleteUnprocessedRequest', () async {
      final client = GraphqlOfflineQueueLink(
        stubGraphqlLink({}, errors: ['Unable to connect']),
        requestManager,
      );
      expect(await requestManager.unprocessedRequests(), isEmpty);

      await client.request(upsertMutation).first;
      final unprocessedRequests = await requestManager.unprocessedRequests();
      expect(unprocessedRequests, hasLength(1));

      await requestManager
          .deleteUnprocessedRequest(unprocessedRequests[0][GRAPHQL_JOBS_PRIMARY_KEY_COLUMN]);
      expect(await requestManager.unprocessedRequests(), isEmpty);
    });

    group('#prepareNextRequestToProcess', () {
      test('integration', () async {
        final client = GraphqlOfflineQueueLink(
          stubGraphqlLink({}, errors: ['Unable to connect']),
          requestManager,
        );

        await client.request(upsertMutation).first;
        await client.request(deleteMutation).first;

        final request = await requestManager.prepareNextRequestToProcess();
        expect(request?.operation.operationName, 'UpsertPerson');

        final asCacheItem = GraphqlRequestSqliteCache(request!);
        await asCacheItem.insertOrUpdate(await requestManager.getDb());
        // Do not retry request if the row is locked and serial processing is active
        final req = await requestManager.prepareNextRequestToProcess();
        expect(req, isNull);
      });

      test('new request is locked and skipped', () async {
        final request = Request(
            operation: Operation(
          document: parseString(
            '''mutation {}''',
          ),
          operationName: 'lockedUp',
        ));

        // prepare unlocked request
        final asCacheItem = GraphqlRequestSqliteCache(request);
        await asCacheItem.insertOrUpdate(await requestManager.getDb());

        final requests = await requestManager.unprocessedRequests(onlyLocked: true);
        expect(requests, hasLength(1));

        final req = await requestManager.prepareNextRequestToProcess();
        expect(req, isNull);
      });

      test('unlocked request is locked', () async {
        final request = Request(
            operation: Operation(
          document: parseString(
            '''mutation {}''',
          ),
          operationName: 'unlocked',
        ));

        // prepare unlocked request
        final asCacheItem = GraphqlRequestSqliteCache(request);
        await asCacheItem.insertOrUpdate(await requestManager.getDb());
        await asCacheItem.unlock(await requestManager.getDb());

        final requests = await requestManager.unprocessedRequests(onlyLocked: false);
        expect(requests, hasLength(1));

        final lockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
        expect(lockedRequests, isEmpty);

        final req = await requestManager.prepareNextRequestToProcess();
        expect(req?.operation.operationName, 'unlocked');

        final newLockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
        expect(newLockedRequests, hasLength(1));
      });

      test('locked request older than 2 minutes is unlocked', () async {
        final request = Request(
            operation: Operation(
          document: parseString(
            '''mutation {}''',
          ),
          operationName: 'unlocked',
        ));
        final db = await requestManager.getDb();
        // prepare unlocked request
        final asCacheItem = GraphqlRequestSqliteCache(request);
        await asCacheItem.insertOrUpdate(await requestManager.getDb());
        expect(await requestManager.prepareNextRequestToProcess(), isNull);

        // ignore: invalid_use_of_protected_member
        final response = await asCacheItem.findRequestInDatabase(db);
        await db.update(
          GRAPHQL_JOBS_TABLE_NAME,
          {
            GRAPHQL_JOBS_UPDATED_AT:
                DateTime.now().subtract(const Duration(seconds: 122)).millisecondsSinceEpoch,
          },
          where: '$GRAPHQL_JOBS_PRIMARY_KEY_COLUMN = ?',
          whereArgs: [response![GRAPHQL_JOBS_PRIMARY_KEY_COLUMN]],
        );

        expect(await requestManager.unprocessedRequests(onlyLocked: true), hasLength(1));
        expect(await requestManager.unprocessedRequests(onlyLocked: false), hasLength(1));

        expect(await requestManager.prepareNextRequestToProcess(), isNull);

        final updatedReq = await requestManager.prepareNextRequestToProcess();
        expect(updatedReq?.operation.operationName, 'unlocked');

        expect(await requestManager.unprocessedRequests(onlyLocked: true), hasLength(1));
      });
    });
  });
}
