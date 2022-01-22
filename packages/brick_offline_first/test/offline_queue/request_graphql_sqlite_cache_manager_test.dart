import 'package:brick_offline_first/src/offline_queue/offline_graphql_request_queue.dart';
import 'package:brick_offline_first/src/offline_queue/offline_queue_graphql_client.dart';
import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache_manager.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:test/test.dart';

void main() {
  final offlineClient = OfflineQueueGraphqlClient(
      Link.from([HttpLink("http://localhost:3000")]), RequestGraphqlSqliteCacheManager('db'));

  group('OfflineRequestQueue', () {
    test('#start', () {
      final queue = OfflineGraphqlRequestQueue(client: offlineClient);
      queue.start();
      expect(queue.isRunning, isTrue);
      queue.stop();
    });

    test('#stop', () {
      final queue = OfflineGraphqlRequestQueue(client: offlineClient);
      queue.start();
      expect(queue.isRunning, isTrue);
      queue.stop();
      expect(queue.isRunning, isFalse);
    });
  });
}
