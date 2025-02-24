import 'package:brick_core/src/model_repository.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'test_domain.dart';

part 'horse.dart';
part 'horse_adapter.dart';
part 'mounty.dart';
part 'mounty_adapter.dart';

/// The exact same as [Mounty], except this class is tracked by the Memory Cache Provider
/// while [Mounty] is not.
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
            InsertForeignKey(
              '_brick_Horse_mounties',
              'Horse',
              foreignKeyColumn: 'l_Horse_brick_id',
              onDeleteCascade: true,
            ),
            InsertForeignKey(
              '_brick_Horse_mounties',
              'Mounty',
              foreignKeyColumn: 'f_Mounty_brick_id',
              onDeleteCascade: true,
            ),
            InsertColumn('name', Column.varchar, onTable: 'Horse'),
          ],
          down: const <MigrationCommand>[],
        );
}

class TestRepository extends OfflineFirstWithTestRepository {
  static late TestRepository? _singleton;

  /// A hack to similuate a failure in the remote provider
  // ignore: omit_obvious_property_types
  static bool throwOnNextRemoteMutation = false;

  factory TestRepository() => _singleton!;

  TestRepository._(
    TestProvider testProvider,
    SqliteProvider sqliteProvider,
  ) : super(
          testProvider: testProvider,
          sqliteProvider: sqliteProvider,
          cacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
        );

  factory TestRepository.withProviders(TestProvider testProvider, SqliteProvider sqliteProvider) =>
      TestRepository._(testProvider, sqliteProvider);

  factory TestRepository.configure() {
    return _singleton = TestRepository._(
      TestProvider(testModelDictionary),
      SqliteProvider(
        '$inMemoryDatabasePath/${DateTime.now().microsecondsSinceEpoch}',
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteModelDictionary,
      ),
    );
  }

  @override
  Query? applyPolicyToQuery(
    Query? query, {
    OfflineFirstDeletePolicy? delete,
    OfflineFirstGetPolicy? get,
    OfflineFirstUpsertPolicy? upsert,
  }) {
    return query?.copyWith(action: QueryAction.values[get?.index ?? 0]);
  }
}

/// Test mappings should only be used when initializing a [TestProvider]
final Map<Type, TestAdapter<TestModel>> testMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter(),
};
final testModelDictionary = TestModelDictionary(testMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter(),
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
