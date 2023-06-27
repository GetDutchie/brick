import 'dart:convert';

import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:gql/language.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:logging/logging.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  sqfliteFfiInit();

  group('GraphqlRequestSqliteCache', () {
    const variables = {'hello': 'world'};
    final mutationRequest = Request(
      operation: Operation(document: parseString('''mutation {}'''), operationName: 'fakeMutate'),
      variables: variables,
    );

    final queryRequest = Request(
      operation: Operation(document: parseString('''query {}'''), operationName: 'fakeQuery'),
      variables: variables,
    );

    final mutResp = GraphqlRequestSqliteCache(mutationRequest);

    final queryResp = GraphqlRequestSqliteCache(queryRequest);

    final requestManager = GraphqlRequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
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

    test('#toSqlite', () {
      final instance = GraphqlRequestSqliteCache(queryRequest);
      final asSqlite = instance.toSqlite();
      expect(asSqlite, containsPair(GRAPHQL_JOBS_ATTEMPTS_COLUMN, 1));
      expect(asSqlite, containsPair(GRAPHQL_JOBS_CREATED_AT_COLUMN, isA<int>()));
      expect(asSqlite, containsPair(GRAPHQL_JOBS_DOCUMENT_COLUMN, isA<String>()));
      expect(asSqlite, containsPair(GRAPHQL_JOBS_OPERATION_NAME_COLUMN, 'fakeQuery'));
      expect(asSqlite, containsPair(GRAPHQL_JOBS_VARIABLES_COLUMN, isA<String>()));
      expect(asSqlite, containsPair(GRAPHQL_JOBS_UPDATED_AT, isA<int>()));
    });

    test('#delete', () async {
      final db = await requestManager.getDb();
      expect(await requestManager.unprocessedRequests(), isEmpty);
      await mutResp.insertOrUpdate(db);
      expect(await requestManager.unprocessedRequests(), isNotEmpty);
      await mutResp.delete(db);
      expect(await requestManager.unprocessedRequests(), isEmpty);
    });

    group('#insertOrUpdate', () {
      final logger = MockLogger();

      test('insert', () async {
        final uninserted = GraphqlRequestSqliteCache(queryRequest);
        final db = await requestManager.getDb();
        expect(await requestManager.unprocessedRequests(), isEmpty);
        await uninserted.insertOrUpdate(db, logger: logger);
        expect(await requestManager.unprocessedRequests(), isNotEmpty);
        verify(logger.fine(any));
      });

      test('update', () async {
        final db = await requestManager.getDb();
        await queryResp.insertOrUpdate(db);
        await queryResp.insertOrUpdate(db, logger: logger);
        final request = await requestManager.unprocessedRequests();
        verify(logger.warning(any));

        expect(request.first[GRAPHQL_JOBS_ATTEMPTS_COLUMN], 2);
      });
    });

    test('#unlock', () async {
      final logger = MockLogger();
      final uninserted = GraphqlRequestSqliteCache(queryRequest);
      final db = await requestManager.getDb();
      expect(await requestManager.unprocessedRequests(), isEmpty);
      await uninserted.insertOrUpdate(db, logger: logger);
      await uninserted.unlock(db);
      final request = await requestManager.unprocessedRequests();
      expect(request.first[GRAPHQL_JOBS_LOCKED_COLUMN], 0);
    });

    test('.lockRequest', () async {
      final uninserted = GraphqlRequestSqliteCache(queryRequest);
      final db = await requestManager.getDb();
      await uninserted.insertOrUpdate(db);
      final lockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
      await RequestSqliteCache.unlockRequest(
        data: lockedRequests.first,
        db: await requestManager.getDb(),
        lockedColumn: GRAPHQL_JOBS_LOCKED_COLUMN,
        primaryKeyColumn: GRAPHQL_JOBS_PRIMARY_KEY_COLUMN,
        tableName: GRAPHQL_JOBS_TABLE_NAME,
      );

      var requests = await requestManager.unprocessedRequests();
      expect(requests.first[GRAPHQL_JOBS_LOCKED_COLUMN], 0);
      await RequestSqliteCache.lockRequest(
        data: requests.first,
        db: await requestManager.getDb(),
        lockedColumn: GRAPHQL_JOBS_LOCKED_COLUMN,
        primaryKeyColumn: GRAPHQL_JOBS_PRIMARY_KEY_COLUMN,
        tableName: GRAPHQL_JOBS_TABLE_NAME,
      );

      requests = await requestManager.unprocessedRequests();
      expect(requests.first[GRAPHQL_JOBS_LOCKED_COLUMN], 1);
    });

    test('.toRequest', () {
      final request = GraphqlRequestSqliteCache(queryRequest).sqliteToRequest({
        GRAPHQL_JOBS_DOCUMENT_COLUMN: printNode(queryRequest.operation.document),
        GRAPHQL_JOBS_OPERATION_NAME_COLUMN: queryRequest.operation.operationName,
        GRAPHQL_JOBS_VARIABLES_COLUMN: jsonEncode(queryRequest.variables),
      });

      expect(request.operation.document, queryRequest.operation.document);
      expect(request.variables, variables);
      expect(request.operation.operationName, 'fakeQuery');
    });

    test('.unlockRequest', () async {
      final uninserted = GraphqlRequestSqliteCache(queryRequest);
      final db = await requestManager.getDb();
      await uninserted.insertOrUpdate(db);
      final requests = await requestManager.unprocessedRequests(onlyLocked: true);
      expect(requests, hasLength(1));
      await RequestSqliteCache.unlockRequest(
        data: requests.first,
        db: await requestManager.getDb(),
        lockedColumn: GRAPHQL_JOBS_LOCKED_COLUMN,
        primaryKeyColumn: GRAPHQL_JOBS_PRIMARY_KEY_COLUMN,
        tableName: GRAPHQL_JOBS_TABLE_NAME,
      );
      final newLockedRequests = await requestManager.unprocessedRequests(onlyLocked: true);
      expect(newLockedRequests, isEmpty);
    });
  });
}
