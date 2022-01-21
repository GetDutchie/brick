// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:brick_offline_first/src/offline_queue/rest_request_sqlite_cache.dart';
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
          processingInterval: processingInterval ?? const Duration(seconds: 0),
          primaryKeyColumn: HTTP_JOBS_PRIMARY_KEY_COLUMN,
          lockedColumn: HTTP_JOBS_LOCKED_COLUMN,
          updateAtColumn: HTTP_JOBS_UPDATED_AT,
          serialProcessing: serialProcessing ?? false,
          tableName: HTTP_JOBS_TABLE_NAME,
        );

  @override
  Future<void> migrate() async {
    final statement = '''
      CREATE TABLE IF NOT EXISTS `$tableName` (
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
  Future<http.Request?> prepareNextRequestToProcess() async {
    final unprocessedRequests = await findNextRequestToProcess();
    final jobs = unprocessedRequests.map(sqliteToRequest);

    if (jobs.isNotEmpty) return jobs.first;

    // lock the request for idempotency

    return null;
  }

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

const HTTP_JOBS_TABLE_NAME = 'HttpJobs';

/// int; autoincrement'd
const HTTP_JOBS_PRIMARY_KEY_COLUMN = 'id';

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

/// String
const HTTP_JOBS_REQUEST_METHOD_COLUMN = 'request_method';

/// int; millisecondsSinceEpoch
const HTTP_JOBS_UPDATED_AT = 'updated_at';

/// String
const HTTP_JOBS_URL_COLUMN = 'url';
