#import "FlutterPluginBatteryStatusPlugin.h"

@interface FlutterPluginBatteryStatusPlugin () <FlutterStreamHandler>
@end

@implementation FlutterPluginBatteryStatusPlugin {
    FlutterEventSink _eventSink;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

  FlutterEventChannel* chargingChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/charging"
                                binaryMessenger:[registrar messenger]];

  FlutterPluginBatteryStatusPlugin* instance = [[FlutterPluginBatteryStatusPlugin alloc] init];
  [chargingChannel setStreamHandler:instance];
}

- (void)onBatteryStateDidChange:(NSNotification*)notification {
  [self sendBatteryStateEvent];
}

- (void)sendBatteryStateEvent {
  if (!_eventSink) return;
  UIDeviceBatteryState state = [[UIDevice currentDevice] batteryState];
  switch (state) {
    case UIDeviceBatteryStateFull:
      _eventSink(@"full");
    case UIDeviceBatteryStateCharging:
      _eventSink(@"charging");
      break;
    case UIDeviceBatteryStateUnplugged:
      _eventSink(@"discharging");
      break;
    default:
      _eventSink([FlutterError errorWithCode:@"UNAVAILABLE"
                                     message:@"Charging status unavailable"
                                     details:nil]);
      break;
  }
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
  [self sendBatteryStateEvent];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onBatteryStateDidChange:)
                                               name:UIDeviceBatteryStateDidChangeNotification
                                             object:nil];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _eventSink = nil;
  return nil;
}

@end
