import 'package:brick_offline_first/offline_first_with_rest.dart';
import 'package:pizza_shoppe/app/db/schema.g.dart';
import 'brick.g.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';

class Repository extends OfflineFirstWithRestRepository {
  Repository._(String endpoint)
      : super(
          restProvider: RestProvider(
            endpoint,
            modelDictionary: restModelDictionary,
          ),
          sqliteProvider: SqliteProvider(
            "pizzaShoppe.sqlite",
            modelDictionary: sqliteModelDictionary,
          ),
          memoryCacheProvider: MemoryCacheProvider(),
          migrations: migrations,
        );

  factory Repository() => _singleton ?? Exception("Must call #configure first");

  static Repository _singleton;

  static void configure(String endpoint) {
    _singleton = Repository._(endpoint);
  }
}
