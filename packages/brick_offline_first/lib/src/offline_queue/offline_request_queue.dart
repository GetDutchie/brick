import 'dart:async';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:brick_offline_first/src/offline_queue/request_sqlite_cache_manager.dart';
import 'offline_queue_http_client.dart';

/// Repeatedly reattempts requests in an interval
class OfflineRequestQueue {
  /// The client responsible for resending requests
  final OfflineQueueHttpClient client;

  /// Time between running jobs. Defaults to 5 seconds.
  final Duration interval;

  final RequestSqliteCacheManager requestManager;

  /// If the queue is processing
  bool get isRunning => _timer?.isActive == true;

  /// All requests not actively being processed.
  /// /// Accessing this list can be useful for deleting a job blocking the queue.
  Future<List<Map<String, dynamic>>> get nextJobs async =>
      await requestManager.unprocessedJobs(whereLocked: true);

  /// All requests to be retried, ordered most recent first
  /// Accessing this list can be useful determining queue length.
  Future<List<Map<String, dynamic>>> get unproccessedJobs async =>
      await requestManager.unprocessedJobs();

  final Logger _logger;

  Timer _timer;

  OfflineRequestQueue({
    @required this.client,
    Duration interval,
  })  : this.interval = interval ?? const Duration(seconds: 5),
        this.requestManager = RequestSqliteCacheManager(client.databaseName),
        _logger = Logger('OfflineRequestQueue#${client.databaseName}');

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
    final request = await requestManager.prepareNextRequestToProcess();

    if (request != null) {
      _logger.finer('Processing request');
      await client.send(request);
    }
  }
}
