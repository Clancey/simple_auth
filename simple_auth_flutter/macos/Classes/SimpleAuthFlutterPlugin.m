#import "SimpleAuthFlutterPlugin.h"
#import "WebAuthenticator.h"
#import <Foundation/Foundation.h>
#import "ASWebAuthenticator.h"
#import "AuthStorage.h"

@interface SimpleAuthFlutterPlugin ()<FlutterStreamHandler>
@end
@implementation SimpleAuthFlutterPlugin{
    FlutterEventSink _eventSink;
    NSMutableDictionary *authenticators;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"simple_auth_flutter/showAuthenticator"
                                     binaryMessenger:[registrar messenger]];
    SimpleAuthFlutterPlugin* instance = [[SimpleAuthFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    NSLog(@"Registered SimpleAuth on macOS");
    FlutterEventChannel* chargingChannel =
    [FlutterEventChannel eventChannelWithName:@"simple_auth_flutter/urlChanged"
                              binaryMessenger:[registrar messenger]];
    [chargingChannel setStreamHandler:instance];
}
+ (BOOL)checkUrl:(NSURL *)url{
    return [ASWebAuthenticator.shared resumeAuth:url];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"showAuthenticator" isEqualToString:call.method]) {
        NSDictionary *argsMap = call.arguments;
        WebAuthenticator *authenticator = [[WebAuthenticator alloc] initFromDictionary:argsMap];
        authenticator.eventSink = _eventSink;
        [authenticators setObject:authenticator forKey:authenticator.identifier];
         [ASWebAuthenticator presentAuthenticator:authenticator];
        result(@"success");
        return;
    }
    if ([@"completed" isEqualToString:call.method]){
        NSString *identifier = call.arguments[@"identifier"];
        WebAuthenticator *auth = authenticators[identifier];
        [auth foundToken];
        result(@"success");
        return;
    }
    
    if ([@"saveKey" isEqualToString:call.method]) {
        NSDictionary *argsMap = call.arguments;
        NSString *key = [argsMap valueForKey:@"key"];
        NSString *value = [argsMap valueForKey:@"value"];
        [AuthStorage.shared saveValue:value for:key];
        result(@"success");
        return;
    }
    if ([@"getValue" isEqualToString:call.method]) {
        NSDictionary *argsMap = call.arguments;
        NSString *key = [argsMap valueForKey:@"key"];
        result([AuthStorage.shared getValueForKey:key]);
        return;
    }
    
    
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"macOS " stringByAppendingString:[[NSProcessInfo processInfo] operatingSystemVersionString]]);
    } else {
        result(FlutterMethodNotImplemented);
    }
    
}
#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    for (NSString* key in authenticators) {
        WebAuthenticator* auth = [authenticators valueForKey:key];
        auth.eventSink = _eventSink;
    }
    
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    for (NSString* key in authenticators) {
        WebAuthenticator* auth = [authenticators valueForKey:key];
        auth.eventSink = nil;
    }
    _eventSink = nil;
    return nil;
}

@end
