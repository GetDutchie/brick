// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common/sqlite_api.dart';

class RestRequestSqliteCacheManager extends RequestSqliteCacheManager<http.Request> {
  RestRequestSqliteCacheManager(
    String databaseName, {
    DatabaseFactory? databaseFactory,
    Duration? processingInterval,
    bool? serialProcessing,
  }) : super(
          databaseName,
          createdAtColumn: HTTP_JOBS_CREATED_AT_COLUMN,
          databaseFactory: databaseFactory,
          lockedColumn: HTTP_JOBS_LOCKED_COLUMN,
          primaryKeyColumn: HTTP_JOBS_PRIMARY_KEY_COLUMN,
          processingInterval: processingInterval ?? const Duration(seconds: 0),
          serialProcessing: serialProcessing ?? true,
          tableName: HTTP_JOBS_TABLE_NAME,
          updateAtColumn: HTTP_JOBS_UPDATED_AT,
        );

  @override
  Future<void> migrate() async {
    const statement = '''
      CREATE TABLE IF NOT EXISTS `$HTTP_JOBS_TABLE_NAME` (
        `$HTTP_JOBS_PRIMARY_KEY_COLUMN` INTEGER PRIMARY KEY AUTOINCREMENT,
        `$HTTP_JOBS_ATTEMPTS_COLUMN` INTEGER DEFAULT 1,
        `$HTTP_JOBS_BODY_COLUMN` TEXT,
        `$HTTP_JOBS_ENCODING_COLUMN` TEXT,
        `$HTTP_JOBS_HEADERS_COLUMN` TEXT,
        `$HTTP_JOBS_LOCKED_COLUMN` INTEGER DEFAULT 0,
        `$HTTP_JOBS_REQUEST_METHOD_COLUMN` TEXT,
        `$HTTP_JOBS_UPDATED_AT` INTEGER DEFAULT 0,
        `$HTTP_JOBS_URL_COLUMN` TEXT,
        `$HTTP_JOBS_CREATED_AT_COLUMN` INTEGER DEFAULT 0
      );
    ''';
    final db = await getDb();
    await db.execute(statement);

    final tableInfo = await db.rawQuery('PRAGMA table_info("$HTTP_JOBS_TABLE_NAME");');
    final createdAtHasBeenMigrated = tableInfo.any((c) => c['name'] == HTTP_JOBS_CREATED_AT_COLUMN);
    if (!createdAtHasBeenMigrated) {
      await db.execute(
          'ALTER TABLE `$HTTP_JOBS_TABLE_NAME` ADD `$HTTP_JOBS_CREATED_AT_COLUMN` INTEGER DEFAULT 0');
    }
  }

  @override
  http.Request sqliteToRequest(Map<String, dynamic> data) {
    var _request = http.Request(
      data[HTTP_JOBS_REQUEST_METHOD_COLUMN],
      Uri.parse(data[HTTP_JOBS_URL_COLUMN]),
    );

    if (data[HTTP_JOBS_ENCODING_COLUMN] != null) {
      final encoding = Encoding.getByName(data[HTTP_JOBS_ENCODING_COLUMN]);
      if (encoding != null) _request.encoding = encoding;
    }

    if (data[HTTP_JOBS_HEADERS_COLUMN] != null) {
      _request.headers.addAll(Map<String, String>.from(jsonDecode(data[HTTP_JOBS_HEADERS_COLUMN])));
    }

    if (data[HTTP_JOBS_BODY_COLUMN] != null) {
      _request.body = data[HTTP_JOBS_BODY_COLUMN];
    }

    return _request;
  }
}

/// int
const HTTP_JOBS_ATTEMPTS_COLUMN = 'attempts';

/// String
const HTTP_JOBS_BODY_COLUMN = 'body';

/// int; millisecondsSinceEpoch
const HTTP_JOBS_CREATED_AT_COLUMN = 'created_at';

/// String
const HTTP_JOBS_ENCODING_COLUMN = 'encoding';

/// json-encoded String
const HTTP_JOBS_HEADERS_COLUMN = 'headers';

/// int; 1 for true, 0 for false
const HTTP_JOBS_LOCKED_COLUMN = 'locked';

/// int; autoincrement'd
const HTTP_JOBS_PRIMARY_KEY_COLUMN = 'id';

/// String
const HTTP_JOBS_REQUEST_METHOD_COLUMN = 'request_method';

const HTTP_JOBS_TABLE_NAME = 'HttpJobs';

/// int; millisecondsSinceEpoch
const HTTP_JOBS_UPDATED_AT = 'updated_at';

/// String
const HTTP_JOBS_URL_COLUMN = 'url';
