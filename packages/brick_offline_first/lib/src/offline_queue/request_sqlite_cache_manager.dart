import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';

/// Fetch and delete [RequestSqliteCache]s.
class RequestSqliteCacheManager {
  final String databaseName;

  RequestSqliteCacheManager(this.databaseName);

  Database _db;
  Future<Database> _getDb() async {
    if (_db?.isOpen == true) return _db;
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, databaseName);
    return _db = await openDatabase(path);
  }

  /// Delete most recent job in queue. **This is a destructive action and cannot be undone**.
  ///
  /// returns `null` if no requests to delete;
  /// returns `true` if the request was deleted.
  Future<bool> deleteNextUnprocessedRequest() async {
    final db = await _getDb();
    final unprocessed = await unprocessedJobs(whereLocked: true);

    if (unprocessed == null ||
        unprocessed.isEmpty ||
        unprocessed.first[HTTP_JOBS_PRIMARY_KEY_COLUMN] == null) {
      return null;
    }

    final result = await db.delete(
      HTTP_JOBS_TABLE_NAME,
      where: '$HTTP_JOBS_PRIMARY_KEY_COLUMN = ?',
      whereArgs: [unprocessed.first[HTTP_JOBS_PRIMARY_KEY_COLUMN]],
    );

    return result > 0;
  }

  /// Discover most recent unprocessed job in database convert it back to an HTTP request.
  /// This method also locks the row to make it idempotent to subsequent processing.
  Future<http.Request> prepareNextRequestToProcess() async {
    final db = await _getDb();
    final unprocessedJobs = await db.transaction<List<Map<String, dynamic>>>((txn) async {
      final whereUnlocked = _lockedQuery(false, selectFields: HTTP_JOBS_LOCKED_COLUMN, limit: 0);
      final whereLocked = _lockedQuery(true, limit: 1);

      // lock all unlocked requests for idempotency
      await txn.rawUpdate([
        'UPDATE $HTTP_JOBS_TABLE_NAME',
        'SET $HTTP_JOBS_LOCKED_COLUMN = 1',
        'WHERE $HTTP_JOBS_LOCKED_COLUMN IN ($whereUnlocked);',
      ].join(' '));

      return txn.rawQuery('$whereLocked;');
    });

    final jobs = unprocessedJobs.map(RequestSqliteCache.sqliteToRequest).cast<http.Request>();

    if (jobs?.isEmpty == false) return jobs.first;

    return null;
  }

  /// Prepare schema.
  Future<void> migrate() async {
    final statement = '''
      CREATE TABLE IF NOT EXISTS `$HTTP_JOBS_TABLE_NAME` (
        `$HTTP_JOBS_PRIMARY_KEY_COLUMN` INTEGER PRIMARY KEY AUTOINCREMENT,
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
    final db = await _getDb();
    return await db.execute(statement);
  }

  /// Returns row data for all unprocessed job in database.
  /// Accessing this list can be useful determining queue length.
  ///
  /// When [whereLocked] is `true`, only jobs that are not actively being processed are returned.
  /// Accessing this sublist can be useful for deleting a job blocking the queue.
  /// Defaults `false`.
  Future<List<Map<String, dynamic>>> unprocessedJobs({bool whereLocked = false}) async {
    final db = await _getDb();

    if (whereLocked) {
      return await db.query(
        HTTP_JOBS_TABLE_NAME,
        distinct: true,
        orderBy: '$HTTP_JOBS_UPDATED_AT ASC',
        where: '$HTTP_JOBS_LOCKED_COLUMN = ?',
        whereArgs: [1],
      );
    }

    return await db.query(
      HTTP_JOBS_TABLE_NAME,
      distinct: true,
      orderBy: '$HTTP_JOBS_UPDATED_AT ASC',
    );
  }
}

const HTTP_JOBS_TABLE_NAME = 'HttpJobs';

const HTTP_JOBS_PRIMARY_KEY_COLUMN = 'id';
const HTTP_JOBS_ATTEMPTS_COLUMN = 'attempts';
const HTTP_JOBS_BODY_COLUMN = 'body';
const HTTP_JOBS_ENCODING_COLUMN = 'encoding';
const HTTP_JOBS_HEADERS_COLUMN = 'headers';
const HTTP_JOBS_LOCKED_COLUMN = 'locked';
const HTTP_JOBS_REQUEST_METHOD_COLUMN = 'request_method';
const HTTP_JOBS_UPDATED_AT = 'updated_at';
const HTTP_JOBS_URL_COLUMN = 'url';

/// Generate SQLite query for [prepareNextRequestToProcess].
/// When [limit] is `<= 0`, all results are returned
String _lockedQuery(bool whereIsLocked, {String selectFields = '*', int limit = 1}) {
  return [
    'SELECT DISTINCT',
    selectFields,
    'FROM $HTTP_JOBS_TABLE_NAME',
    'WHERE $HTTP_JOBS_LOCKED_COLUMN = ${whereIsLocked ? 1 : 0}',
    'ORDER BY $HTTP_JOBS_UPDATED_AT ASC',
    if (limit > 0) 'LIMIT $limit'
  ].join(' ');
}
