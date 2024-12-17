import 'package:brick_core/core.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:gql_link/gql_link.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

class TestRepository extends OfflineFirstWithGraphqlRepository {
  TestRepository._(
    GraphqlProvider graphqlProvider,
    SqliteProvider sqliteProvider,
    GraphqlRequestSqliteCacheManager manager,
  ) : super(
          graphqlProvider: graphqlProvider,
          sqliteProvider: sqliteProvider,
          memoryCacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
          offlineRequestManager: manager,
        );

  factory TestRepository.configure({
    required Link link,
  }) {
    final manager = GraphqlRequestSqliteCacheManager(
      '$inMemoryDatabasePath/queue${DateTime.now().millisecondsSinceEpoch}',
      databaseFactory: databaseFactoryFfi,
    );
    return TestRepository._(
      GraphqlProvider(
        modelDictionary: graphqlModelDictionary,
        link: GraphqlOfflineQueueLink(manager).concat(link),
      ),
      SqliteProvider(
        '$inMemoryDatabasePath/repository${DateTime.now().millisecondsSinceEpoch}',
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteModelDictionary,
      ),
      manager,
    );
  }
}

/// REST mappings should only be used when initializing a [GraphqlProvider]
final Map<Type, GraphqlAdapter<GraphqlModel>> graphqlMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter(),
};
final graphqlModelDictionary = GraphqlModelDictionary(graphqlMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter(),
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
