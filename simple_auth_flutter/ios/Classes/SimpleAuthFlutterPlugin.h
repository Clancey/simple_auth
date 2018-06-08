#import <Flutter/Flutter.h>
#import "WebAuthenticator.h"
#import "WebAuthenticatorWindow.h"
@interface SimpleAuthFlutterPlugin : NSObject<FlutterPlugin>
+ (BOOL)checkUrl:(NSURL *)url;
@end
