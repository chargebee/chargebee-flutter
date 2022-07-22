#import "ChargebeeFlutterSdkPlugin.h"
#if __has_include(<chargebee_flutter/chargebee_flutter-Swift.h>)
#import <chargebee_flutter/chargebee_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "chargebee_flutter-Swift.h"
#endif

@implementation ChargebeeFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftChargebeeFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end