import 'dart:async';

import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';
import 'package:brick_offline_first/src/offline_queue/offline_request_queue.dart';
import 'package:http/http.dart' as http;

class RestOfflineRequestQueue extends OfflineRequestQueue {
  /// The client responsible for resending requests
  final OfflineQueueHttpClient client;

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates

  RestOfflineRequestQueue({
    required this.client,
  }) : super(
          processingInterval: client.requestManager.processingInterval,
        );

  @override
  void process(Timer _timer) async {
    if (processingInBackground) return;

    processingInBackground = true;

    http.Request? request;
    try {
      request = await client.requestManager.prepareNextRequestToProcess();
    } finally {
      processingInBackground = false;
    }

    if (request != null) {
      logger.info('Processing request ${request.method} ${request.url}');
      await client.send(request);
    }
  }
}
