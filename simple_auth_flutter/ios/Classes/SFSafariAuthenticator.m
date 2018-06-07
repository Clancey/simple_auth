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

+(void)presentAuthenticator:(WebAuthenticator *)authenticator {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"presenting the authenticator");
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        UIViewController *root = window.rootViewController;
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
    if(@available(iOS 11.0, *))
    {
        
    }
    else{
        //TODO: check Bundle URL Schemes
    }
    [SFSafariAuthenticator.shared beginAuthentication:authenticator viewController:viewController];
}

    SFAuthenticationSession *session;
-(void) beginAuthentication:(WebAuthenticator *)authenticator viewController:(UIViewController *)viewController{
   if(@available(iOS 11.0, *))
   {
       NSString *scheme = authenticator.redirectUrl.scheme;
       session =  [[SFAuthenticationSession alloc] initWithURL:authenticator.initialUrl callbackURLScheme:scheme completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
           if(error == nil)
           {
               [authenticator checkUrl:callbackURL];
           }
           else{
               [authenticator failed:error.localizedDescription];
           }
       }];
       if(![session start])
           [authenticator failed:@"error setting up SFAuthenticationSession"];
   }
   
}
@end
