// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:gql/language.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:sqflite/sqflite.dart';

class GraphqlRequestSqliteCacheManager extends RequestSqliteCacheManager<Request> {
  GraphqlRequestSqliteCacheManager(
    String databaseName, {
    DatabaseFactory? databaseFactory,
    Duration? processingInterval,
    bool? serialProcessing,
  }) : super(
          databaseName,
          createdAtColumn: GRAPHQL_JOB_CREATED_AT_COLUMN,
          databaseFactory: databaseFactory,
          lockedColumn: GRAPHQL_JOB_LOCKED_COLUMN,
          primaryKeyColumn: GRAPHQL_JOB_PRIMARY_KEY_COLUMN,
          processingInterval: processingInterval ?? const Duration(seconds: 0),
          serialProcessing: serialProcessing ?? true,
          tableName: GRAPHQL_JOB_TABLE_NAME,
          updateAtColumn: GRAPHQL_JOB_UPDATED_AT,
        );

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
  }

  /// Recreate a request from SQLite data
  @override
  Request sqliteToRequest(Map<String, dynamic> data) {
    final document = parseString(data[GRAPHQL_JOB_DOCUMENT_COLUMN]);
    final operationName = data[GRAPHQL_JOB_OPERATION_NAME_COLUMN];
    final variables = jsonDecode(data[GRAPHQL_JOB_VARIABLES_COLUMN]);

    final operation = Operation(document: document, operationName: operationName);
    return Request(variables: variables, operation: operation);
  }
}

/// int
const GRAPHQL_JOB_ATTEMPTS_COLUMN = 'attempts';

/// int; millisecondsSinceEpoch
const GRAPHQL_JOB_CREATED_AT_COLUMN = 'created_at';

/// String
const GRAPHQL_JOB_DOCUMENT_COLUMN = 'graphql_document';

/// int; 1 for true, 0 for false
const GRAPHQL_JOB_LOCKED_COLUMN = 'locked';

/// String
const GRAPHQL_JOB_OPERATION_NAME_COLUMN = 'name';

/// int; autoincrement'd
const GRAPHQL_JOB_PRIMARY_KEY_COLUMN = 'id';

/// json-encoded String
const GRAPHQL_JOB_VARIABLES_COLUMN = 'varibles';

// String
const GRAPHQL_JOB_TABLE_NAME = 'GraphqlJobs';

/// int; millisecondsSinceEpoch
const GRAPHQL_JOB_UPDATED_AT = 'updated_at';
