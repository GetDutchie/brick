import 'dart:async';
import 'package:logging/logging.dart';

/// Repeatedly reattempts requests in an interval
class OfflineRequestQueue<_Client> {
  /// The client responsible for resending requests
  final _Client client;

  /// If the queue is processing
  bool get isRunning => _timer?.isActive == true;

  final String databaseName;

  final Logger _logger;

  final Duration processingInterval;

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates
  bool processingInBackground = false;

  Timer? _timer;

  OfflineRequestQueue(
      {required this.client, required this.databaseName, required this.processingInterval})
      : _logger = Logger('OfflineRequest#$databaseName');

  /// Start the processing queue, resending requests every [interval].
  /// Stops the existing timer if it was already running.
  void start() {
    stop();
    _logger.finer('Queue started');
    processingInBackground = false;
    _timer = Timer.periodic(processingInterval, process);
  }

  /// Invalidates timer. This does not stop actively-running recreated jobs.
  void stop() {
    _timer?.cancel();
    _timer = null;
    processingInBackground = false;
    _logger.finer('Queue stopped');
  }

  /// Resend latest unproccessed request to the client.
  void process(Timer _timer) async {}
}
