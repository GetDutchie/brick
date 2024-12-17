import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:sqflite_common/sqlite_api.dart' show Database, DatabaseExecutor;

/// Serialize and Deserialize a [TRequest] from SQLite.
abstract class RequestSqliteCache<TRequest> {
  /// Column that tracks the number of attempts
  final String attemptColumn;

  ///
  final String createdAtColumn;

  /// Column that tracks if the request is locked
  final String lockedColumn;

  /// Column that tracks the primary key
  final String primaryKeyColumn;

  ///
  final TRequest request;

  /// Columns used to uniquely identify the request (e.g. body, headers, url, method).
  final List<String> requestColumns;

  ///
  final String tableName;

  ///
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

  /// The log output before each attempt
  String attemptLogMessage(Map<String, dynamic> responseFromSqlite);

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

  ///
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

      logger?.warning('failed, attempt #${response[attemptColumn]} ${attemptLogMessage(response)}');

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

  /// Builds SQLite-row into a [request]
  TRequest sqliteToRequest(Map<String, dynamic> data);

  /// Builds request into a new SQLite-insertable row
  /// Only available if [request] was initialized from [sqliteToRequest]
  ///
  /// This is a function to ensure `DateTime.now()` is invoked predictably.
  Map<String, dynamic> toSqlite();

  /// If the request did not succeed, unlock for subsequent processing
  Future<int?> unlock(Database db) async {
    return await db.transaction((txn) async {
      final response = await findRequestInDatabase(txn);
      if (response == null) return null;
      return await unlockRequest(
        data: response,
        db: txn,
        lockedColumn: lockedColumn,
        primaryKeyColumn: primaryKeyColumn,
        tableName: tableName,
      );
    });
  }

  ///
  static Future<int> lockRequest({
    required DatabaseExecutor db,
    required Map<String, dynamic> data,
    required String lockedColumn,
    required String primaryKeyColumn,
    required String tableName,
  }) async =>
      await _updateLock(true, data, db, tableName, lockedColumn, primaryKeyColumn);

  ///
  static Future<int> unlockRequest({
    required DatabaseExecutor db,
    required Map<String, dynamic> data,
    required String lockedColumn,
    required String primaryKeyColumn,
    required String tableName,
  }) async =>
      await _updateLock(false, data, db, tableName, lockedColumn, primaryKeyColumn);

  static Future<int> _updateLock(
    bool shouldLock,
    Map<String, dynamic> data,
    DatabaseExecutor db,
    String tableName,
    String lockedColumn,
    String primaryKeyColumn,
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
