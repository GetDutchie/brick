import 'package:brick_offline_first/offline_first.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:brick_sqlite_abstract/db.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'test_domain.dart';
export 'package:brick_offline_first/offline_first.dart';

part 'horse_adapter.dart';
part 'horse.dart';
part 'mounty_adapter.dart';
part 'mounty.dart';

/// The exact same as [DemoModel], except this class is tracked by the Memory Cache Provider
/// while [DemoModel] is not.
class MemoryDemoModel extends Mounty {
  MemoryDemoModel(String name) : super(name: name);
}

class DemoModelMigration extends Migration {
  const DemoModelMigration()
      : super(
          version: 1,
          up: const <MigrationCommand>[
            InsertTable('Mounty'),
            InsertColumn('name', Column.varchar, onTable: 'Mounty'),
            InsertTable('_brick_Horse_mounties'),
            InsertTable('Horse'),
            InsertForeignKey('_brick_Horse_mounties', 'Horse',
                foreignKeyColumn: 'l_Horse_brick_id', onDeleteCascade: true),
            InsertForeignKey('_brick_Horse_mounties', 'Mounty',
                foreignKeyColumn: 'f_Mounty_brick_id', onDeleteCascade: true),
            InsertColumn('name', Column.varchar, onTable: 'Horse')
          ],
          down: const <MigrationCommand>[],
        );
}

class TestRepository extends OfflineFirstWithTestRepository {
  static TestRepository? _singleton;

  /// A hack to similuate a failure in the remote provider
  static bool throwOnNextRemoteMutation = false;

  TestRepository._(
    TestProvider testProvider,
    SqliteProvider sqliteProvider,
  ) : super(
          testProvider: testProvider,
          sqliteProvider: sqliteProvider,
          cacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
        );

  factory TestRepository() => _singleton!;

  factory TestRepository.withProviders(TestProvider testProvider, SqliteProvider sqliteProvider) =>
      TestRepository._(testProvider, sqliteProvider);

  factory TestRepository.configure({
    required SqliteModelDictionary sqliteDictionary,
  }) {
    return _singleton = TestRepository._(
      TestProvider(testModelDictionary),
      SqliteProvider(
        '$inMemoryDatabasePath/repository',
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteDictionary,
      ),
    );
  }

  @override
  Query? applyPolicyToQuery(Query? query,
      {OfflineFirstDeletePolicy? delete,
      OfflineFirstGetPolicy? get,
      OfflineFirstUpsertPolicy? upsert}) {
    return query?.copyWith(providerArgs: {
      'policy': get?.index,
    });
  }
}

/// Test mappings should only be used when initializing a [TestProvider]
final Map<Type, TestAdapter<TestModel>> testMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter()
};
final testModelDictionary = TestModelDictionary(testMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
