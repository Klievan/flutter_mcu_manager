#import "DeviceManagerPlugin.h"
#if __has_include(<flutter_mcu_manager/device_manager-Swift.h>)
#import <flutter_mcu_manager/device_manager-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "device_manager-Swift.h"
#endif

@implementation DeviceManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftDeviceManagerPlugin registerWithRegistrar:registrar];
}
@end
