import 'dart:async';

import 'package:brick_offline_first_with_rest/src/offline_queue/rest_offline_queue_client.dart';
import 'package:brick_offline_first/offline_queue.dart';
import 'package:http/http.dart' as http;

class RestOfflineRequestQueue extends OfflineRequestQueue<http.Request> {
  /// The client responsible for resending requests
  final RestOfflineQueueClient client;

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
