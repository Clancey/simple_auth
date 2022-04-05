#import <FlutterMacOS/FlutterMacOS.h>
@interface SimpleAuthFlutterPlugin : NSObject<FlutterPlugin>
+ (BOOL)checkUrl:(NSURL *)url;
@end
