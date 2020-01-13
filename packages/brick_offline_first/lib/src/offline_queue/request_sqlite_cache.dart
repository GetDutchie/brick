import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

/// Serialize and Deserialize a [http.Request] from SQLite.
class RequestSqliteCache {
  final http.Request request;
  final String databaseName;

  /// Matches any HTTP requests that send data (or 'push'). 'Pull' requests most often have an
  /// outcome that exists in memory (e.g. deserializing to a model). Since callbacks cannot
  /// be stored in SQLite and there's no guarantee of the destination existing (say
  /// disposal or a crash has since occurred), 'pull' requests will be ignored.
  bool get requestIsPush => ['POST', 'PUT', 'DELETE', 'PATCH'].contains(request.method);

  RequestSqliteCache(
    this.request,
    this.databaseName,
  );

  /// Builds request into a new SQLite-insertable row
  /// Only available if [request] was initialized from [fromRequest]
  ///
  /// This is a function to ensure `DateTime.now()` is invoked predictably.
  Map<String, dynamic> toSqlite() {
    return {
      HTTP_JOBS_ATTEMPTS_COLUMN: 1,
      HTTP_JOBS_BODY_COLUMN: request.body,
      HTTP_JOBS_ENCODING_COLUMN: request.encoding.name,
      HTTP_JOBS_HEADERS_COLUMN: jsonEncode(request.headers),
      HTTP_JOBS_REQUEST_METHOD_COLUMN: request.method,
      HTTP_JOBS_UPDATED_AT: DateTime.now().millisecondsSinceEpoch,
      HTTP_JOBS_URL_COLUMN: request.url.toString(),
    };
  }

  /// Removes the request from the database and thus the queue
  Future<int> delete() async {
    final db = await _getDb();
    final response = await _findRequestInDatabase();

    if (response != null && response.isNotEmpty) {
      return await db.transaction((txn) async {
        return await txn.delete(
          HTTP_JOBS_TABLE_NAME,
          where: 'id = ?',
          whereArgs: [response['id']],
        );
      });
    }

    return 0;
  }

  /// If the request already exists in the database, increment attemps and
  /// set `updated_at` to current time.
  Future<int> insertOrUpdate(Logger logger) async {
    final db = await _getDb();
    final response = await _findRequestInDatabase();

    return db.transaction((txn) async {
      if (response == null || response.isEmpty) {
        final serialized = toSqlite();

        logger.fine('adding to queue: $serialized');
        return await txn.insert(
          HTTP_JOBS_TABLE_NAME,
          serialized,
        );
      }

      logger.warning('failed, attempt #${response[HTTP_JOBS_ATTEMPTS_COLUMN]} $response');
      return await txn.update(
        HTTP_JOBS_TABLE_NAME,
        {
          HTTP_JOBS_ATTEMPTS_COLUMN: response[HTTP_JOBS_ATTEMPTS_COLUMN] + 1,
          HTTP_JOBS_UPDATED_AT: DateTime.now().millisecondsSinceEpoch,
          HTTP_JOBS_LOCKED_COLUMN: 0, // unlock the row, this job has finished processing
        },
        where: 'id = ?',
        whereArgs: [response['id']],
      );
    });
  }

  Future<Map<String, dynamic>> _findRequestInDatabase() async {
    final db = await _getDb();

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

  Database _db;
  Future<Database> _getDb() async {
    if (_db?.isOpen == true) return _db;
    return _db = await _openDb(databaseName);
  }

  /// Prepare schema.
  static Future<void> migrate(String dbName) async {
    final statement = '''
      CREATE TABLE IF NOT EXISTS `$HTTP_JOBS_TABLE_NAME` (
        `id` INTEGER PRIMARY KEY AUTOINCREMENT,
        `$HTTP_JOBS_ATTEMPTS_COLUMN` INTEGER DEFAULT 1,
        `$HTTP_JOBS_BODY_COLUMN` TEXT,
        `$HTTP_JOBS_ENCODING_COLUMN` TEXT,
        `$HTTP_JOBS_HEADERS_COLUMN` TEXT,
        `$HTTP_JOBS_LOCKED_COLUMN` INTEGER DEFAULT 0,
        `$HTTP_JOBS_REQUEST_METHOD_COLUMN` TEXT,
        `$HTTP_JOBS_UPDATED_AT` INTEGER DEFAULT 0,
        `$HTTP_JOBS_URL_COLUMN` TEXT
      );
    ''';
    final db = await _openDb(dbName);
    return await db.execute(statement);
  }

  /// Take all jobs in database.
  ///
  /// [maximumRequests] determines how many records will be returned. Defaults to `1`.
  static Future<Iterable<http.Request>> unproccessedRequests(
    String dbName, {
    int maximumRequests = 1,
  }) async {
    final db = await _openDb(dbName);
    final unprocessedJobs = await db.transaction<List<Map<String, dynamic>>>((txn) async {
      final whereUnlocked = _lockedQuery(false, maximumRequests, HTTP_JOBS_LOCKED_COLUMN);
      final whereLocked = _lockedQuery(true, maximumRequests);

      // lock the requests for idempotency
      await txn.rawUpdate(
          'UPDATE $HTTP_JOBS_TABLE_NAME SET $HTTP_JOBS_LOCKED_COLUMN = 1 WHERE $HTTP_JOBS_LOCKED_COLUMN IN ($whereUnlocked);');

      return txn.rawQuery('$whereLocked;');
    });

    return unprocessedJobs.map(toRequest);
  }

  /// Recreate a request from SQLite data
  @visibleForTesting
  @protected
  static http.Request toRequest(Map<String, dynamic> data) {
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

const HTTP_JOBS_TABLE_NAME = 'HttpJobs';

const HTTP_JOBS_ATTEMPTS_COLUMN = 'attempts';
const HTTP_JOBS_BODY_COLUMN = 'body';
const HTTP_JOBS_ENCODING_COLUMN = 'encoding';
const HTTP_JOBS_HEADERS_COLUMN = 'headers';
const HTTP_JOBS_LOCKED_COLUMN = 'locked';
const HTTP_JOBS_REQUEST_METHOD_COLUMN = 'request_method';
const HTTP_JOBS_UPDATED_AT = 'updated_at';
const HTTP_JOBS_URL_COLUMN = 'url';

Future<Database> _openDb(String dbName) async {
  final databasesPath = await getDatabasesPath();
  final path = p.join(databasesPath, dbName);
  return await openDatabase(path);
}

/// Generate SQLite query for [unprocessedRequests]
String _lockedQuery(bool whereIsLocked, int limit, [String selectFields = '*']) {
  return [
    'SELECT DISTINCT',
    selectFields,
    'FROM $HTTP_JOBS_TABLE_NAME',
    'WHERE $HTTP_JOBS_LOCKED_COLUMN = ${whereIsLocked ? 1 : 0}',
    'ORDER BY $HTTP_JOBS_UPDATED_AT ASC',
    'LIMIT $limit'
  ].join(' ');
}
