import 'package:brick_core/core.dart';
import 'package:brick_offline_first_with_graphql/offline_first_with_graphql.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:brick_sqlite_abstract/db.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql/language.dart' show parseString;

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

class TestRepository extends OfflineFirstWithGraphqlRepository {
  TestRepository._(
    GraphqlProvider _graphqlProvider,
    SqliteProvider _sqliteProvider,
  ) : super(
          graphqlProvider: _graphqlProvider,
          sqliteProvider: _sqliteProvider,
          memoryCacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
          offlineQueueLinkSqliteCacheManager: GraphqlRequestSqliteCacheManager(
            '$inMemoryDatabasePath/queue',
            databaseFactory: databaseFactoryFfi,
          ),
        );

  factory TestRepository.withProviders(
          GraphqlProvider graphqlProvider, SqliteProvider sqliteProvider) =>
      TestRepository._(graphqlProvider, sqliteProvider);

  factory TestRepository.configure({
    required Link link,
  }) {
    return TestRepository._(
      GraphqlProvider(
        modelDictionary: graphqlModelDictionary,
        link: link,
      ),
      SqliteProvider(
        '$inMemoryDatabasePath/repository',
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteModelDictionary,
      ),
    );
  }
}

/// REST mappings should only be used when initializing a [GraphqlProvider]
final Map<Type, GraphqlAdapter<GraphqlModel>> graphqlMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter()
};
final graphqlModelDictionary = GraphqlModelDictionary(graphqlMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  Horse: HorseAdapter(),
  MemoryDemoModel: MountyAdapter(),
  Mounty: MountyAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
