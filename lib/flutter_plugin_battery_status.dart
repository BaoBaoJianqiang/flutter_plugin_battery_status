import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPluginBatteryStatus {
  final EventChannel _eventChannel;
  Stream<String> _onBatteryStateChanged;

  factory FlutterPluginBatteryStatus() {
    if (_instance == null) {
      final EventChannel eventChannel = const EventChannel('plugins.flutter.io/charging');
      _instance = FlutterPluginBatteryStatus.private(eventChannel);
    }
    return _instance;
  }

  FlutterPluginBatteryStatus.private(this._eventChannel);

  static FlutterPluginBatteryStatus _instance;

  /// Fires whenever the battery state changes.
  Stream<String> get onBatteryStateChanged {
    if (_onBatteryStateChanged == null) {
      _onBatteryStateChanged = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => event);
    }
    return _onBatteryStateChanged;
  }
}
