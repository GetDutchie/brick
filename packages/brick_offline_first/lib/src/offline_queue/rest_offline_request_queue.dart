import 'dart:async';

import 'package:brick_offline_first/src/offline_queue/offline_queue_http_client.dart';
import 'package:brick_offline_first/src/offline_queue/offline_request_queue.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;

class RestOfflineRequestQueue extends OfflineRequestQueue<OfflineQueueHttpClient> {
  @override
  // ignore: overridden_fields
  final Logger logger;

  RestOfflineRequestQueue({
    required OfflineQueueHttpClient client,
  })  : logger = Logger('RestOfflineRequestQueue'),
        super(
          client: client,
          databaseName: client.requestManager.databaseName,
          processingInterval: client.requestManager.processingInterval,
        );

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates
  bool _processingInBackground = false;

  @override
  void process(Timer _timer) async {
    if (_processingInBackground) return;

    _processingInBackground = true;

    http.Request? request;
    try {
      request = await client.requestManager.prepareNextRequestToProcess();
    } finally {
      _processingInBackground = false;
    }

    if (request != null) {
      logger.info('Processing request ${request.method} ${request.url}');
      await client.send(request);
    }
  }
}
