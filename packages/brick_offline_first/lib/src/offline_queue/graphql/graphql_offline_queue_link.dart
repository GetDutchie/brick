import 'dart:io';

import 'package:brick_offline_first/src/offline_queue/graphql/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_offline_first/src/offline_queue/graphql/graphql_request_sqlite_cache.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql/ast.dart';
import 'package:logging/logging.dart';

/// Stores all mutation requests in a SQLite database
class GraphqlOfflineQueueLink extends Link {
  /// A DocumentNode GraphQL execution interface
  /// https://pub.dev/documentation/gql_link/latest/link/Link-class.html
  ///
  /// Instead of the proscribed [Link] series with the links calling `#forward`
  /// [_inner] is composed. Storing the request must occur before an HTTPLink
  /// and validating the request occurred with a SocketException must occur
  /// after the request. Therefore, `forward` can't be called because it's
  /// needed on both ends of the request. HTTPLink also doesn't invoke `#forward`
  /// and can only be used last in a `Link.from([])` invocation.
  final Link _inner;

  final Logger _logger;

  final GraphqlRequestSqliteCacheManager requestManager;

  GraphqlOfflineQueueLink(this._inner, this.requestManager)
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

    Response response;

    try {
      // Attempt to make Graphql Request, handle it as a traditional response to do check
      response = await _inner.request(request).first;

      if (response.errors?.isEmpty ?? true) {
        final db = await requestManager.getDb();
        // request was successfully sent and can be removed
        _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
        await cacheItem.delete(db);
      }
    } on ServerException catch (e) {
      if (e.originalException is SocketException) {
        _logger.warning('#send: $e');

        /// When the request is null a generic Graphql error needs to be generated
        response = Response(errors: [GraphQLError(message: 'Unknown error: $e')], data: null);
      } else {
        rethrow;
      }
    } finally {
      final db = await requestManager.getDb();
      await cacheItem.unlock(db);
    }

    yield response;
  }

  /// Parse a request and determines what [OperationType] it is
  /// If the statement evaluates to true it is a mutation
  static bool isMutation(Request request) {
    final node = request.operation.document.definitions.first;
    return node is OperationDefinitionNode && node.type == OperationType.mutation;
  }
}
