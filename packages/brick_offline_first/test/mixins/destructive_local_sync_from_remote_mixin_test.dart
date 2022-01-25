import 'package:brick_offline_first/mixins.dart';
import 'package:brick_offline_first/src/offline_queue/rest/rest_request_sqlite_cache_manager.dart';
import 'package:brick_offline_first/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:brick_rest/rest.dart';
import 'package:http/http.dart' as http;
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:sqflite_common/sqlite_api.dart';

import '../offline_first/helpers/__mocks__.dart';

class MyRepository extends OfflineFirstWithRestRepository
    with DestructiveLocalSyncFromRemoteMixin<OfflineFirstWithRestModel> {
  MyRepository({
    required String baseUrl,
    required RestModelDictionary restDictionary,
    required SqliteModelDictionary sqliteDictionary,
    http.Client? client,
  }) : super(
          restProvider: RestProvider(baseUrl, client: client, modelDictionary: restDictionary),
          sqliteProvider: SqliteProvider(
            inMemoryDatabasePath,
            databaseFactory: databaseFactoryFfi,
            modelDictionary: sqliteDictionary,
          ),
          memoryCacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
          offlineQueueHttpClientRequestSqliteCacheManager: RestRequestSqliteCacheManager(
            inMemoryDatabasePath,
            databaseFactory: databaseFactoryFfi,
          ),
        );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('DestructiveLocalSyncFromRemoteMixin', () {
    final repository = MyRepository(
      baseUrl: 'http://0.0.0.0:3000',
      restDictionary: restModelDictionary,
      sqliteDictionary: sqliteModelDictionary,
      client: StubOfflineFirstWithRest.fromFiles('http://0.0.0.0:3000', {
        'mounties': 'offline_first/api/mounties.json',
      }).client,
    );

    setUpAll(() async {
      await repository.initialize();
    });

    test('#get', () async {
      final newModel = Mounty(name: 'Guy');
      final newModel2 = Mounty(name: 'Thomas');

      await repository.upsert<Mounty>(newModel);
      // stubbed API doesn't support upserts; this will be synced to SQLite but not to REST
      await repository.upsert<Mounty>(newModel2);
      final beforeDelete = await repository.sqliteProvider.get<Mounty>();
      expect(beforeDelete, hasLength(2));

      final getFromRemote = await repository.get<Mounty>(forceLocalSyncFromRemote: true);
      expect(getFromRemote, hasLength(1));
      final getFromLocal = await repository.sqliteProvider.get<Mounty>();
      expect(getFromLocal, hasLength(1));
    });
  });
}
