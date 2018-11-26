//
//  SFSafariAuthenticator.m
//  Pods-Runner
//
//  Created by James Clancey on 6/6/18.
//

#import "SFSafariAuthenticator.h"
#import <SafariServices/SafariServices.h>

@implementation SFSafariAuthenticator

+ (SFSafariAuthenticator *) shared
{
    static dispatch_once_t once;
    static SFSafariAuthenticator *sharedObject;
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
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        UIViewController *root = window.rootViewController;
        [SFSafariAuthenticator.authenticators setObject:authenticator  forKey:authenticator.redirectUrl.scheme];

        if(root != nil)
        {
            UIViewController *current = root;
            while (current.presentedViewController != nil) {
                current = current.presentedViewController;
            }
            [SFSafariAuthenticator presentAuthenticatorFromViewController:authenticator viewController:current];
        }
    });
}
+(void)presentAuthenticatorFromViewController:(WebAuthenticator *)authenticator viewController:(UIViewController *)viewController{
    [SFSafariAuthenticator.shared beginAuthentication:authenticator viewController:viewController];
}

SFAuthenticationSession *session;
SFSafariViewController *controller;
-(void) beginAuthentication:(WebAuthenticator *)authenticator viewController:(UIViewController *)viewController{
    @try{
        NSString *scheme = authenticator.redirectUrl.scheme;
        if(@available(iOS 11.0, *))
        {
            session =  [[SFAuthenticationSession alloc] initWithURL:authenticator.initialUrl callbackURLScheme:scheme completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
                if(error == nil)
                {
                    [authenticator checkUrl:callbackURL forceComplete:YES];
                }
                else{
                    [authenticator failed:error.localizedDescription];
                }
            }];
            if(![session start])
                [authenticator failed:@"error setting up SFAuthenticationSession"];
            return;
        }
        if(![SFSafariAuthenticator verifyHasScheme:scheme]){
            [authenticator failed:[NSString stringWithFormat:@"CFBundleURLTypes is missing CFBundleURLSchemes, Missing Scheme: %@",scheme]];
            return;
        }
        if(@available(iOS 9.0, *)) {
            controller = [[SFSafariViewController alloc] initWithURL:authenticator.initialUrl];
            controller.delegate = self;
            [viewController presentViewController:controller animated:true completion:nil];
            return;
        }
        BOOL opened = [UIApplication.sharedApplication openURL:authenticator.initialUrl];
        if(!opened)
        {
            [authenticator failed:@"error opening safari"];
        }
    }
    @catch(NSException *ex)
    {
        [authenticator failed:ex.description];
    }
}

-(void) dismisController
{
    if(controller != nil){
        [controller dismissViewControllerAnimated:true completion:nil];
    }
    controller = nil;
    
}
-(BOOL)resumeAuth:(NSURL *)url{
    NSString *scheme = url.scheme;
    id obj = [SFSafariAuthenticator.authenticators objectForKey:scheme];
    if(![obj isKindOfClass:[WebAuthenticator class]])
        return false;
    WebAuthenticator *authenticator = (WebAuthenticator*)obj;
    [authenticator checkUrl:url forceComplete:YES];
    [SFSafariAuthenticator.authenticators removeObjectForKey:scheme];
    [self dismisController];
    return YES;
}

+(BOOL) verifyHasScheme: (NSString *)scheme{
    if(@available(iOS 11.0, *))
    {
        return true;
    }
    NSArray* schemes = [SFSafariAuthenticator getUrlSchemes];
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

@end
