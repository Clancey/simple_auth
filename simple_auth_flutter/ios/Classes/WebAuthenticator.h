//
//  WebAuthenticator.h
//  Runner
//
//  Created by James Clancey on 6/6/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface WebAuthenticator : NSObject
@property NSString *identifier;
@property NSURL *initialUrl;
@property NSURL *redirectUrl;
@property NSString *title;
@property BOOL allowsCancel;
@property BOOL isCompleted;
@property BOOL useEmbeddedBrowser;
@property FlutterEventSink eventSink;
-(void)checkUrl:(NSURL *)url forceComplete:(BOOL)force;
-(void)foundToken;
-(void)cancel;
-(void)failed:(NSString*)error;
-(id)initFromDictionary:(NSDictionary *)data_;
@property void (^onTokenFound)(void);
@end
