import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick/brick.g.dart';
import 'package:brick_supabase/brick/db/schema.g.dart';
import 'package:brick_supabase/brick/supabase_brick_client.dart';
import 'package:brick_supabase/env.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;

class Repository extends OfflineFirstWithRestRepository {
  Repository._()
      : super(
          restProvider: RestProvider(
            '${SUPABASE_PROJECT_URL}/rest/v1',
            modelDictionary: restModelDictionary,
            client: SupabaseBrickClient(
              supabaseAnonKey: SUPABASE_ANON_KEY,
            ),
          ),
          sqliteProvider: SqliteProvider(
            'brick_db.sqlite',
            databaseFactory: databaseFactory,
            modelDictionary: sqliteModelDictionary,
          ),
          offlineQueueManager: RestRequestSqliteCacheManager(
            'brick_offline_queue.sqlite',
            databaseFactory: databaseFactory,
          ),
          migrations: migrations,
        );

  factory Repository() => _singleton!;

  static Repository? _singleton;

  static void configure() {
    _singleton = Repository._();
  }
}
