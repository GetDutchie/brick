import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:meta/meta.dart';
import 'package:sqflite_common/sqlite_api.dart' show Database, DatabaseExecutor, DatabaseFactory;

/// Fetch and delete [RequestSqliteCache]s.
abstract class RequestSqliteCacheManager<RequestMethod> {
  /// Access the [SQLite](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi),
  /// instance agnostically across platforms.
  @protected
  final DatabaseFactory databaseFactory;

  /// The file name for the database used.
  ///
  /// When [databaseFactory] is present, this is the **entire** path name.
  /// With [databaseFactory], this is most commonly the
  /// `sqlite_common` constant `inMemoryDatabasePath`.
  final String createdAtColumn;

  /// Database file path
  final String databaseName;

  /// Column that tracks if the request is locked
  final String lockedColumn;

  /// Column that tracks the primary key
  final String primaryKeyColumn;

  ///
  final String updateAtColumn;

  Future<Database>? _db;

  ///
  final String tableName;

  ///
  String get orderByStatement {
    if (!serialProcessing) {
      return '$updateAtColumn ASC';
    }

    return '$createdAtColumn ASC';
  }

  /// Time between attempts to resubmit a request. Defaults to 5 seconds.
  final Duration processingInterval;

  /// When `true`, results are processed one at a time in the order in which they were created.
  /// Defaults `true`.
  final bool serialProcessing;

  /// Fetch and delete [RequestSqliteCache]s.
  RequestSqliteCacheManager(
    this.databaseName, {
    required this.createdAtColumn,
    required this.databaseFactory,
    required this.lockedColumn,
    required this.primaryKeyColumn,
    Duration? processingInterval,
    this.serialProcessing = true,
    required this.tableName,
    required this.updateAtColumn,
  }) : processingInterval = processingInterval ?? const Duration(seconds: 5);

  /// Delete job in queue. **This is a destructive action and cannot be undone**.
  /// [id] is retrieved from the [primaryKeyColumn].
  ///
  /// Returns `false` if [id] could not be found;
  /// returns `true` if the request was deleted.
  Future<bool> deleteUnprocessedRequest(int id) async {
    final db = await getDb();

    final result = await db.delete(
      tableName,
      where: '$primaryKeyColumn = ?',
      whereArgs: [id],
    );

    return result > 0;
  }

  ///
  Future<Database> getDb() {
    _db ??= databaseFactory.openDatabase(databaseName);

    return _db!;
  }

  /// Prepare schema.
  Future<void> migrate();

  /// Discover most recent unprocessed job in database convert it back to an HTTP request.
  /// This method also locks the row to make it idempotent to subsequent processing.
  Future<RequestMethod?> prepareNextRequestToProcess() async {
    final db = await getDb();
    final unprocessedRequests = await db.transaction<List<Map<String, dynamic>>>((txn) async {
      final latestLockedRequests = await _latestRequest(txn, whereLocked: true);

      if (latestLockedRequests.isNotEmpty) {
        // ensure that if the request is longer the 2 minutes old it's unlocked automatically
        final lastUpdated =
            DateTime.fromMillisecondsSinceEpoch(latestLockedRequests.first[updateAtColumn]);
        final twoMinutesAgo = DateTime.now().subtract(const Duration(minutes: 2));
        if (lastUpdated.isBefore(twoMinutesAgo)) {
          await RequestSqliteCache.unlockRequest(
            data: latestLockedRequests.first,
            db: txn,
            lockedColumn: lockedColumn,
            primaryKeyColumn: primaryKeyColumn,
            tableName: tableName,
          );
        }
        if (serialProcessing) return [];
      }

      // Find the latest unlocked request
      final unlockedRequests = await _latestRequest(txn, whereLocked: false);
      if (unlockedRequests.isEmpty) return [];
      // lock the latest unlocked request
      await RequestSqliteCache.lockRequest(
        data: unlockedRequests.first,
        db: txn,
        lockedColumn: lockedColumn,
        primaryKeyColumn: primaryKeyColumn,
        tableName: tableName,
      );
      // return the next unlocked request (now locked)
      return unlockedRequests;
    });

    final jobs = unprocessedRequests.map(sqliteToRequest).cast<RequestMethod>();

    if (jobs.isNotEmpty) return jobs.first;

    // lock the request for idempotency

    return null;
  }

  Future<List<Map<String, dynamic>>> _latestRequest(
    DatabaseExecutor txn, {
    required bool whereLocked,
  }) async {
    /// Ensure that a request that's immediately attempted and stored is not immediately
    /// reattempted by the queue interval before an HTTP response is received.
    final nowMinusNextPoll =
        DateTime.now().millisecondsSinceEpoch - processingInterval.inMilliseconds;

    return await txn.query(
      tableName,
      distinct: true,
      where: '$lockedColumn = ? AND $createdAtColumn <= ?',
      whereArgs: [if (whereLocked) 1 else 0, nowMinusNextPoll],
      orderBy: orderByStatement,
      limit: 1,
    );
  }

  /// Builds a client-consumable [RequestMethod] from SQLite row output
  RequestMethod? sqliteToRequest(Map<String, dynamic> data);

  /// Returns row data for all unprocessed job in database.
  /// Accessing this list can be useful determining queue length.
  ///
  /// When [onlyLocked] is `true`, only jobs that are not actively being processed are returned.
  /// Accessing this sublist can be useful for deleting a job blocking the queue.
  /// Defaults `false`.
  Future<List<Map<String, dynamic>>> unprocessedRequests({bool onlyLocked = false}) async {
    final db = await getDb();

    if (onlyLocked) {
      return await db.query(
        tableName,
        distinct: true,
        orderBy: orderByStatement,
        where: '$lockedColumn = ?',
        whereArgs: [1],
      );
    }

    return await db.query(
      tableName,
      distinct: true,
      orderBy: orderByStatement,
    );
  }
}
