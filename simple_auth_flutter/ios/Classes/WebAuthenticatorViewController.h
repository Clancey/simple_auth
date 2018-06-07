//
//  WebAuthenticatorViewController.h
//  Runner
//
//  Created by James Clancey on 6/6/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WebAuthenticator.h"

@interface WebAuthenticatorViewController : UIViewController<UIWebViewDelegate>
@property void (^dismiss)(void);
@property WebAuthenticator *authenticator;
-(id)initWithAuthenticator:(WebAuthenticator *)authenticator;
@end
