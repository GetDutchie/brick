// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:brick_offline_first/offline_queue.dart';
import 'package:gql/language.dart' as lang;
import 'package:gql_exec/gql_exec.dart';

/// GraphQL implementation of [RequestSqliteCacheManager]
class GraphqlRequestSqliteCacheManager extends RequestSqliteCacheManager<Request> {
  /// GraphQL implementation of [RequestSqliteCacheManager]
  GraphqlRequestSqliteCacheManager(
    super.databaseName, {
    required super.databaseFactory,
    super.processingInterval,
    bool? serialProcessing,
  }) : super(
          createdAtColumn: GRAPHQL_JOBS_CREATED_AT_COLUMN,
          lockedColumn: GRAPHQL_JOBS_LOCKED_COLUMN,
          primaryKeyColumn: GRAPHQL_JOBS_PRIMARY_KEY_COLUMN,
          serialProcessing: serialProcessing ?? true,
          tableName: GRAPHQL_JOBS_TABLE_NAME,
          updateAtColumn: GRAPHQL_JOBS_UPDATED_AT,
        );

  @override
  Future<void> migrate() async {
    const statement = '''
      CREATE TABLE IF NOT EXISTS `$GRAPHQL_JOBS_TABLE_NAME` (
        `$GRAPHQL_JOBS_PRIMARY_KEY_COLUMN` INTEGER PRIMARY KEY AUTOINCREMENT,
        `$GRAPHQL_JOBS_ATTEMPTS_COLUMN` INTEGER DEFAULT 1,
        `$GRAPHQL_JOBS_DOCUMENT_COLUMN` TEXT,
        `$GRAPHQL_JOBS_VARIABLES_COLUMN` TEXT,
        `$GRAPHQL_JOBS_LOCKED_COLUMN` INTEGER DEFAULT 0,
        `$GRAPHQL_JOBS_OPERATION_NAME_COLUMN` TEXT,
        `$GRAPHQL_JOBS_UPDATED_AT` INTEGER DEFAULT 0,
        `$GRAPHQL_JOBS_CREATED_AT_COLUMN` INTEGER DEFAULT 0
      );
    ''';
    final db = await getDb();
    await db.execute(statement);
  }

  /// Recreate a request from SQLite data
  @override
  Request sqliteToRequest(Map<String, dynamic> data) {
    final document = lang.parseString(data[GRAPHQL_JOBS_DOCUMENT_COLUMN]);
    final operationName = data[GRAPHQL_JOBS_OPERATION_NAME_COLUMN];
    final variables = jsonDecode(data[GRAPHQL_JOBS_VARIABLES_COLUMN]);

    final operation = Operation(document: document, operationName: operationName);
    return Request(variables: variables, operation: operation);
  }
}

/// int
const GRAPHQL_JOBS_ATTEMPTS_COLUMN = 'attempts';

/// int; millisecondsSinceEpoch
const GRAPHQL_JOBS_CREATED_AT_COLUMN = 'created_at';

/// String
const GRAPHQL_JOBS_DOCUMENT_COLUMN = 'graphql_document';

/// int; 1 for true, 0 for false
const GRAPHQL_JOBS_LOCKED_COLUMN = 'locked';

/// String
const GRAPHQL_JOBS_OPERATION_NAME_COLUMN = 'name';

/// int; autoincrement'd
const GRAPHQL_JOBS_PRIMARY_KEY_COLUMN = 'id';

/// json-encoded String
const GRAPHQL_JOBS_VARIABLES_COLUMN = 'variables';

/// String
const GRAPHQL_JOBS_TABLE_NAME = 'GraphqlJobs';

/// int; millisecondsSinceEpoch
const GRAPHQL_JOBS_UPDATED_AT = 'updated_at';
