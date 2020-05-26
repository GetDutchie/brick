import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:path/path.dart' as p;
import 'package:meta/meta.dart';

/// Fetch and delete [RequestSqliteCache]s.
class RequestSqliteCacheManager {
  /// Access the [SQLite](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi),
  /// instance agnostically across platforms. If [databaseFactory] is null, the default
  /// Flutter SQFlite will be used.
  @protected
  final DatabaseFactory databaseFactory;

  /// The file name for the database used.
  ///
  /// When [databaseFactory] is present, this is the **entire** path name.
  /// With [databaseFactory], this is most commonly the
  /// `sqlite_common` constant `inMemoryDatabasePath`.
  final String databaseName;

  Database _db;

  String get orderByStatement {
    if (!serialProcessing) {
      return '$HTTP_JOBS_UPDATED_AT ASC';
    }

    // TODO: change to '$HTTP_JOBS_CREATED_AT_COLUMN ASC' for first major release
    return '$HTTP_JOBS_CREATED_AT_COLUMN ASC, $HTTP_JOBS_ATTEMPTS_COLUMN DESC, $HTTP_JOBS_UPDATED_AT ASC';
  }

  /// Time between attempts to resubmit a request. Defaults to 5 seconds.
  final Duration processingInterval;

  /// When `true`, results are processed one at a time in the order in which they were created.
  /// Defaults `true`.
  final bool serialProcessing;

  RequestSqliteCacheManager(
    this.databaseName, {
    this.databaseFactory,
    this.processingInterval = DEFAUT_PROCESSING_INTERVAL,
    this.serialProcessing = true,
  });

  /// Delete job in queue. **This is a destructive action and cannot be undone**.
  /// [id] is retrieved from the [HTTP_JOBS_PRIMARY_KEY_COLUMN].
  ///
  /// Returns `false` if [id] could not be found;
  /// returns `true` if the request was deleted.
  Future<bool> deleteUnprocessedRequest(int id) async {
    final db = await getDb();

    final result = await db.delete(
      HTTP_JOBS_TABLE_NAME,
      where: '$HTTP_JOBS_PRIMARY_KEY_COLUMN = ?',
      whereArgs: [id],
    );

    return result > 0;
  }

  /// Discover most recent unprocessed job in database convert it back to an HTTP request.
  /// This method also locks the row to make it idempotent to subsequent processing.
  Future<http.Request> prepareNextRequestToProcess() async {
    final db = await getDb();
    final unprocessedRequests = await db.transaction<List<Map<String, dynamic>>>((txn) async {
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

    final jobs = unprocessedRequests.map(RequestSqliteCache.sqliteToRequest).cast<http.Request>();

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
    final db = await getDb();
    await db.execute(statement);

    final tableInfo = await db.rawQuery('PRAGMA table_info("$HTTP_JOBS_TABLE_NAME");');
    final createdAtHasBeenMigrated =
        tableInfo.contains((c) => c['name'] == HTTP_JOBS_CREATED_AT_COLUMN);
    if (!createdAtHasBeenMigrated) {
      await db.execute(
          'ALTER TABLE `$HTTP_JOBS_TABLE_NAME` ADD `$HTTP_JOBS_CREATED_AT_COLUMN` INTEGER DEFAULT 0');
    }
  }

  /// Returns row data for all unprocessed job in database.
  /// Accessing this list can be useful determining queue length.
  ///
  /// When [whereLocked] is `true`, only jobs that are not actively being processed are returned.
  /// Accessing this sublist can be useful for deleting a job blocking the queue.
  /// Defaults `false`.
  Future<List<Map<String, dynamic>>> unprocessedRequests({bool whereLocked = false}) async {
    final db = await getDb();

    if (whereLocked) {
      return await db.query(
        HTTP_JOBS_TABLE_NAME,
        distinct: true,
        orderBy: orderByStatement,
        where: '$HTTP_JOBS_LOCKED_COLUMN = ?',
        whereArgs: [1],
      );
    }

    return await db.query(
      HTTP_JOBS_TABLE_NAME,
      distinct: true,
      orderBy: orderByStatement,
    );
  }

  /// Generate SQLite query for [prepareNextRequestToProcess].
  /// When [limit] is `<= 0`, all results are returned
  String _lockedQuery(
    bool whereIsLocked, {
    int limit = 1,
    String selectFields = '*',
  }) {
    // Ensure that a request that's immediately attempted and stored is not immediately
    // reattempted by the queue interval before an HTTP response is received.
    final nowMinusNextPoll =
        DateTime.now().millisecondsSinceEpoch - processingInterval.inMilliseconds;
    return [
      'SELECT DISTINCT',
      selectFields,
      'FROM $HTTP_JOBS_TABLE_NAME',
      'WHERE $HTTP_JOBS_LOCKED_COLUMN = ${whereIsLocked ? 1 : 0}',
      'AND $HTTP_JOBS_CREATED_AT_COLUMN < $nowMinusNextPoll',
      'ORDER BY $orderByStatement',
      if (limit > 0) 'LIMIT $limit'
    ].join(' ');
  }

  Future<Database> getDb() async {
    if (_db?.isOpen == true) return _db;

    if (databaseFactory != null) {
      return _db = await databaseFactory.openDatabase(databaseName);
    }

    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, databaseName);

    return _db = await openDatabase(path);
  }
}

const HTTP_JOBS_TABLE_NAME = 'HttpJobs';

const HTTP_JOBS_PRIMARY_KEY_COLUMN = 'id';
const HTTP_JOBS_ATTEMPTS_COLUMN = 'attempts';
const HTTP_JOBS_BODY_COLUMN = 'body';
const HTTP_JOBS_CREATED_AT_COLUMN = 'created_at';
const HTTP_JOBS_ENCODING_COLUMN = 'encoding';
const HTTP_JOBS_HEADERS_COLUMN = 'headers';
const HTTP_JOBS_LOCKED_COLUMN = 'locked';
const HTTP_JOBS_REQUEST_METHOD_COLUMN = 'request_method';
const HTTP_JOBS_UPDATED_AT = 'updated_at';
const HTTP_JOBS_URL_COLUMN = 'url';

const DEFAUT_PROCESSING_INTERVAL = Duration(seconds: 5);
