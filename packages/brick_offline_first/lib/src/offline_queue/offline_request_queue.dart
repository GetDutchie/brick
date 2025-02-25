import 'dart:async';

import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// Repeatedly reattempts requests in an interval
abstract class OfflineRequestQueue<TRequest> {
  /// If the queue is processing
  bool get isRunning => _timer?.isActive ?? false;

  ///
  @protected
  final Logger logger;

  /// This mutex ensures that concurrent writes to the DB will
  /// not occur as the Timer runs in sub routines or isolates
  // ignore: omit_obvious_property_types
  bool _processingInBackground = false;

  /// How often requests are reattempted
  final Duration processingInterval;

  ///
  final RequestSqliteCacheManager requestManager;

  Timer? _timer;

  /// Repeatedly reattempts requests in an interval
  OfflineRequestQueue({
    required this.processingInterval,
    required this.requestManager,
  }) : logger = Logger('OfflineRequestQueue');

  /// Resend latest unproccessed request to the client.
  Future<void> _process(Timer timer) async {
    if (_processingInBackground) return;

    _processingInBackground = true;

    TRequest? request;
    try {
      request = await requestManager.prepareNextRequestToProcess();
    } finally {
      _processingInBackground = false;
    }

    if (request != null) {
      await transmitRequest(request);
    }
  }

  /// Start the processing queue, resending requests every [processingInterval].
  /// Stops the existing timer if it was already running.
  void start() {
    stop();
    logger.finer('Queue started');
    _processingInBackground = false;
    _timer = Timer.periodic(processingInterval, _process);
  }

  /// Invalidates timer. This does not stop actively-running recreated jobs.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _processingInBackground = false;
    logger.finer('Queue stopped');
  }

  /// Send the next available request through the remote interface
  /// such as an HTTP client.
  Future<void> transmitRequest(TRequest request);
}
