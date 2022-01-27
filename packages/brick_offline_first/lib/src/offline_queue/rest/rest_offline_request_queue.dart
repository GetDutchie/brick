import 'dart:async';

import 'package:brick_offline_first/src/offline_queue/rest/rest_offline_queue_client.dart';
import 'package:brick_offline_first/src/offline_queue/offline_request_queue.dart';
import 'package:http/http.dart' as http;

class RestOfflineRequestQueue extends OfflineRequestQueue<http.Request> {
  /// The client responsible for resending requests
  final RestOfflineQueueClient client;

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates

  RestOfflineRequestQueue({
    required this.client,
  }) : super(
          processingInterval: client.requestManager.processingInterval,
          requestManager: client.requestManager,
        );

  @override
  Future<void> transmitRequest(http.Request request) async {
    logger.info('Processing request ${request.method} ${request.url}');
    await client.send(request);
  }
}
