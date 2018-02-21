//
//  VKAccessToken.m
//  VK GPM
//
//  Created by Clyde Barrow on 03.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKAccessToken.h"

@implementation VKAccessToken

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.token = [dict objectForKey:@"access_token"];
        self.userID = [dict objectForKey:@"user_id"];
        
        if ([[dict objectForKey:@"expires_in"] doubleValue] == 0) {
            self.offline = YES;
        } else {
            self.offline = NO;
            NSTimeInterval interval = [[dict objectForKey:@"expires_in"] doubleValue];
            self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        }
    }
    return self;
}

@end
