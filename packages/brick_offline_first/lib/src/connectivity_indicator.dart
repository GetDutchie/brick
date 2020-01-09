import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';

/// Describe internet availability for the current device.
class ConnectivityIndicator {
  final Connectivity _connectivity = Connectivity();
  @visibleForTesting
  ConnectivityResult connectivityStatus;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  /// If device is currently connected to WiFi or cellular
  bool get isConnected {
    if (connectivityStatus == null) {
      _forceUpdateConnectivityStatus();
    }
    return connectivityStatus != ConnectivityResult.none;
  }

  static ConnectivityIndicator _singleton;

  ConnectivityIndicator._();

  factory ConnectivityIndicator() {
    if (_singleton == null) {
      _singleton = ConnectivityIndicator._();
      _singleton.startListener();
    }

    return _singleton;
  }

  /// Subscribe to connectivity updates
  Future startListener() async {
    await _connectivitySubscription?.cancel();
    await _forceUpdateConnectivityStatus();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      connectivityStatus = result;
    });
  }

  /// Stop subscribing to connectivity changes.
  Future stopListener() {
    return _connectivitySubscription?.cancel();
  }

  Future<void> _forceUpdateConnectivityStatus() async {
    connectivityStatus = await Connectivity().checkConnectivity();
  }
}
