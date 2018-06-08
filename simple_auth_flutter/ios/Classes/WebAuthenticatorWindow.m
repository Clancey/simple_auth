//
//  WebAuthenticatorWindow.m
//  Runner
//
//  Created by James Clancey on 6/5/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import "WebAuthenticatorWindow.h"
#import "WebAuthenticatorViewController.h"

@implementation WebAuthenticatorWindow

+ (WebAuthenticatorWindow *) shared
{
    static dispatch_once_t once;
    static WebAuthenticatorWindow *sharedObject;
    dispatch_once(&once, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

+(void)presentAuthenticator:(WebAuthenticator *)authenticator {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"presenting the authenticator");
        WebAuthenticatorViewController* vc = [[WebAuthenticatorViewController alloc] initWithAuthenticator:authenticator];
        [WebAuthenticatorWindow.shared Show:vc];
        NSLog(@"presenting the authenticator completed");
    });
}
UIWindow* previousWindow;
- (void) Show:(WebAuthenticatorViewController *)authenticator {
    if(!self.isKeyWindow)
    {
        NSLog(@"getting previous window");
        previousWindow = UIApplication.sharedApplication.keyWindow;
        self.rootViewController = [[UIViewController alloc] init];
        NSLog(@"making window key and visible");
        [self makeKeyAndVisible];
    }
    authenticator.dismiss = ^(){
        [self dismiss];
    };
    [self.rootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:authenticator] animated:true completion:nil];
}

- (void) dismiss
{
    [self.rootViewController dismissViewControllerAnimated:true completion:nil];
    if(previousWindow != nil)
        [previousWindow makeKeyAndVisible];
    self.rootViewController = nil;
    self.hidden = true;
    [self removeFromSuperview];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
