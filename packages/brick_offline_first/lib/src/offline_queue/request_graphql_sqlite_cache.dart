import 'package:brick_offline_first/src/offline_queue/request_graphql_sqlite_cache_manager.dart';
import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache.dart';

/// Serialize and Deserialize a [http.Request] from SQLite.
class RequestGraphqlSqliteCache extends RequestSqliteCache {
  RequestGraphqlSqliteCache({request})
      : super(
            attemptColumn: GRAPHQL_JOB_ATTEMPTS_COLUMN,
            createdAtColumn: GRAPHQL_JOB_CREATED_AT_COLUMN,
            lockedColumn: GRAPHQL_JOB_LOCKED_COLUMN,
            primaryKeyColumn: GRAPHQL_JOB_PRIMARY_KEY_COLUMN,
            request: request,
            requestColumns: [
              GRAPHQL_JOB_DOCUMENT_COLUMN,
              GRAPHQL_JOB_VARIABLES_COLUMN,
              GRAPHQL_JOB_OPERATION_NAME_COLUMN,
            ],
            tableName: GRAPHQL_JOB_TABLE_NAME,
            updateAtColumn: GRAPHQL_JOB_UPDATED_AT);

  /// Builds request into a new SQLite-insertable row
  /// Only available if [request] was initialized from [fromRequest]
  ///
  /// This is a function to ensure `DateTime.now()` is invoked predictably.
  @override
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
}
