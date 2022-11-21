#import "MskPlugin.h"
#if __has_include(<msk/msk-Swift.h>)
#import <msk/msk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "msk-Swift.h"
#endif

@implementation MskPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMskPlugin registerWithRegistrar:registrar];
}
@end
