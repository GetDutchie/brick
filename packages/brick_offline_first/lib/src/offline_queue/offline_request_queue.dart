import 'dart:async';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'offline_queue_http_client.dart';
import 'request_sqlite_cache.dart';

/// Repeatedly reattempts requests in an interval
class OfflineRequestQueue {
  /// The client responsible for resending requests
  final OfflineQueueHttpClient client;

  /// Time between running jobs. Defaults to 5 seconds.
  final Duration interval;

  /// The number of requests returned per check. Ultimately determines how many queued jobs
  /// to reprocess simultaneously. Defaults to `1`.
  final int maximumRequests;

  final Logger _logger;

  /// If the queue is processing
  bool get isRunning => _timer?.isActive == true;

  Timer _timer;

  OfflineRequestQueue({
    @required this.client,
    Duration interval,
    this.maximumRequests = 1,
  })  : this.interval = interval ?? const Duration(seconds: 5),
        _logger = Logger('OfflineRequestQueue#${client.databaseName}');

  /// Start the processing queue, resending requests every [interval].
  /// Stops the existing timer if it was already running.
  void start() {
    stop();
    _logger.finer('Queue started');
    _timer = Timer.periodic(interval, _process);
  }

  /// Invalidates timer. This does not stop actively-running recreated jobs.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _logger.finer('Queue stopped');
  }

  /// Resend unproccessed requests to the client.
  void _process(Timer _timer) async {
    final requests = await RequestSqliteCache.unproccessedRequests(
      client.databaseName,
      maximumRequests: maximumRequests,
    );

    final requeuedRequests = requests.map(client.send);
    if (requeuedRequests.isNotEmpty) {
      _logger.finer('Processing ${requeuedRequests.length} requests');
      await Future.wait(requeuedRequests);
    }
  }
}
