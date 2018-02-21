//
//  VKGroup.m
//  VK GPM
//
//  Created by Clyde Barrow on 10.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKGroup.h"

@implementation VKGroup

- (instancetype)initWithResponseObject:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.name = [dictionary objectForKey:@"name"];
        self.type = [dictionary objectForKey:@"type"];
        
        if ([dictionary objectForKey:@"photo"]) {
            NSString * stringURL = [dictionary objectForKey:@"photo"];
            self.photoURL = [NSURL URLWithString:stringURL];
        }
        
        NSInteger intGID = [[dictionary objectForKey:@"gid"] integerValue];
        NSString * gid = [NSString stringWithFormat:@"%li", intGID];
        self.groupID = gid;
    }
    return self;
}

@end
