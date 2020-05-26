import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';

/// Serialize and Deserialize a [http.Request] from SQLite.
class RequestSqliteCache {
  final http.Request request;

  /// Matches any HTTP requests that send data (or 'push'). 'Pull' requests most often have an
  /// outcome that exists in memory (e.g. deserializing to a model). Since callbacks cannot
  /// be stored in SQLite and there's no guarantee of the destination existing (say
  /// disposal or a crash has since occurred), 'pull' requests will be ignored.
  bool get requestIsPush => ['POST', 'PUT', 'DELETE', 'PATCH'].contains(request.method);

  RequestSqliteCache(this.request);

  /// Builds request into a new SQLite-insertable row
  /// Only available if [request] was initialized from [fromRequest]
  ///
  /// This is a function to ensure `DateTime.now()` is invoked predictably.
  Map<String, dynamic> toSqlite() {
    return {
      HTTP_JOBS_ATTEMPTS_COLUMN: 1,
      HTTP_JOBS_BODY_COLUMN: request.body,
      HTTP_JOBS_CREATED_AT_COLUMN: DateTime.now().millisecondsSinceEpoch,
      HTTP_JOBS_ENCODING_COLUMN: request.encoding.name,
      HTTP_JOBS_HEADERS_COLUMN: jsonEncode(request.headers),
      HTTP_JOBS_REQUEST_METHOD_COLUMN: request.method,
      HTTP_JOBS_UPDATED_AT: DateTime.now().millisecondsSinceEpoch,
      HTTP_JOBS_URL_COLUMN: request.url.toString(),
    };
  }

  /// Removes the request from the database and thus the queue
  Future<int> delete(Database db) async {
    final response = await _findRequestInDatabase(db);

    if (response != null && response.isNotEmpty) {
      return await db.transaction((txn) async {
        return await txn.delete(
          HTTP_JOBS_TABLE_NAME,
          where: '$HTTP_JOBS_PRIMARY_KEY_COLUMN = ?',
          whereArgs: [response[HTTP_JOBS_PRIMARY_KEY_COLUMN]],
        );
      });
    }

    return 0;
  }

  /// If the request already exists in the database, increment attemps and
  /// set `updated_at` to current time.
  Future<int> insertOrUpdate(Database db, {Logger logger}) async {
    final response = await _findRequestInDatabase(db);

    return db.transaction((txn) async {
      if (response == null || response.isEmpty) {
        final serialized = toSqlite();

        logger?.fine('adding to queue: $serialized');
        return await txn.insert(
          HTTP_JOBS_TABLE_NAME,
          serialized,
        );
      }
      final methodWithUrl =
          [response[HTTP_JOBS_REQUEST_METHOD_COLUMN], response[HTTP_JOBS_URL_COLUMN]].join(' ');
      logger?.warning(
          'failed, attempt #${response[HTTP_JOBS_ATTEMPTS_COLUMN]} in $methodWithUrl : $response');
      return await txn.update(
        HTTP_JOBS_TABLE_NAME,
        {
          HTTP_JOBS_ATTEMPTS_COLUMN: response[HTTP_JOBS_ATTEMPTS_COLUMN] + 1,
          HTTP_JOBS_UPDATED_AT: DateTime.now().millisecondsSinceEpoch,
          HTTP_JOBS_LOCKED_COLUMN: 0, // unlock the row, this job has finished processing
        },
        where: '$HTTP_JOBS_PRIMARY_KEY_COLUMN = ?',
        whereArgs: [response[HTTP_JOBS_PRIMARY_KEY_COLUMN]],
      );
    });
  }

  Future<Map<String, dynamic>> _findRequestInDatabase(Database db) async {
    final columns = [
      HTTP_JOBS_BODY_COLUMN,
      HTTP_JOBS_ENCODING_COLUMN,
      HTTP_JOBS_HEADERS_COLUMN,
      HTTP_JOBS_REQUEST_METHOD_COLUMN,
      HTTP_JOBS_URL_COLUMN,
    ];

    final whereStatement = columns.join(' = ? AND ');
    final serialized = toSqlite();

    final response = await db.query(
      HTTP_JOBS_TABLE_NAME,
      where: '$whereStatement = ?',
      whereArgs: columns.map((c) => serialized[c]).toList(),
    );

    return response?.isNotEmpty == true ? response.first : null;
  }

  /// Recreate a request from SQLite data
  static http.Request sqliteToRequest(Map<String, dynamic> data) {
    var _request = http.Request(
      data[HTTP_JOBS_REQUEST_METHOD_COLUMN],
      Uri.parse(data[HTTP_JOBS_URL_COLUMN]),
    );

    if (data[HTTP_JOBS_ENCODING_COLUMN] != null) {
      _request.encoding = Encoding.getByName(data[HTTP_JOBS_ENCODING_COLUMN]);
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
