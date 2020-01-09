import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

void stubConnectivity({bool isOnline = false}) {
  Connectivity.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'check') {
      return isOnline ? 'wifi' : null;
    }

    return "";
  });

  MethodChannel(Connectivity.eventChannel.name)
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'listen' || methodCall.method == 'cancel') {
      return null;
    }
  });
}
