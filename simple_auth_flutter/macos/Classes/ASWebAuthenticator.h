//
//  ASWebAuthenticator.h
//  Pods
//
//  Created by Scott MacDougall on 2020-07-03.
//

#import <Foundation/Foundation.h>
#import "WebAuthenticator.h"
#import "Webkit/Webkit.h"
#import <AuthenticationServices/AuthenticationServices.h>

@interface ASWebAuthenticator : NSObject<ASWebAuthenticationPresentationContextProviding>
+ (ASWebAuthenticator *) shared;
+ (void) presentAuthenticator:(WebAuthenticator *)authenticator;
+ (void) presentAuthenticatorFromViewController:(WebAuthenticator *)authenticator viewController:(NSViewController*)viewController;
+ (bool) verifyHasScheme:(NSString *)scheme;
- (void) dismissController;
- (BOOL) resumeAuth:(NSURL*)url;
- (void) beginAuthentication:(WebAuthenticator *)authenticator viewController:(NSViewController *)viewController;
+ (NSMutableDictionary*) authenticators;
@end
