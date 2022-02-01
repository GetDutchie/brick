import 'package:brick_offline_first_with_rest/offline_first_with_rest.dart';
import 'package:brick_offline_first_with_rest/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:brick_rest/rest.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:brick_sqlite_abstract/db.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

class TestRepository extends OfflineFirstWithRestRepository {
  static TestRepository? _singleton;

  TestRepository._(
    RestProvider _restProvider,
    SqliteProvider _sqliteProvider,
  ) : super(
          restProvider: _restProvider,
          sqliteProvider: _sqliteProvider,
          memoryCacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
          offlineQueueHttpClientRequestSqliteCacheManager: RestRequestSqliteCacheManager(
            '$inMemoryDatabasePath/queue',
            databaseFactory: databaseFactoryFfi,
          ),
        );
  factory TestRepository() => _singleton!;

  factory TestRepository.withProviders(RestProvider restProvider, SqliteProvider sqliteProvider) =>
      TestRepository._(restProvider, sqliteProvider);

  factory TestRepository.configure({
    required String baseUrl,
    required RestModelDictionary restDictionary,
    required SqliteModelDictionary sqliteDictionary,
    http.Client? client,
  }) {
    return _singleton = TestRepository._(
      RestProvider(
        baseUrl,
        modelDictionary: restDictionary,
        client: client,
      ),
      SqliteProvider(
        '$inMemoryDatabasePath/repository',
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteDictionary,
      ),
    );
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
