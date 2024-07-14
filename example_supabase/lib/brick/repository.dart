import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick/brick.g.dart';
import 'package:brick_supabase/brick/db/schema.g.dart';
import 'package:brick_supabase/brick/jwt_client.dart';
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
            client: JWTClient(),
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

  /// The headers that are sent with every request.
  ///
  /// The access token and api key is attached to the headers just before sending
  /// the request to ensure that the token is up-to-date (and not expired).
  /// See [JWTClient] for more information.
  static Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      // In order to use the upsert method for updates, the following header
      // is needed for the REST API to work correctly.
      // see // https://postgrest.org/en/v12/references/api/tables_views.html#upsert
      'Prefer': 'resolution=merge-duplicates',
    };
  }

  /// Creates a new [Repository] instance and stores it in the singleton.
  static void configure() {
    _singleton = Repository._()
      ..remoteProvider.defaultHeaders = _defaultHeaders();
  }
}
