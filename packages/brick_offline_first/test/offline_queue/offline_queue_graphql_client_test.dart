import 'package:brick_offline_first/src/offline_queue/offline_queue_graphql_client.dart';
import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gql/language.dart';
import '__helpers__.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('OfflineQueueGraphqlClient', () {
    final requestManager = RequestGraphqlSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    setUpAll(() async {
      await requestManager.migrate();
    });

    tearDown(() async {
      final requests = await requestManager.unprocessedRequests();
      final requestsToDelete = requests.map((request) {
        return requestManager.deleteUnprocessedRequest(request[GRAPHQL_JOB_PRIMARY_KEY_COLUMN]);
      });

      await Future.wait(requestsToDelete);
    });

    test('#verify link request made', () async {
      final mockLink = MockLink();
      final client = OfflineQueueGraphqlClient(mockLink, requestManager);

      await client
          .request(
            Request(
              operation: Operation(
                document: parseString(""""""),
              ),
              variables: const <String, dynamic>{"i": 12},
            ),
          )
          .first;

      verify(
        mockLink.request(
          Request(
            operation: Operation(
              document: parseString(""""""),
            ),
            variables: const <String, dynamic>{"i": 12},
          ),
          null,
        ),
      ).called(1);
    });
  });

  test('#send forwards to inner client', () async {}, skip: 'Needs to be implemented');

  test('requests are not tracked', () async {}, skip: 'Needs to be implemented');

  test('request is stored in SQLite', () async {}, skip: 'Needs to be implemented');

  test('request deletes after a successful response', () async {}, skip: 'Needs to be implemented');

  test('request increments after a unsuccessful response', () async {},
      skip: 'Needs to be implemented');

  test('request creates and does not delete after an unsuccessful response', () async {},
      skip: 'Needs to be implemented');

  test('request is not deleted after sending to a misconfigured client', () async {},
      skip: 'Needs to be implemented');

  test('request is not deleted after sending to an inaccessible endpoint', () async {},
      skip: 'Needs to be implemented');

  test('request is not deleted after receiving a status code that should be reattempted',
      () async {},
      skip: 'Needs to be implemented');

  test('.areGraphwlErrorsEmpty', () async {}, skip: 'Needs to be implemented');
}
