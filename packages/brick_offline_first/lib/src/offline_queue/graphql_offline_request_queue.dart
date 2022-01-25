import 'dart:async';

import 'package:brick_offline_first/src/offline_queue/graphql_offline_queue_link.dart';
import 'package:brick_offline_first/src/offline_queue/offline_request_queue.dart';
import 'package:gql_exec/gql_exec.dart';

class GraphqlOfflineRequestQueue extends OfflineRequestQueue {
  /// The client responsible for resending requests
  GraphqlOfflineQueueLink link;

  GraphqlOfflineRequestQueue({required this.link})
      : super(
          processingInterval: link.requestManager.processingInterval,
        );

  @override
  void process(Timer? _timer) async {
    if (processingInBackground) return;

    processingInBackground = true;

    Request? request;
    try {
      request = await link.requestManager.prepareNextRequestToProcess();
    } finally {
      processingInBackground = false;
    }

    if (request != null) {
      logger.finest('Processing request ${request.operation.operationName}');
      link.request(request);
    }
  }
}
