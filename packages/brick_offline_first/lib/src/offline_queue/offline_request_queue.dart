import 'dart:async';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// Repeatedly reattempts requests in an interval
abstract class OfflineRequestQueue<_Client> {
  /// The client responsible for resending requests
  final _Client client;

  final String databaseName;

  /// If the queue is processing
  bool get isRunning => _timer?.isActive == true;

  @protected
  final Logger logger;

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates
  bool processingInBackground = false;

  final Duration processingInterval;

  late Timer? _timer;

  OfflineRequestQueue({
    required this.client,
    required this.databaseName,
    required this.processingInterval,
  }) : logger = Logger('OfflineRequestQueue#$databaseName');

  /// Start the processing queue, resending requests every [interval].
  /// Stops the existing timer if it was already running.
  void start() {
    stop();
    logger.finer('Queue started');
    processingInBackground = false;
    _timer = Timer.periodic(processingInterval, process);
  }

  /// Invalidates timer. This does not stop actively-running recreated jobs.
  void stop() {
    try {
      _timer?.cancel();
    } catch (e) {
      _timer = null;
    }
    _timer = null;
    processingInBackground = false;
    logger.finer('Queue stopped');
  }

  /// Resend latest unproccessed request to the client.
  void process(Timer _timer) async {}
}
