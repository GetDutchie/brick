import 'dart:async';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// Repeatedly reattempts requests in an interval
abstract class OfflineRequestQueue {
  /// If the queue is processing
  bool get isRunning => _timer?.isActive == true;

  @protected
  Logger logger;

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates
  @protected
  bool processingInBackground = false;

  final Duration processingInterval;

  Timer? _timer;

  OfflineRequestQueue({
    required this.processingInterval,
  }) : logger = Logger('OfflineRequestQueue');

  /// Resend latest unproccessed request to the client.
  @protected
  void process(Timer _timer);

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
    _timer?.cancel();
    _timer = null;
    processingInBackground = false;
    logger.finer('Queue stopped');
  }
}
