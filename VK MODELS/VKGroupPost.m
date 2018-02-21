//
//  VKGroupPost.m
//  VK GPM
//
//  Created by Clyde Barrow on 12.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKGroupPost.h"

@implementation VKGroupPost

- (instancetype)initWithResponseObject:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.text = [dictionary objectForKey:@"text"];
    }
    return self;
}

@end
