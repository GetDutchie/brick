import 'dart:io';

import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql/ast.dart';
import 'package:logging/logging.dart';

/// Stores all mutation requests in a SQLite database
class GraphqlOfflineQueueLink extends Link {
  final Logger _logger;

  final GraphqlRequestSqliteCacheManager requestManager;

  GraphqlOfflineQueueLink(this.requestManager)
      : _logger = Logger('GraphqlOfflineQueueLink#${requestManager.databaseName}');

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final cacheItem = GraphqlRequestSqliteCache(request);
    _logger.finest('sending: ${cacheItem.toSqlite()}');

    // Ignore "query" and "subscription" request
    if (isMutation(cacheItem.request)) {
      final db = await requestManager.getDb();
      // Log immediately before we make the request
      await cacheItem.insertOrUpdate(db, logger: _logger);
    }

    yield* forward!(request).handleError(
      (e) async {
        _logger.warning('#send: $e');
        final db = await requestManager.getDb();
        await cacheItem.unlock(db);
        return;
      },
      test: (e) => e is ServerException && e.originalException is SocketException,
    ).asyncMap((response) async {
      if (response.errors?.isEmpty ?? true) {
        final db = await requestManager.getDb();
        // request was successfully sent and can be removed
        _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
        await cacheItem.delete(db);
      }
      final db = await requestManager.getDb();
      await cacheItem.unlock(db);

      return response;
    });
  }

  /// Parse a request and determines what [OperationType] it is
  /// If the statement evaluates to true it is a mutation
  static bool isMutation(Request request) {
    final node = request.operation.document.definitions.first;
    return node is OperationDefinitionNode && node.type == OperationType.mutation;
  }
}
