import 'dart:async';

import 'package:brick_offline_first/src/offline_queue/graphql_offline_queue_client.dart';
import 'package:brick_offline_first/src/offline_queue/offline_request_queue.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:logging/logging.dart';

class GraphqlOfflineRequestQueue extends OfflineRequestQueue<GraphqlOfflineQueueClient> {
  @override
  // ignore: overridden_fields
  final Logger logger;

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates
  bool _processingInBackground = false;

  GraphqlOfflineRequestQueue({required GraphqlOfflineQueueClient client})
      : logger = Logger('GraphqlOfflineRequestQueue'),
        super(
            client: client,
            databaseName: client.requestManager.databaseName,
            processingInterval: client.requestManager.processingInterval);

  @override
  Future<void> process(Timer _timer) async {
    if (_processingInBackground) return;

    _processingInBackground = true;

    Request? request;
    try {
      request = await client.requestManager.prepareNextRequestToProcess();
    } finally {
      _processingInBackground = false;
    }

    if (request != null) {
      logger.info('Processing request ${request.operation.operationName}');
      client.request(request);
    }
  }
}
