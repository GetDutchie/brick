import 'dart:async';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'offline_queue_http_client.dart';

/// Repeatedly reattempts requests in an interval
class OfflineRequestQueue {
  /// The client responsible for resending requests
  final OfflineQueueHttpClient client;

  /// Time between running jobs. Defaults to 5 seconds.
  final Duration interval;

  /// If the queue is processing
  bool get isRunning => _timer?.isActive == true;

  final Logger _logger;

  Timer _timer;

  OfflineRequestQueue({
    @required this.client,
    Duration interval,
  })  : this.interval = interval ?? const Duration(seconds: 5),
        _logger = Logger('OfflineRequestQueue#${client.requestManager.databaseName}');

  /// Start the processing queue, resending requests every [interval].
  /// Stops the existing timer if it was already running.
  void start() {
    stop();
    _logger.finer('Queue started');
    _timer = Timer.periodic(interval, process);
  }

  /// Invalidates timer. This does not stop actively-running recreated jobs.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _logger.finer('Queue stopped');
  }

  /// Resend latest unproccessed request to the client.
  @protected
  void process(Timer _timer) async {
    final request = await client.requestManager.prepareNextRequestToProcess();

    if (request != null) {
      _logger.finer('Processing request');
      await client.send(request);
    }
  }
}
