package com.example.flutter_plugin_battery_status;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterPluginBatteryStatusPlugin */
public class FlutterPluginBatteryStatusPlugin implements EventChannel.StreamHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final EventChannel eventChannel =
            new EventChannel(registrar.messenger(), "plugins.flutter.io/charging");
    final FlutterPluginBatteryStatusPlugin instance = new FlutterPluginBatteryStatusPlugin(registrar);
    eventChannel.setStreamHandler(instance);
  }

  FlutterPluginBatteryStatusPlugin(PluginRegistry.Registrar registrar) {
    this.registrar = registrar;
  }

  private final PluginRegistry.Registrar registrar;
  private BroadcastReceiver chargingStateChangeReceiver;

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    chargingStateChangeReceiver = createChargingStateChangeReceiver(events);
    registrar
            .context()
            .registerReceiver(
                    chargingStateChangeReceiver, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
  }

  @Override
  public void onCancel(Object arguments) {
    registrar.context().unregisterReceiver(chargingStateChangeReceiver);
    chargingStateChangeReceiver = null;
  }

  private BroadcastReceiver createChargingStateChangeReceiver(final EventChannel.EventSink events) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        int status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1);

        switch (status) {
          case BatteryManager.BATTERY_STATUS_CHARGING:
            events.success("charging");
            break;
          case BatteryManager.BATTERY_STATUS_FULL:
            events.success("full");
            break;
          case BatteryManager.BATTERY_STATUS_DISCHARGING:
            events.success("discharging");
            break;
          default:
            events.error("UNAVAILABLE", "Charging status unavailable", null);
            break;
        }
      }
    };
  }
}
