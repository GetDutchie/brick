import 'dart:async';
import 'package:brick_graphql/src/offline_queue/offline_queue_graphql_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:graphql/client.dart';

/// Repeatedly reattempts requests in an interval
class OfflineRequestQueueGraphql {
  /// The client responsible for resending requests
  final OfflineQueueGraphqlClient client;

  /// If the queue is processing
  bool get isRunning => _timer?.isActive == true;

  final Logger _logger;

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates
  bool _processingInBackground = false;

  Timer? _timer;

  OfflineRequestQueueGraphql({
    required this.client,
  }) : _logger = Logger('OfflineRequestQueue#${client.requestManager.databaseName}');

  /// Start the processing queue, resending requests every [interval].
  /// Stops the existing timer if it was already running.
  void start() {
    stop();
    _logger.finer('Queue started');
    _processingInBackground = false;
    _timer = Timer.periodic(client.requestManager.processingInterval, process);
  }

  /// Invalidates timer. This does not stop actively-running recreated jobs.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _processingInBackground = false;
    _logger.finer('Queue stopped');
  }

  /// Resend latest unproccessed request to the client.
  @protected
  void process(Timer _timer) async {
    if (_processingInBackground) return;

    _processingInBackground = true;

    Request? request;
    try {
      request = (await client.requestManager.prepareNextRequestToProcess()) as Request?;
    } finally {
      _processingInBackground = false;
    }

    if (request != null) {
      _logger.finest('Processing request ${request.type} ${request.operation.operationName}');
      await client.send(request);
    }
  }
}
