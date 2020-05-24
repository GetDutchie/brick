import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/offline_queue/request_sqlite_cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RequestSqliteCacheManager', () {
    var sqliteLogs = <String>[];

    setUpAll(() {
      const MethodChannel('com.tekartik.sqflite').setMockMethodCallHandler((methodCall) async {
        if (methodCall.method == 'getDatabasesPath') {
          return Future.value('db');
        }

        if (methodCall.method == 'openDatabase') {
          return Future.value(null);
        }

        sqliteLogs.add(methodCall.arguments['sql']);
        if (methodCall.method == 'query') {
          return Future.value([
            {
              HTTP_JOBS_REQUEST_METHOD_COLUMN: 'PUT',
              HTTP_JOBS_URL_COLUMN: 'http://localhost:3000/stored-query',
              HTTP_JOBS_ATTEMPTS_COLUMN: 1,
              HTTP_JOBS_PRIMARY_KEY_COLUMN: 1,
            }
          ]);
        }

        if (methodCall.method == 'update' && methodCall.arguments['sql'].startsWith('DELETE')) {
          return 1;
        }

        return Future.value(null);
      });
    });

    tearDown(sqliteLogs.clear);

    test('#serialProcessing:false', () async {
      final manager = RequestSqliteCacheManager('fake_db', serialProcessing: false);
      await manager.prepareNextRequestToProcess();
      expect(sqliteLogs[0], 'BEGIN IMMEDIATE');
      expect(
          sqliteLogs[1],
          startsWith(
              'UPDATE HttpJobs SET locked = 1 WHERE locked IN (SELECT DISTINCT locked FROM HttpJobs WHERE locked = 0 AND created_at <'));
      expect(sqliteLogs[1], endsWith('ORDER BY updated_at ASC);'));
      expect(sqliteLogs[2],
          startsWith('SELECT DISTINCT * FROM HttpJobs WHERE locked = 1 AND created_at <'));
      expect(sqliteLogs[2], endsWith('ORDER BY updated_at ASC LIMIT 1;'));
      expect(sqliteLogs[3], 'COMMIT');
    });

    test('#prepareNextRequestToProcess', () async {
      final manager = RequestSqliteCacheManager('fake_db');
      final request = await manager.prepareNextRequestToProcess();
      expect(sqliteLogs[0], 'BEGIN IMMEDIATE');
      expect(
          sqliteLogs[1],
          startsWith(
              'UPDATE HttpJobs SET locked = 1 WHERE locked IN (SELECT DISTINCT locked FROM HttpJobs WHERE locked = 0 AND created_at <'));
      expect(sqliteLogs[1], endsWith('ORDER BY created_at ASC, attempts DESC, updated_at ASC);'));
      expect(sqliteLogs[2],
          startsWith('SELECT DISTINCT * FROM HttpJobs WHERE locked = 1 AND created_at <'));
      expect(sqliteLogs[2],
          endsWith('ORDER BY created_at ASC, attempts DESC, updated_at ASC LIMIT 1;'));
      expect(sqliteLogs[3], 'COMMIT');

      expect(request.method, 'PUT');
      expect(request.url.toString(), 'http://localhost:3000/stored-query');
    });

    test('#migrate', () async {
      final manager = RequestSqliteCacheManager('fake_db');
      await manager.migrate();

      expect(sqliteLogs.first, contains('CREATE TABLE IF NOT EXISTS `HttpJobs`'));
      expect(sqliteLogs.first, contains('`id` INTEGER PRIMARY KEY AUTOINCREMENT,'));
      expect(sqliteLogs.first, contains('`updated_at` INTEGER DEFAULT 0,'));
      expect(sqliteLogs.last, 'ALTER TABLE `HttpJobs` ADD `created_at` INTEGER DEFAULT 0');
    });

    group('#unprocessedRequests', () {
      test('default args', () async {
        final manager = RequestSqliteCacheManager('fake_db');
        await manager.unprocessedRequests();

        expect(
          sqliteLogs,
          [
            'SELECT DISTINCT * FROM HttpJobs ORDER BY created_at ASC, attempts DESC, updated_at ASC'
          ],
        );
      });

      test('whereLocked:true', () async {
        final manager = RequestSqliteCacheManager('fake_db');
        await manager.unprocessedRequests(whereLocked: true);

        expect(
          sqliteLogs,
          [
            'SELECT DISTINCT * FROM HttpJobs WHERE locked = ? ORDER BY created_at ASC, attempts DESC, updated_at ASC'
          ],
        );
      });
    });

    test('#deleteUnprocessedRequest', () async {
      final manager = RequestSqliteCacheManager('fake_db');
      final resp = await manager.deleteUnprocessedRequest(1);

      expect(
        sqliteLogs,
        ['DELETE FROM HttpJobs WHERE id = ?'],
      );
      expect(resp, isTrue);
    });
  });
}
