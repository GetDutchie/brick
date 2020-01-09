import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import '../../lib/src/offline_queue/offline_request_queue.dart';
import '../../lib/src/offline_queue/offline_queue_http_client.dart';

class MockOfflineClient extends Mock implements OfflineQueueHttpClient {}

void main() {
  final offlineClient = MockOfflineClient();

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
