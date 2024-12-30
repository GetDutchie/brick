import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_queue_client.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_request_queue.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '__helpers__.dart';

void main() {
  final offlineClient = RestOfflineQueueClient(
    stubResult(),
    RestRequestSqliteCacheManager(
      'db',
      databaseFactory: databaseFactoryFfi,
    ),
  );

  group('RestOfflineRequestQueue', () {
    test('#start', () {
      final queue = RestOfflineRequestQueue(client: offlineClient)..start();
      expect(queue.isRunning, isTrue);
      queue.stop();
    });

    test('#stop', () {
      final queue = RestOfflineRequestQueue(client: offlineClient)..start();
      expect(queue.isRunning, isTrue);
      queue.stop();
      expect(queue.isRunning, isFalse);
    });
  });
}
