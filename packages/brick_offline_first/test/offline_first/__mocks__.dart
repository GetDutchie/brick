import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:brick_sqlite_abstract/db.dart';
import 'package:brick_offline_first/offline_first.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '__adapters_models__.dart';

export '__adapters_models__.dart';
export 'package:brick_offline_first/offline_first.dart';

class MockClient extends Mock implements http.Client {}

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
            InsertTable("Mounty"),
            InsertColumn("name", Column.varchar, onTable: "Mounty"),
            InsertTable('_brick_Horse_mounties'),
            InsertTable('Horse'),
            InsertForeignKey('_brick_Horse_mounties', 'Horse',
                foreignKeyColumn: 'Horse_brick_id', onDeleteCascade: true),
            InsertForeignKey('_brick_Horse_mounties', 'Mounty',
                foreignKeyColumn: 'Mounty_brick_id', onDeleteCascade: true),
            InsertColumn('name', Column.varchar, onTable: 'Horse')
          ],
          down: const <MigrationCommand>[],
        );
}

class TestRepository extends OfflineFirstWithRestRepository {
  static TestRepository _singleton;

  TestRepository._(
    RestProvider _restProvider,
    SqliteProvider _sqliteProvider,
  ) : super(
          restProvider: _restProvider,
          sqliteProvider: _sqliteProvider,
          memoryCacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
          offlineQueueHttpClientRequestSqliteCacheManager: RequestSqliteCacheManager(
            inMemoryDatabasePath,
            databaseFactory: databaseFactoryFfi,
          ),
        );
  factory TestRepository() => _singleton;

  factory TestRepository.createInstance({
    String baseUrl,
    RestModelDictionary restDictionary,
    SqliteModelDictionary sqliteDictionary,
    http.Client client,
  }) {
    return TestRepository._(
      RestProvider(baseUrl, modelDictionary: restDictionary, client: client),
      SqliteProvider(
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteDictionary,
      ),
    );
  }

  static TestRepository configure({
    String baseUrl,
    RestModelDictionary restDictionary,
    SqliteModelDictionary sqliteDictionary,
    http.Client client,
  }) {
    _singleton = TestRepository.createInstance(
      baseUrl: baseUrl,
      restDictionary: restDictionary,
      sqliteDictionary: sqliteDictionary,
      client: client,
    );
    return _singleton;
  }
}

/// REST mappings should only be used when initializing a [RestProvider]
final Map<Type, RestAdapter<RestModel>> restMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter()
};
final restModelDictionary = RestModelDictionary(restMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
