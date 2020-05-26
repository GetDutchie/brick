import 'package:test/test.dart';
import 'package:brick_offline_first/src/offline_queue/offline_request_queue.dart';
import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';

import '__helpers__.dart';

void main() {
  final offlineClient = OfflineQueueHttpClient(MockClient(), RequestSqliteCacheManager('db'));

  group("OfflineRequestQueue", () {
    test("#start", () {
      final queue = OfflineRequestQueue(client: offlineClient);
      queue.start();
      expect(queue.isRunning, isTrue);
      queue.stop();
    });

    test("#stop", () {
      final queue = OfflineRequestQueue(client: offlineClient);
      queue.start();
      expect(queue.isRunning, isTrue);
      queue.stop();
      expect(queue.isRunning, isFalse);
    });
  });
}
