#import <Flutter/Flutter.h>
#import "WebAuthenticator.h"
@interface SimpleAuthFlutterPlugin : NSObject<FlutterPlugin>
+ (BOOL)checkUrl:(NSURL *)url;
@end
