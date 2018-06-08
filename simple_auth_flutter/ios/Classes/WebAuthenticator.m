//
//  WebAuthenticator.m
//  Runner
//
//  Created by James Clancey on 6/6/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import "WebAuthenticator.h"
#import <Flutter/Flutter.h>

@implementation WebAuthenticator
-(id)initFromDictionary:(NSDictionary *)data_
{
    self = [super init];
    NSLog(@"Authenticator created");
    if(self) {
        self.identifier = [data_ valueForKey:@"identifier"];
        self.allowsCancel = [[data_ valueForKey:@"allowsCancel"] boolValue];
        self.useEmbeddedBrowser =[[data_ valueForKey:@"useEmbeddedBrowser"] boolValue];
        self.initialUrl = [NSURL URLWithString:[data_ valueForKey:@"initialUrl"]];
        self.redirectUrl = [NSURL URLWithString:[data_ valueForKey:@"redirectUrl"]];
        self.title = [data_ valueForKey:@"title"];
    }
    return self;
}
-(void)cancel{
    _eventSink(@{
                 @"identifier" : self.identifier,
                 @"url" : @"canceled"
                 });
}
-(void)foundToken{
    self.isCompleted = YES;
    _onTokenFound();
}
-(void) checkUrl:(NSURL *)url forceComplete:(BOOL)force
{
    _eventSink(@{
                 @"identifier" : self.identifier,
                 @"url" : url.absoluteString,
                 @"forceComplete" : force ? @"true" : @"false"
                 });
}
-(void) failed:(NSString *)error{
    _eventSink(@{
                 @"identifier" : self.identifier,
                 @"url" : @"error",
                 @"description": error.description,
                 @"forceComplete" : @"true"
                 });
}
@end
