import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
// run flutter pub run build_runner build before using this example
import 'package:pizza_shoppe/brick/db/schema.g.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'brick.g.dart';

class Repository extends OfflineFirstWithRestRepository {
  Repository._(String endpoint)
      : super(
          restProvider: RestProvider(
            endpoint,
            modelDictionary: restModelDictionary,
          ),
          sqliteProvider: SqliteProvider(
            'pizzaShoppe.sqlite',
            databaseFactory: databaseFactory,
            modelDictionary: sqliteModelDictionary,
          ),
          offlineQueueManager: RestRequestSqliteCacheManager(
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
