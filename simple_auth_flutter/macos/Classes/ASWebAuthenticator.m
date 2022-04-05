//
//  ASWebAuthenticator.m
//  Pods
//
//  Created by Scott MacDougall on 2020-07-03.
//

#import <Foundation/Foundation.h>
#import "ASWebAuthenticator.h"
#import <AuthenticationServices/AuthenticationServices.h>

@implementation ASWebAuthenticator

+ (ASWebAuthenticator *) shared
{
    static dispatch_once_t once;
    static ASWebAuthenticator *sharedObject;
    dispatch_once(&once, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

+ (NSMutableDictionary *) authenticators
{
    static dispatch_once_t once;
    static NSMutableDictionary *sharedObject;
    dispatch_once(&once, ^{
        sharedObject = [[NSMutableDictionary alloc] init];
    });
    return sharedObject;
    
}

+(void)presentAuthenticator:(WebAuthenticator *)authenticator {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"presenting the authenticator");
        NSWindow *window = NSApplication.sharedApplication.keyWindow;
        NSViewController *root = window.contentViewController;
        if (root != nil) {
            [ASWebAuthenticator presentAuthenticatorFromViewController:authenticator viewController: root];
        }
        [ASWebAuthenticator.authenticators setObject:authenticator  forKey:authenticator.redirectUrl.scheme];
    });
}

+(void)presentAuthenticatorFromViewController:(WebAuthenticator *)authenticator viewController:(NSViewController *)viewController{
    [ASWebAuthenticator.shared beginAuthentication:authenticator viewController:viewController];
}

API_AVAILABLE(macos(10.15))
ASWebAuthenticationSession *session;
- (void) beginAuthentication:(WebAuthenticator *)authenticator viewController:(NSViewController *)viewController {
    @try{
        NSString *scheme = authenticator.redirectUrl.scheme;
        if(authenticator.useSSO){
            if (@available(macOS 10.15, *)) {
                session = [[ASWebAuthenticationSession alloc]initWithURL:authenticator.initialUrl callbackURLScheme:authenticator.redirectUrl.scheme completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
                    if (error == nil)
                    {
                        [authenticator checkUrl:callbackURL forceComplete:YES];
                    }
                    else{
                        [authenticator failed:error.localizedDescription];
                    }
                }];
                [session setPresentationContextProvider:[ASWebAuthenticator shared]];
                if(![session start]) {
                    [authenticator failed:@"error setting up ASWebAuthenticationSession"];
                }

                return;
            }
        }
        if(![ASWebAuthenticator verifyHasScheme:scheme]){
            [authenticator failed:[NSString stringWithFormat:@"CFBundleURLTypes is missing CFBundleURLSchemes, Missing Scheme: %@",scheme]];
            return;
        }
        [ASWebAuthenticator.shared webViewSignIn:authenticator viewController: viewController];
    }
    @catch(NSException *ex)
    {
        [authenticator failed:ex.description];
    }
}

-(void) dismissController
{
    if(controller != nil){
        NSWindow *window = NSApplication.sharedApplication.keyWindow;
        NSViewController *root = window.contentViewController;
        [root dismissViewController:controller];
    }
    controller = nil;
    
}

-(BOOL)resumeAuth:(NSURL *)url{
    NSString *scheme = url.scheme;
    id obj = [ASWebAuthenticator.authenticators objectForKey:scheme];
    if(![obj isKindOfClass:[WebAuthenticator class]])
        return false;
    WebAuthenticator *authenticator = (WebAuthenticator*)obj;
    [authenticator checkUrl:url forceComplete:YES];
    [ASWebAuthenticator.authenticators removeObjectForKey:scheme];
    
    [self dismissController];
    return YES;
}

+(bool) verifyHasScheme: (NSString *)scheme{
    NSArray* schemes = [ASWebAuthenticator getUrlSchemes];
    return [schemes containsObject:scheme];
}

+(NSArray *) getUrlSchemes{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    id nsobj  = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleURLTypes"];
    if(nsobj == nil)
        return returnArray;
    if (![nsobj isKindOfClass:[NSArray class]])
        return returnArray;
    
    NSArray *array = (NSArray*)nsobj;
    for (id object in array) {
        if ([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* dict = (NSDictionary*)object;
            nsobj = [dict objectForKey:@"CFBundleURLSchemes"];
            if([nsobj  isKindOfClass:[NSArray class]])
            {
                NSArray* a = (NSArray*)nsobj;
                for (id s in a) {
                    if([s  isKindOfClass:[NSString class]]){
                        [returnArray addObject:s];
                    }
                }
            }
        }
    }
    return returnArray;
}

NSViewController *controller;
-(void) webViewSignIn:(WebAuthenticator *)authenticator viewController:(NSViewController *)viewController {
            WKWebView *webView = [[WKWebView alloc] init];
            NSURLRequest *nsrequest=[NSURLRequest requestWithURL:authenticator.initialUrl];
            [webView loadRequest:nsrequest];
            [webView setNavigationDelegate:[ASWebAuthenticator shared]];
            controller = [[NSViewController alloc] init];
            controller.view = webView;
            controller.preferredContentSize = NSMakeSize(750, 750);
            [viewController presentViewControllerAsModalWindow:controller];
}

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session  API_AVAILABLE(macos(10.15)){
    return NSApplication.sharedApplication.keyWindow;
}

@end
