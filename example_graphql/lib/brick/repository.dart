import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:gql_http_link/gql_http_link.dart';
// run flutter pub run build_runner build before using this example
import 'package:pizza_shoppe/brick/db/schema.g.dart';
import 'brick.g.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;

class Repository extends OfflineFirstWithGraphqlRepository {
  Repository._(String endpoint)
      : super(
          graphqlProvider: GraphqlProvider(
            link: HttpLink(endpoint),
            modelDictionary: graphqlModelDictionary,
          ),
          sqliteProvider: SqliteProvider(
            'pizzaShoppe.sqlite',
            databaseFactory: databaseFactory,
            modelDictionary: sqliteModelDictionary,
          ),
          offlineRequestManager: GraphqlRequestSqliteCacheManager(
            'brick_offline_queue.sqlite',
            databaseFactory: databaseFactory,
          ),
          // as both models store each other as associations, we should
          // cache neither
          memoryCacheProvider: MemoryCacheProvider(),
          migrations: migrations,
        );

  factory Repository() => _singleton!;

  static Repository? _singleton;

  static void configure(String endpoint) {
    _singleton = Repository._(endpoint);
  }
}
