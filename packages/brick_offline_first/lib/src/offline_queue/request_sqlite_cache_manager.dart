import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
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

  Future<Database> _db;

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
    this.processingInterval = const Duration(seconds: 5),
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
      final latestLockedRequests = await _latestRequest(txn, whereLocked: true);

      final atLeastOneRequestIsLocked = latestLockedRequests?.isNotEmpty ?? false;

      if (atLeastOneRequestIsLocked) {
        final lastUpdated = DateTime.parse(latestLockedRequests.first[HTTP_JOBS_UPDATED_AT]);
        if (lastUpdated.isBefore(DateTime.now().subtract(Duration(minutes: 2)))) {
          await RequestSqliteCache.unlockRequest(latestLockedRequests.first, txn);
        } else {
          return [];
        }
        if (serialProcessing) return [];
      }

      // Find the latest unlocked request
      final unlockedRequests = await _latestRequest(txn, whereLocked: false);
      if (unlockedRequests?.isEmpty ?? true) return [];
      // lock the latest unlocked request
      await _lockRequest(txn, unlockedRequests.first);

      // return the next unlocked request (now locked)
      return unlockedRequests;
    });

    final jobs = unprocessedRequests.map(RequestSqliteCache.sqliteToRequest).cast<http.Request>();

    if (jobs?.isEmpty ?? true) return null;

    // lock the request for idempotency

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

  Future<Database> getDb() {
    if (_db == null) {
      if (databaseFactory != null) {
        _db = databaseFactory.openDatabase(databaseName);
      } else {
        _db = openDatabase(databaseName);
      }
    }

    return _db;
  }

  Future<List<Map<String, dynamic>>> _latestRequest(
    DatabaseExecutor txn, {
    @required bool whereLocked,
  }) async {
    /// Ensure that a request that's immediately attempted and stored is not immediately
    /// reattempted by the queue interval before an HTTP response is received.
    final nowMinusNextPoll =
        DateTime.now().millisecondsSinceEpoch - processingInterval.inMilliseconds;

    return await txn.query(
      HTTP_JOBS_TABLE_NAME,
      distinct: true,
      where: '$HTTP_JOBS_LOCKED_COLUMN = ? AND $HTTP_JOBS_CREATED_AT_COLUMN = ?',
      whereArgs: [whereLocked ? 1 : 0, nowMinusNextPoll],
      orderBy: orderByStatement,
      limit: 1,
    );
  }

  Future<void> _lockRequest(DatabaseExecutor txn, Map<String, dynamic> request) async {
    await txn.update(
      HTTP_JOBS_TABLE_NAME,
      {
        HTTP_JOBS_LOCKED_COLUMN: 1,
      },
      where: '$HTTP_JOBS_PRIMARY_KEY_COLUMN = ?',
      whereArgs: [request[HTTP_JOBS_PRIMARY_KEY_COLUMN]],
    );
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
