//
//  VKGroup.h
//  VK GPM
//
//  Created by Clyde Barrow on 10.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKModels.h"

@interface VKGroup : VKModels

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSURL * photoURL;
@property (nonatomic, strong) NSString * groupID;

@end
