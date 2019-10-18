//
//  WebAuthenticatorViewController.m
//  Runner
//
//  Created by James Clancey on 6/6/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import "WebAuthenticatorViewController.h"
#import "WebAuthenticator.h"
#import "WebAuthenticatorWindow.h"

@implementation WebAuthenticatorViewController
WKWebView *webview;
UIActivityIndicatorView *activity;

-(id)initWithAuthenticator:(WebAuthenticator *)authenticator
{
    self = [super init];
    NSLog(@"webauthenticator init");
    if (self) {
        self.authenticator = authenticator;
        NSLog(@"set authenticator");
        if(authenticator.title != nil){
            self.title = authenticator.title;
        }
        NSLog(@"set title");
        if(self.authenticator.allowsCancel)
        {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        }
        __weak typeof(self) weakSelf = self;
        self.authenticator.onTokenFound = ^(){
            [webview stopLoading];
            weakSelf.dismiss();
        };
        NSLog(@"set ontokenFound");
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        NSLog(@"setup activity");
        UIBarButtonItem *refreshButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
        UIBarButtonItem *activityButton =[[UIBarButtonItem alloc] initWithCustomView:activity];
        NSLog(@"setting nav buttons");
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton, activityButton, nil];
        NSLog(@"set nav buttons");
    }
    NSLog(@"webauthenticator init complete");
    return self;
}

- (void) viewDidLoad{
    NSLog(@"webauthenticator view did load");
    self.view.backgroundColor = UIColor.blackColor;
    webview = [[WKWebView alloc] init];
    webview.UIDelegate = self;
    [self.view addSubview:webview];
}
-(void)viewDidAppear:(BOOL)animated{
    [webview loadRequest:[NSURLRequest requestWithURL:self.authenticator.initialUrl]];
}

-(void) viewDidLayoutSubviews{
    webview.frame = self.view.bounds;
}

-(void)cancel
{
    NSLog(@"Canceled");
    [self.authenticator cancel];
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if ([window isKindOfClass:[WebAuthenticatorWindow class]])
    {
        WebAuthenticatorWindow *webWindow = (WebAuthenticatorWindow *)window;
        [webWindow dismiss];
    }
}
-(void)refresh {
    [webview reload];
}
-(BOOL)webView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigation *)navigationType{
    if(!self.authenticator.isCompleted){
        [self.authenticator checkUrl:request.URL forceComplete:NO];
    }
    return true;
}
-(void)webViewDidStartLoad:(WKWebView *)webView{
    [activity startAnimating];
}
-(void)webViewDidFinishLoad:(WKWebView *)webView{
    [activity stopAnimating];
}
-(void)webView:(WKWebView *)webView didFailLoadWithError:(NSError *)error{
    [activity stopAnimating];
}

@end
