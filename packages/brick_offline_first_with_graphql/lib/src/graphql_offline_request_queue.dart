import 'dart:async';

import 'package:brick_offline_first/offline_queue.dart';
import 'package:brick_offline_first_with_graphql/src/graphql_offline_queue_link.dart';
import 'package:gql_exec/gql_exec.dart';

class GraphqlOfflineRequestQueue extends OfflineRequestQueue<Request> {
  /// The client responsible for resending requests
  final GraphqlOfflineQueueLink link;

  GraphqlOfflineRequestQueue({required this.link})
      : super(
          processingInterval: link.requestManager.processingInterval,
          requestManager: link.requestManager,
        );

  @override
  Future<void> transmitRequest(Request request) async {
    logger.finest('Processing request ${request.operation.operationName}');
    link.request(request);
  }
}
