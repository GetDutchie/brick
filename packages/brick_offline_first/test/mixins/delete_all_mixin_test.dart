import 'package:brick_core/query.dart';
import 'package:brick_offline_first/mixins.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '../offline_first/helpers/__mocks__.dart';
import '../offline_first/helpers/test_domain.dart';

class DeleteAllRepository extends OfflineFirstWithTestRepository
    with DeleteAllMixin<OfflineFirstWithTestModel> {
  DeleteAllRepository({
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

  group('DeleteAllMixin', () {
    final repository = DeleteAllRepository(
      sqliteDictionary: sqliteModelDictionary,
    );

    setUpAll(() async {
      await repository.initialize();
    });

    test('#deleteAll', () async {
      final newModel = Mounty(name: 'GuyDelete');
      final newModel2 = Mounty(name: 'GuyDelete2');

      await repository.upsert<Mounty>(newModel);
      await repository.upsert<Mounty>(newModel2);
      final beforeDelete = await repository.sqliteProvider.get<Mounty>();
      expect(beforeDelete, hasLength(2));

      final deleteAllResult = await repository.deleteAll<Mounty>();
      expect(deleteAllResult, isTrue);

      final afterDelete = await repository.sqliteProvider.get<Mounty>();
      expect(afterDelete, hasLength(0));
    });

    test('#deleteAllExcept', () async {
      final newModel = Mounty(name: 'GuyDelete');
      final newModel2 = Mounty(name: 'GuyDelete2');

      await repository.upsert<Mounty>(newModel);
      await repository.upsert<Mounty>(newModel2);
      final beforeDelete = await repository.sqliteProvider.get<Mounty>();
      expect(beforeDelete, hasLength(2));

      final deleteAllResult =
          await repository.deleteAllExcept<Mounty>(query: Query.where('name', newModel2.name));
      expect(deleteAllResult, isTrue);

      final afterDelete = await repository.sqliteProvider.get<Mounty>();
      expect(afterDelete, hasLength(1));
      expect(afterDelete.first.name, newModel2.name);
    });
  });
}
