//
//  VKGroupPost.h
//  VK GPM
//
//  Created by Clyde Barrow on 12.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKModels.h"




@interface VKGroupPost : VKModels

//
typedef void(^VKPostLoad)(VKGroupPost * post);
//

@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSDate * date;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSURL * url;

@property (nonatomic, assign) NSInteger index;


//
- (void) postWithDictionary:(NSDictionary *)dict completionBlock:(VKPostLoad)completionBlock;
//

@end
