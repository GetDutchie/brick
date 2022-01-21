import 'dart:convert';

import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache_manager.dart';
import 'package:brick_offline_first/src/offline_queue/rest_request_sqlite_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

/// Serialize and Deserialize a [Request] from SQLite.
abstract class RequestSqliteCache {
  final dynamic request;
  final List<dynamic> requestColumns;
  final String attemptColumn;
  final String createdAtColumn;
  final String lockedColumn;
  final String primaryKeyColumn;
  final String tableName;
  final String updateAtColumn;

  /// Matches any HTTP requests that send data (or 'push'). 'Pull' requests most often have an
  /// outcome that exists in memory (e.g. deserializing to a model). Since callbacks cannot
  /// be stored in SQLite and there's no guarantee of the destination existing (say
  /// disposal or a crash has since occurred), 'pull' requests will be ignored.

  RequestSqliteCache({
    required this.attemptColumn,
    required this.createdAtColumn,
    required this.lockedColumn,
    required this.primaryKeyColumn,
    required this.request,
    required this.requestColumns,
    required this.tableName,
    required this.updateAtColumn,
  });

  /// Removes the request from the database and thus the queue
  Future<int> delete(Database db) async {
    final response = await findRequestInDatabase(db);

    if (response != null && response.isNotEmpty) {
      return await db.transaction((txn) async {
        return await txn.delete(
          tableName,
          where: '$primaryKeyColumn = ?',
          whereArgs: [response[primaryKeyColumn]],
        );
      });
    }

    return 0;
  }

  @protected
  Future<Map<String, dynamic>?> findRequestInDatabase(DatabaseExecutor db) async {
    final whereStatement = requestColumns.join(' = ? AND ');
    final serialized = toSqlite();

    final response = await db.query(
      tableName,
      where: '$whereStatement = ?',
      whereArgs: requestColumns.map((c) => serialized[c]).toList(),
    );

    return response.isNotEmpty ? response.first : null;
  }

  /// If the request already exists in the database, increment attemps and
  /// set `updated_at` to current time.
  Future<int> insertOrUpdate(Database db, {Logger? logger}) async {
    final response = await findRequestInDatabase(db);

    return db.transaction((txn) async {
      if (response == null || response.isEmpty) {
        final serialized = toSqlite();
        serialized[lockedColumn] = 1;

        logger?.fine('adding to queue: $serialized');
        return await txn.insert(
          tableName,
          serialized,
        );
      }

      var attemptMessage = '';

      if (response[HTTP_JOBS_REQUEST_METHOD_COLUMN].isEmpty &&
          response[HTTP_JOBS_URL_COLUMN].isEmpty) {
        attemptMessage =
            [response[HTTP_JOBS_REQUEST_METHOD_COLUMN], response[HTTP_JOBS_URL_COLUMN]].join(' ');
      } else {
        attemptMessage = response[GRAPHQL_JOB_OPERATION_NAME_COLUMN];
      }

      logger?.warning('failed, attempt #${response[attemptColumn]} in $attemptMessage : $response');
      return await txn.update(
        tableName,
        {
          attemptColumn: response[attemptColumn] + 1,
          updateAtColumn: DateTime.now().millisecondsSinceEpoch,
          lockedColumn: 1,
        },
        where: '$primaryKeyColumn = ?',
        whereArgs: [response[primaryKeyColumn]],
      );
    });
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

  /// Builds request into a new SQLite-insertable row
  /// Only available if [request] was initialized from [fromRequest]
  ///
  /// This is a function to ensure `DateTime.now()` is invoked predictably.
  Map<String, dynamic> toSqlite();

  /// If the request did not succeed, unlock for subsequent processing
  Future<int?> unlock(Database db) async {
    return await db.transaction((txn) async {
      final response = await findRequestInDatabase(txn);
      if (response == null) return null;
      return await unlockRequest(response, txn);
    });
  }

  Future<int> lockRequest(Map<String, dynamic> data, DatabaseExecutor db) async =>
      await _updateLock(true, data, db);

  Future<int> unlockRequest(Map<String, dynamic> data, DatabaseExecutor db) async =>
      await _updateLock(false, data, db);

  Future<int> _updateLock(
    bool shouldLock,
    Map<String, dynamic> data,
    DatabaseExecutor db,
  ) async {
    return await db.update(
      tableName,
      {
        lockedColumn: shouldLock ? 1 : 0,
      },
      where: '$primaryKeyColumn = ?',
      whereArgs: [data[primaryKeyColumn]],
    );
  }
}
