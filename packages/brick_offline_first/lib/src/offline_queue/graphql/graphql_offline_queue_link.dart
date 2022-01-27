import 'package:brick_offline_first/src/offline_queue/graphql/graphql_request_sqlite_cache_manager.dart';
import 'package:brick_offline_first/src/offline_queue/graphql/graphql_request_sqlite_cache.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql/ast.dart';
import 'package:logging/logging.dart';

/// Stores all requests in a SQLite database
class GraphqlOfflineQueueLink extends Link {
  /// A DocumentNode GraphQL execution interface
  /// https://pub.dev/documentation/gql_link/latest/link/Link-class.html
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
    if (!isNotMutation(cacheItem.request)) {
      final db = await requestManager.getDb();
      // Log immediately before we make the request
      await cacheItem.insertOrUpdate(db, logger: _logger);
    }

    Response? response;

    /// When the request is null a generic Graphql error needs to be generated
    const _genericErrorResponse =
        Response(errors: [GraphQLError(message: 'Unknown error')], data: null);

    try {
      // Attempt to make Graphql Request, handle it as a traditional response to do check
      final requestAsStream = _inner.request(request).first;

      try {
        response = await requestAsStream;

        if (response.errors == null) {
          final db = await requestManager.getDb();
          // request was successfully sent and can be removed
          _logger.finest('removing from queue: ${cacheItem.toSqlite()}');
          await cacheItem.delete(db);
        }

        yield response;
      } catch (e) {
        _logger.warning('Error retrieving response');
        response = _genericErrorResponse;
      }
    } catch (e) {
      _logger.warning('#send: $e');
    } finally {
      final db = await requestManager.getDb();
      await cacheItem.unlock(db);
    }

    yield _genericErrorResponse;
  }

  /// Parse a request and determines what [OperationType] it is
  /// If the statement evaluates to true it is a query or subscription
  static bool isNotMutation(Request request) {
    final node = request.operation.document.definitions.first;
    return node is OperationDefinitionNode && node.type != OperationType.mutation;
  }
}
