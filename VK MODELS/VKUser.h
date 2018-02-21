//
//  VKUser.h
//  VK GPM
//
//  Created by Clyde Barrow on 03.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKModels.h"


@interface VKUser : VKModels

//string
@property (nonatomic, strong) NSString * domain;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * nickName;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * screenName;


//integer
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger lastSeenPlatform;


//BOOL
@property (nonatomic, assign) BOOL hasMobile;
@property (nonatomic, assign) BOOL online;


//other
@property (nonatomic, strong) NSDate * lastSeenTime;


//NSURL
@property (nonatomic, strong) NSURL * photo;






@end
