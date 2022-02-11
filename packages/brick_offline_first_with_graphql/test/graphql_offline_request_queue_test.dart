import 'package:brick_offline_first_with_graphql/src/graphql_offline_queue_link.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_offline_request_queue.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final offlineClient = GraphqlOfflineQueueLink(
    GraphqlRequestSqliteCacheManager('db'),
  );

  group('GraphqlOfflineRequestQueue', () {
    test('#start', () {
      final queue = GraphqlOfflineRequestQueue(link: offlineClient);
      queue.start();
      expect(queue.isRunning, isTrue);
      queue.stop();
    });

    test('#stop', () {
      final queue = GraphqlOfflineRequestQueue(link: offlineClient);
      queue.start();
      expect(queue.isRunning, isTrue);
      queue.stop();
      expect(queue.isRunning, isFalse);
    });
  });
}
