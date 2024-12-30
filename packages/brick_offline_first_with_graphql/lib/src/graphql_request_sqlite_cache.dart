import 'dart:convert';

import 'package:brick_offline_first/offline_queue.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:gql/language.dart' as lang;
import 'package:gql_exec/gql_exec.dart';

/// Serialize and Deserialize a [Request] from SQLite.
class GraphqlRequestSqliteCache extends RequestSqliteCache<Request> {
  /// Serialize and Deserialize a [Request] from SQLite.
  GraphqlRequestSqliteCache(request)
      : super(
          attemptColumn: GRAPHQL_JOBS_ATTEMPTS_COLUMN,
          createdAtColumn: GRAPHQL_JOBS_CREATED_AT_COLUMN,
          lockedColumn: GRAPHQL_JOBS_LOCKED_COLUMN,
          primaryKeyColumn: GRAPHQL_JOBS_PRIMARY_KEY_COLUMN,
          request: request,
          requestColumns: [
            GRAPHQL_JOBS_DOCUMENT_COLUMN,
            GRAPHQL_JOBS_VARIABLES_COLUMN,
            GRAPHQL_JOBS_OPERATION_NAME_COLUMN,
          ],
          tableName: GRAPHQL_JOBS_TABLE_NAME,
          updateAtColumn: GRAPHQL_JOBS_UPDATED_AT,
        );

  @override
  String attemptLogMessage(Map<String, dynamic> responseFromSqlite) {
    final attemptMessage = responseFromSqlite[GRAPHQL_JOBS_OPERATION_NAME_COLUMN];

    return 'failed, attempt #${responseFromSqlite[GRAPHQL_JOBS_ATTEMPTS_COLUMN]} in $attemptMessage : $responseFromSqlite';
  }

  @override
  Request sqliteToRequest(Map<String, dynamic> data) {
    final document = lang.parseString(data[GRAPHQL_JOBS_DOCUMENT_COLUMN]);
    final operationName = data[GRAPHQL_JOBS_OPERATION_NAME_COLUMN];
    final variables = jsonDecode(data[GRAPHQL_JOBS_VARIABLES_COLUMN]);

    final operation = Operation(document: document, operationName: operationName);
    return Request(variables: variables, operation: operation);
  }

  /// Builds request into a new SQLite-insertable row
  /// Only available if [request] was initialized from [sqliteToRequest]
  ///
  /// This is a function to ensure `DateTime.now()` is invoked predictably.
  @override
  Map<String, dynamic> toSqlite() {
    return {
      GRAPHQL_JOBS_ATTEMPTS_COLUMN: 1,
      GRAPHQL_JOBS_DOCUMENT_COLUMN: lang.printNode(request.operation.document),
      GRAPHQL_JOBS_VARIABLES_COLUMN: jsonEncode(request.variables),
      GRAPHQL_JOBS_CREATED_AT_COLUMN: DateTime.now().millisecondsSinceEpoch,
      GRAPHQL_JOBS_OPERATION_NAME_COLUMN: request.operation.operationName.toString(),
      GRAPHQL_JOBS_UPDATED_AT: DateTime.now().millisecondsSinceEpoch,
    };
  }
}
