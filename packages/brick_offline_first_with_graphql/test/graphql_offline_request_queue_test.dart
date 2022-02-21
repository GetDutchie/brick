import 'package:brick_offline_first_with_graphql/src/graphql_offline_queue_link.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_offline_request_queue.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:test/test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final offlineClient = GraphqlOfflineQueueLink(
    GraphqlRequestSqliteCacheManager('db', databaseFactory: databaseFactoryFfi),
  );

  group('GraphqlOfflineRequestQueue', () {
    final requestManager = GraphqlRequestSqliteCacheManager(
      inMemoryDatabasePath,
      databaseFactory: databaseFactoryFfi,
    );

    test('#start', () {
      final queue = GraphqlOfflineRequestQueue(
        link: offlineClient,
        requestManager: requestManager,
      );
      queue.start();
      expect(queue.isRunning, isTrue);
      queue.stop();
    });

    test('#stop', () {
      final queue = GraphqlOfflineRequestQueue(
        link: offlineClient,
        requestManager: requestManager,
      );
      queue.start();
      expect(queue.isRunning, isTrue);
      queue.stop();
      expect(queue.isRunning, isFalse);
    });
  });
}
