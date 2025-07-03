import 'dart:async';

import 'package:brick_offline_first/offline_queue.dart';
import 'package:brick_offline_first_with_graphql/brick_offline_first_with_graphql.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';

/// GraphQL implementation of [OfflineRequestQueue]
class GraphqlOfflineRequestQueue extends OfflineRequestQueue<Request> {
  /// The client responsible for resending requests
  final Link link;

  /// GraphQL implementation of [OfflineRequestQueue]
  GraphqlOfflineRequestQueue({
    required this.link,
    required GraphqlRequestSqliteCacheManager requestManager,
  }) : super(
          processingInterval: requestManager.processingInterval,
          requestManager: requestManager,
        );

  @override
  Future<void> transmitRequest(Request request) async {
    logger.finest('Processing request ${request.operation.operationName}');
    await link.request(request).drain();
  }
}
