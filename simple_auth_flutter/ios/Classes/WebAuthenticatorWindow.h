//
//  WebAuthenticatorWindow.h
//  Runner
//
//  Created by James Clancey on 6/5/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <Flutter/Flutter.h>
#import "WebAuthenticatorViewController.h"

@interface WebAuthenticatorWindow : UIWindow
+ (WebAuthenticatorWindow *) shared;
+ (void) presentAuthenticator:(WebAuthenticator *)authenticator;
- (void) dismiss;
@end
