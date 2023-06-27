import 'package:brick_offline_first/mixins.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '../offline_first/helpers/__mocks__.dart';
import '../offline_first/helpers/test_domain.dart';

class MyRepository extends OfflineFirstWithTestRepository
    with DestructiveLocalSyncFromRemoteMixin<OfflineFirstWithTestModel> {
  MyRepository({
    required SqliteModelDictionary sqliteDictionary,
  }) : super(
          testProvider: TestProvider(testModelDictionary),
          sqliteProvider: SqliteProvider(
            inMemoryDatabasePath,
            databaseFactory: databaseFactoryFfi,
            modelDictionary: sqliteDictionary,
          ),
          cacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
        );
}

void main() {
  sqfliteFfiInit();

  group('DestructiveLocalSyncFromRemoteMixin', () {
    final repository = MyRepository(
      sqliteDictionary: sqliteModelDictionary,
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
