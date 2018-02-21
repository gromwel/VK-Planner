//
//  VKUser.m
//  VK GPM
//
//  Created by Clyde Barrow on 03.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKUser.h"

@implementation VKUser

- (instancetype) initWithResponseObject:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        
        //NSString
        self.domain = [dictionary objectForKey:@"domain"];
        self.firstName = [dictionary objectForKey:@"first_name"];
        self.lastName = [dictionary objectForKey:@"last_name"];
        self.nickName = [dictionary objectForKey:@"nickname"];
        self.status = [dictionary objectForKey:@"status"];
        self.screenName = [dictionary objectForKey:@"screen_name"];
        
        
        //NSURL
        NSString * url = [dictionary objectForKey:@"photo_max_orig"];
        self.photo = [NSURL URLWithString:url];

        
        //NSInteger
        self.uid = [[dictionary objectForKey:@"uid"] integerValue];
        NSDictionary * lastSeen = [dictionary objectForKey:@"last_seen"];
        self.lastSeenPlatform = [[lastSeen objectForKey:@"platform"] integerValue];
        double time = [[lastSeen objectForKey:@"time"] doubleValue];
        self.lastSeenTime = [NSDate dateWithTimeIntervalSinceNow:time];
        
        //BOOL
        if ([dictionary objectForKey:@"has_mobile"]) {
            self.hasMobile = [[dictionary objectForKey:@"has_mobile"] boolValue];
        }
        if ([dictionary objectForKey:@"online"]) {
            self.online = [[dictionary objectForKey:@"online"] boolValue];
        }
    }
    return self;
}

@end
