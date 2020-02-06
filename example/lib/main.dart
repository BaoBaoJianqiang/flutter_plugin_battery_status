import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_battery_status/flutter_plugin_battery_status.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterPluginBatteryStatus batteryStatus = FlutterPluginBatteryStatus();

  StreamSubscription<String> _batteryStateSubscription;

  String _chargingStatus = 'Battery status: unknown.';

  @override
  void initState() {
    super.initState();

    _batteryStateSubscription =
        batteryStatus.onBatteryStateChanged.listen((String state) {
          setState(() {
            _chargingStatus = state;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('电池状态: $_chargingStatus\n'),
        ),
      ),
    );
  }
}
