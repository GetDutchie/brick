// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:graphql/client.dart';

class RequestGraphqlSqliteCacheManager extends RequestSqliteCacheManager<Request> {
  RequestGraphqlSqliteCacheManager(String databaseName)
      : super(databaseName,
            tableName: GRAPHQL_JOB_TABLE_NAME,
            createdAtColumn: GRAPHQL_JOB_CREATED_AT_COLUMN,
            primaryKeyColumn: GRAPHQL_JOB_PRIMARY_KEY_COLUMN,
            lockedColumn: GRAPHQL_JOB_LOCKED_COLUMN,
            updateAtColumn: GRAPHQL_JOB_UPDATED_AT);

  @override
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

  @override
  Future<Request?> prepareNextRequestToProcess() async {
    final unprocessedRequests = await findNextRequestToProcess();
    final jobs = unprocessedRequests.map((data) => sqliteToRequest(data)).cast<Request>();

    if (jobs.isNotEmpty) return jobs.first;

    // lock the request for idempotency

    return null;
  }

  /// Recreate a request from SQLite data
  Request sqliteToRequest(Map<String, dynamic> data) {
    final document = gql(data[GRAPHQL_JOB_DOCUMENT_COLUMN]);
    final operationName = data[GRAPHQL_JOB_OPERATION_NAME_COLUMN];
    final variables = jsonDecode(data[GRAPHQL_JOB_VARIABLES_COLUMN]);

    final operation = Operation(document: document, operationName: operationName);
    return Request(variables: variables, operation: operation);
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
const GRAPHQL_JOB_OPERATION_NAME_COLUMN = 'name';

/// int; millisecondsSinceEpoch
const GRAPHQL_JOB_UPDATED_AT = 'updated_at';
