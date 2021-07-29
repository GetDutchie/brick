import 'dart:async';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'offline_queue_http_client.dart';

/// Repeatedly reattempts requests in an interval
class OfflineRequestQueue {
  bool _backgroundIsProcessing = false;

  /// The client responsible for resending requests
  final OfflineQueueHttpClient client;

  /// If the queue is processing
  bool get isRunning => _timer?.isActive == true;

  final Logger _logger;

  Timer _timer;

  OfflineRequestQueue({
    @required this.client,
  }) : _logger = Logger('OfflineRequestQueue#${client.requestManager.databaseName}');

  /// Start the processing queue, resending requests every [interval].
  /// Stops the existing timer if it was already running.
  void start() {
    stop();
    _logger.finer('Queue started');
    _backgroundIsProcessing = false;
    _timer = Timer.periodic(client.requestManager.processingInterval, process);
  }

  /// Invalidates timer. This does not stop actively running work.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _backgroundIsProcessing = false;
    _logger.finer('Queue stopped');
  }

  /// Resend latest unproccessed request to the client.
  @protected
  void process(Timer _timer) async {
    if (_backgroundIsProcessing) return;
    _backgroundIsProcessing = true;
    final request = await client.requestManager.prepareNextRequestToProcess();
    _backgroundIsProcessing = false;

    if (request != null) {
      _logger.finest('Processing request ${request.method} ${request.url}');
      await client.send(request);
    }
  }
}
