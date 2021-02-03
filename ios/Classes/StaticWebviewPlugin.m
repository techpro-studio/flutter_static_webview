#import "StaticWebviewPlugin.h"
#if __has_include(<static_webview/static_webview-Swift.h>)
#import <static_webview/static_webview-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "static_webview-Swift.h"
#endif

@implementation StaticWebviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftStaticWebViewPlugin registerWithRegistrar:registrar];
}
@end
