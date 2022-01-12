import 'package:brick_graphql/src/graphql_provider.dart';
import 'package:brick_graphql/src/offline_first_with_graphql/offline_first_with_graphql.dart';
import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:brick_rest/rest.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_sqlite/sqlite.dart';

import 'package:brick_sqlite_abstract/db.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
export 'package:brick_offline_first/offline_first.dart';

class TestRepository extends OfflineFirstWithGraphQLRespository {
  static TestRepository? _singleton;

  TestRepository._(
    GraphQLProvider _graphqlProvider,
    SqliteProvider _sqliteProvider,
  ) : super(
          restProvider: _graphqlProvider,
          sqliteProvider: _sqliteProvider,
          memoryCacheProvider: MemoryCacheProvider([MemoryDemoModel]),
          migrations: {const DemoModelMigration()},
          offlineQueueHttpClientRequestSqliteCacheManager: RequestSqliteCacheManager(
            inMemoryDatabasePath,
            databaseFactory: databaseFactoryFfi,
          ),
        );
  factory TestRepository() => _singleton!;

  factory TestRepository.withProviders(RestProvider restProvider, SqliteProvider sqliteProvider) =>
      TestRepository._(_graphqlProvider, sqliteProvider);

  factory TestRepository.configure({
    required String baseUrl,
    required RestModelDictionary restDictionary,
    required SqliteModelDictionary sqliteDictionary,
    GraphQLClient? client,
  }) {
    return _singleton = TestRepository._(
      GraphQLProvider(
        baseUrl,
        modelDictionary: restDictionary,
        client: client,
      ),
      SqliteProvider(
        inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        modelDictionary: sqliteDictionary,
      ),
    );
  }
}
