import 'package:flutter/services.dart';

void stubConnectivity({bool isOnline = false}) {
  MethodChannel('plugins.flutter.io/connectivity')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'check') {
      return isOnline ? 'wifi' : null;
    }

    return '';
  });

  MethodChannel('plugins.flutter.io/connectivity_status')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'listen' || methodCall.method == 'cancel') {
      return null;
    }
  });
}
