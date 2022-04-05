//
//  AuthStorage.h
//  Pods-Runner
//
//  Created by James Clancey on 6/7/18.
//

#import <Foundation/Foundation.h>

@interface AuthStorage : NSObject
+ (AuthStorage *) shared;
- (NSString*)getValueForKey:(NSString*)key;
- (void)saveValue:(NSString*)value for:(NSString*)key;
@end
