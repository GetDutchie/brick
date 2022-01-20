// ignore_for_file: constant_identifier_names

import 'package:sqflite/sqflite.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';
import 'package:meta/meta.dart';
import 'package:graphql/client.dart';

/// Fetch and delete [RequestSqliteCache]s.
class RequestGrapqQLSqliteCacheManager {
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
  final String databaseName;

  Future<Database>? _db;

  String get orderByStatement {
    if (!serialProcessing) {
      return '$GRAPHQL_JOB_UPDATED_AT ASC';
    }

    return '$GRAPHQL_JOB_CREATED_AT_COLUMN ASC';
  }

  /// Time between attempts to resubmit a request. Defaults to 5 seconds.
  final Duration processingInterval;

  /// When `true`, results are processed one at a time in the order in which they were created.
  /// Defaults `true`.
  final bool serialProcessing;

  RequestGrapqQLSqliteCacheManager(
    this.databaseName, {
    this.databaseFactory,
    this.processingInterval = const Duration(seconds: 5),
    this.serialProcessing = true,
  });

  /// Delete job in queue. **This is a destructive action and cannot be undone**.
  /// [id] is retrieved from the [GRAPHQL_JOB_PRIMARY_KEY_COLUMN].
  ///
  /// Returns `false` if [id] could not be found;
  /// returns `true` if the request was deleted.
  Future<bool> deleteUnprocessedRequest(int id) async {
    final db = await getDb();

    final result = await db.delete(
      GRAPHQL_JOB_TABLE_NAME,
      where: '$GRAPHQL_JOB_PRIMARY_KEY_COLUMN = ?',
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
  Future<void> migrate() async {
    const statement = '''
      CREATE TABLE IF NOT EXISTS `$GRAPHQL_JOB_TABLE_NAME` (
        `$GRAPHQL_JOB_PRIMARY_KEY_COLUMN` INTEGER PRIMARY KEY AUTOINCREMENT,
        `$GRAPHQL_JOB_ATTEMPTS_COLUMN` INTEGER DEFAULT 1,
        `$GRAPHQL_JOB_DOCUMENT_COLUMN` TEXT,
        `$GRAPHQL_JOB_VARIABLES_COLUMN` TEXT,
        `$GRAPHQL_JOB_LOCKED_COLUMN` INTEGER DEFAULT 0,
        `$GRAPHQL_JOB_OPERATION_NAME_COLUMN` TEXT,
        `$GRAPHQL_JOB_UPDATED_AT` INTEGER DEFAULT 0,
        `$GRAPHQL_JOB_OPERATION_TYPE_COLUMN   ` TEXT,
        `$GRAPHQL_JOB_CREATED_AT_COLUMN` INTEGER DEFAULT 0
      );
    ''';
    final db = await getDb();
    await db.execute(statement);

    final tableInfo = await db.rawQuery('PRAGMA table_info("$GRAPHQL_JOB_TABLE_NAME");');
    final createdAtHasBeenMigrated =
        tableInfo.any((c) => c['name'] == GRAPHQL_JOB_CREATED_AT_COLUMN);
    if (!createdAtHasBeenMigrated) {
      await db.execute(
          'ALTER TABLE `$GRAPHQL_JOB_TABLE_NAME` ADD `$GRAPHQL_JOB_CREATED_AT_COLUMN` INTEGER DEFAULT 0');
    }
  }

  /// Discover most recent unprocessed job in database convert it back to an HTTP request.
  /// This method also locks the row to make it idempotent to subsequent processing.
  Future<Request?> prepareNextRequestToProcess() async {
    final db = await getDb();
    final unprocessedRequests = await db.transaction<List<Map<String, dynamic>>>((txn) async {
      final latestLockedRequests = await _latestRequest(txn, whereLocked: true);

      if (latestLockedRequests.isNotEmpty) {
        // ensure that if the request is longer the 2 minutes old it's unlocked automatically
        final lastUpdated =
            DateTime.fromMillisecondsSinceEpoch(latestLockedRequests.first[GRAPHQL_JOB_UPDATED_AT]);
        final twoMinutesAgo = DateTime.now().subtract(const Duration(minutes: 2));
        if (lastUpdated.isBefore(twoMinutesAgo)) {
          await RequestSqliteCache.unlockRequest(latestLockedRequests.first, txn);
        }
        if (serialProcessing) return [];
      }

      // Find the latest unlocked request
      final unlockedRequests = await _latestRequest(txn, whereLocked: false);
      if (unlockedRequests.isEmpty) return [];
      // lock the latest unlocked request
      await RequestSqliteCache.lockRequest(unlockedRequests.first, txn);

      // return the next unlocked request (now locked)
      return unlockedRequests;
    });

    final jobs = unprocessedRequests.map(RequestSqliteCache.sqliteToRequest).cast<Request>();

    if (jobs.isNotEmpty) return jobs.first;

    // lock the request for idempotency

    return null;
  }

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
        GRAPHQL_JOB_TABLE_NAME,
        distinct: true,
        orderBy: orderByStatement,
        where: '$GRAPHQL_JOB_LOCKED_COLUMN = ?',
        whereArgs: [1],
      );
    }

    return await db.query(
      GRAPHQL_JOB_TABLE_NAME,
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
      GRAPHQL_JOB_TABLE_NAME,
      distinct: true,
      where: '$GRAPHQL_JOB_LOCKED_COLUMN = ? AND $GRAPHQL_JOB_CREATED_AT_COLUMN <= ?',
      whereArgs: [whereLocked ? 1 : 0, nowMinusNextPoll],
      orderBy: orderByStatement,
      limit: 1,
    );
  }
}

const GRAPHQL_JOB_TABLE_NAME = 'GraphqlJobs';

/// int; autoincrement'd
const GRAPHQL_JOB_PRIMARY_KEY_COLUMN = 'id';

/// int
const GRAPHQL_JOB_ATTEMPTS_COLUMN = 'attempts';

/// int; millisecondsSinceEpoch
const GRAPHQL_JOB_CREATED_AT_COLUMN = 'created_at';

/// String
const GRAPHQL_JOB_DOCUMENT_COLUMN = 'graphql_document';

/// json-encoded String
const GRAPHQL_JOB_VARIABLES_COLUMN = 'varibles';

/// int; 1 for true, 0 for false
const GRAPHQL_JOB_LOCKED_COLUMN = 'locked';

/// String
const GRAPHQL_JOB_OPERATION_TYPE_COLUMN = 'operation_type';

/// String
const GRAPHQL_JOB_OPERATION_NAME_COLUMN = 'name';

/// int; millisecondsSinceEpoch
const GRAPHQL_JOB_UPDATED_AT = 'updated_at';
