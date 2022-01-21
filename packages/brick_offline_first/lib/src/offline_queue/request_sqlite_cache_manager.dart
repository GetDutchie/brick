// ignore_for_file: constant_identifier_names
import 'package:brick_offline_first/src/offline_queue/rest_request_sqlite_cache.dart';
import 'package:sqflite/sqflite.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:meta/meta.dart';

/// Fetch and delete [RequestSqliteCache]s.
abstract class RequestSqliteCacheManager<_RequestMethod> {
  /// Access the [SQLite](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi),
  /// instance agnostically across platforms. If [databaseFactory] is null, the default
  /// Flutter SQFlite will be used.
  @protected
  final DatabaseFactory? databaseFactory;

  /// The file name for the database used.
  ///
  /// When [databaseFactory] is present, this is the **entire** path name.
  /// With [databaseFactory], this is most commonly the
  /// `sqlite_common` constant `inMemoryDatabasePath`.
  final String createdAtColumn;
  final String databaseName;
  final String lockedColumn;
  final String primaryKeyColumn;
  final String updateAtColumn;

  Future<Database>? _db;

  final String tableName;

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

  RequestSqliteCacheManager(
    this.databaseName, {
    required this.createdAtColumn,
    required this.lockedColumn,
    required this.primaryKeyColumn,
    required this.tableName,
    required this.updateAtColumn,
    this.databaseFactory,
    this.processingInterval = const Duration(seconds: 5),
    this.serialProcessing = true,
  });

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

  Future<Database> getDb() {
    if (_db == null) {
      if (databaseFactory != null) {
        _db = databaseFactory?.openDatabase(databaseName);
      } else {
        _db = openDatabase(databaseName);
      }
    }

    return _db!;
  }

  /// Prepare schema.
  Future<void> migrate();

  /// Discover most recent unprocessed job in database convert it back to an HTTP request.
  /// This method also locks the row to make it idempotent to subsequent processing.
  Future<List<Map<String, dynamic>>> findNextRequestToProcess() async {
    final db = await getDb();
    return await db.transaction<List<Map<String, dynamic>>>((txn) async {
      final latestLockedRequests = await _latestRequest(txn, whereLocked: true);

      if (latestLockedRequests.isNotEmpty) {
        // ensure that if the request is longer the 2 minutes old it's unlocked automatically
        final request = latestLockedRequests.first;
        final requestManager = RestRequestSqliteCache(request: request);
        final lastUpdated = DateTime.fromMillisecondsSinceEpoch(request[updateAtColumn]);
        final twoMinutesAgo = DateTime.now().subtract(const Duration(minutes: 2));
        if (lastUpdated.isBefore(twoMinutesAgo)) {
          await requestManager.unlockRequest(request, txn);
        }
        if (serialProcessing) return [];
      }

      // Find the latest unlocked request
      final unlockedRequests = await _latestRequest(txn, whereLocked: false);
      if (unlockedRequests.isEmpty) return [];
      final requestManager = RestRequestSqliteCache(request: unlockedRequests);
      // lock the latest unlocked request
      await requestManager.lockRequest(unlockedRequests.first, txn);

      // return the next unlocked request (now locked)
      return unlockedRequests;
    });
  }

  Future<_RequestMethod?> prepareNextRequestToProcess();

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
      whereArgs: [whereLocked ? 1 : 0, nowMinusNextPoll],
      orderBy: orderByStatement,
      limit: 1,
    );
  }
}
