import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick/brick.g.dart';
import 'package:brick_supabase/brick/db/schema.g.dart';
import 'package:brick_supabase/brick/supabase_brick_client.dart';
import 'package:brick_supabase/env.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class Repository extends OfflineFirstWithRestRepository {
  Repository._()
      : super(
          restProvider: RestProvider(
            '${SUPABASE_PROJECT_URL}/rest/v1',
            modelDictionary: restModelDictionary,
            client: SupabaseBrickClient(
              anonKey: SUPABASE_ANON_KEY,
            ),
          ),
          sqliteProvider: SqliteProvider(
            'brick_db.sqlite',
            databaseFactory: kIsWeb ? databaseFactoryFfiWeb : databaseFactory,
            modelDictionary: sqliteModelDictionary,
          ),
          offlineQueueManager: RestRequestSqliteCacheManager(
            'brick_offline_queue.sqlite',
            databaseFactory: kIsWeb ? databaseFactoryFfiWeb : databaseFactory,
          ),
          migrations: migrations,
        );

  factory Repository() => _singleton!;

  static Repository? _singleton;

  static void configure() {
    _singleton = Repository._();
  }
}
