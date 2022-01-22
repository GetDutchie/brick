import 'package:brick_offline_first/src/offline_queue/offline_graphql_request_queue.dart';
import 'package:brick_offline_first/src/offline_queue/offline_queue_graphql_client.dart';
import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache_manager.dart';
import 'package:brick_offline_first/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';
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

      final resp = await client
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
}
