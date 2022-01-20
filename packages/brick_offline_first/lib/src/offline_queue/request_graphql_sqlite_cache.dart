import 'dart:convert';
import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache_manager.dart';
import 'package:graphql/client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

/// Serialize and Deserialize a [http.Request] from SQLite.
class RequestGraphqlSqliteCache {
  final Request request;

  RequestGraphqlSqliteCache(this.request);

  /// Removes the request from the database and thus the queue
  Future<int> delete(Database db) async {
    final response = await findRequestInDatabase(db);

    if (response != null && response.isNotEmpty) {
      return await db.transaction((txn) async {
        return await txn.delete(
          GRAPHQL_JOB_TABLE_NAME,
          where: '$GRAPHQL_JOB_PRIMARY_KEY_COLUMN = ?',
          whereArgs: [response[GRAPHQL_JOB_PRIMARY_KEY_COLUMN]],
        );
      });
    }

    return 0;
  }

  @protected
  Future<Map<String, dynamic>?> findRequestInDatabase(DatabaseExecutor db) async {
    final columns = [
      GRAPHQL_JOB_DOCUMENT_COLUMN,
      GRAPHQL_JOB_VARIABLES_COLUMN,
      GRAPHQL_JOB_OPERATION_NAME_COLUMN,
    ];

    final whereStatement = columns.join(' = ? AND ');
    final serialized = toSqlite();

    final response = await db.query(
      GRAPHQL_JOB_TABLE_NAME,
      where: '$whereStatement = ?',
      whereArgs: columns.map((c) => serialized[c]).toList(),
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
        serialized[GRAPHQL_JOB_LOCKED_COLUMN] = 1;

        logger?.fine('adding to queue: $serialized');
        return await txn.insert(
          GRAPHQL_JOB_TABLE_NAME,
          serialized,
        );
      }
      final methodWithUrl = [
        response[GRAPHQL_JOB_OPERATION_NAME_COLUMN],
      ].join(' ');
      logger?.warning(
          'failed, attempt #${response[GRAPHQL_JOB_ATTEMPTS_COLUMN]} in $methodWithUrl : $response');
      return await txn.update(
        GRAPHQL_JOB_TABLE_NAME,
        {
          GRAPHQL_JOB_ATTEMPTS_COLUMN: response[GRAPHQL_JOB_ATTEMPTS_COLUMN] + 1,
          GRAPHQL_JOB_UPDATED_AT: DateTime.now().millisecondsSinceEpoch,
          GRAPHQL_JOB_LOCKED_COLUMN: 1,
        },
        where: '$GRAPHQL_JOB_PRIMARY_KEY_COLUMN = ?',
        whereArgs: [response[GRAPHQL_JOB_PRIMARY_KEY_COLUMN]],
      );
    });
  }

  /// Builds request into a new SQLite-insertable row
  /// Only available if [request] was initialized from [fromRequest]
  ///
  /// This is a function to ensure `DateTime.now()` is invoked predictably.
  Map<String, dynamic> toSqlite() {
    return {
      GRAPHQL_JOB_ATTEMPTS_COLUMN: 1,
      GRAPHQL_JOB_DOCUMENT_COLUMN: request.operation.document.toString(),
      GRAPHQL_JOB_VARIABLES_COLUMN: request.variables.toString(),
      GRAPHQL_JOB_CREATED_AT_COLUMN: DateTime.now().millisecondsSinceEpoch,
      GRAPHQL_JOB_OPERATION_NAME_COLUMN: request.operation.operationName.toString(),
      GRAPHQL_JOB_UPDATED_AT: DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// If the request did not succeed, unlock for subsequent processing
  Future<int?> unlock(Database db) async {
    return await db.transaction((txn) async {
      final response = await findRequestInDatabase(txn);
      if (response == null) return null;
      return await unlockRequest(response, txn);
    });
  }

  static Future<int> lockRequest(Map<String, dynamic> data, DatabaseExecutor db) async =>
      await _updateLock(true, data, db);

  /// Recreate a request from SQLite data
  static Request sqliteToRequest(Map<String, dynamic> data) {
    final document = gql(data[GRAPHQL_JOB_DOCUMENT_COLUMN]);
    final operationName = data[GRAPHQL_JOB_OPERATION_NAME_COLUMN];
    final variables = jsonDecode(data[GRAPHQL_JOB_VARIABLES_COLUMN]);

    final operation = Operation(document: document, operationName: operationName);
    return Request(variables: variables, operation: operation);
  }

  static Future<int> unlockRequest(Map<String, dynamic> data, DatabaseExecutor db) async =>
      await _updateLock(false, data, db);
}

Future<int> _updateLock(
  bool shouldLock,
  Map<String, dynamic> data,
  DatabaseExecutor db,
) async {
  return await db.update(
    GRAPHQL_JOB_TABLE_NAME,
    {
      GRAPHQL_JOB_LOCKED_COLUMN: shouldLock ? 1 : 0,
    },
    where: '$GRAPHQL_JOB_PRIMARY_KEY_COLUMN = ?',
    whereArgs: [data[GRAPHQL_JOB_PRIMARY_KEY_COLUMN]],
  );
}
