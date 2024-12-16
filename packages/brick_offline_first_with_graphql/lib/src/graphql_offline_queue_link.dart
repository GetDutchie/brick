import 'dart:io';

import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_offline_first_with_graphql/src/offline_first_graphql_policy.dart';
import 'package:gql/ast.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:logging/logging.dart';

/// Stores all mutation requests in a SQLite database
class GraphqlOfflineQueueLink extends Link {
  final Logger _logger;

  ///
  final GraphqlRequestSqliteCacheManager requestManager;

  /// A callback triggered when a request failed, but will be reattempted.
  final void Function(Request request)? onReattempt;

  /// A callback triggered when a request throws an exception during execution.
  final void Function(Request request, Object error)? onRequestException;

  /// Stores all mutation requests in a SQLite database
  GraphqlOfflineQueueLink(
    this.requestManager, {
    this.onReattempt,
    this.onRequestException,
  }) : _logger = Logger('GraphqlOfflineQueueLink#${requestManager.databaseName}');

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final cacheItem = GraphqlRequestSqliteCache(request);
    _logger.finest('GraphqlOfflineQueueLink#request: requesting ${cacheItem.toSqlite()}');

    // Ignore "query" and "subscription" request
    if (shouldCache(cacheItem.request)) {
      final db = await requestManager.getDb();
      // Log immediately before we make the request
      await cacheItem.insertOrUpdate(db, logger: _logger);
    }

    yield* forward!(request).handleError(
      (e) async {
        _logger.warning('GraphqlOfflineQueueLink#request: error $e');
        onRequestException?.call(request, e);
        final db = await requestManager.getDb();
        await cacheItem.unlock(db);
      },
      test: (e) {
        return e is SocketException ||
            (e is ServerException && e.originalException is SocketException);
      },
    ).asyncMap((response) async {
      if (response.errors?.isEmpty ?? true) {
        final db = await requestManager.getDb();
        // request was successfully sent and can be removed
        _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
        await cacheItem.delete(db);
      } else if (response.errors != null) {
        onRequestException?.call(request, response.errors!);
      }

      onReattempt?.call(request);
      final db = await requestManager.getDb();
      await cacheItem.unlock(db);

      return response;
    });
  }

  /// Parse a request and determines what [OperationType] it is
  /// If the statement evaluates to true it is a mutation
  static bool shouldCache(Request request) {
    final node = request.operation.document.definitions.first;
    final policy = request.context.entry<OfflineFirstGraphqlPolicy>()?.upsert;
    final isMutation = node is OperationDefinitionNode && node.type == OperationType.mutation;
    return isMutation && policy != OfflineFirstUpsertPolicy.requireRemote;
  }
}
