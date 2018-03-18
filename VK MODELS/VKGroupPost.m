//
//  VKGroupPost.m
//  VK GPM
//
//  Created by Clyde Barrow on 12.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#define VK_API_VERSION              @"5.8"

#import "VKGroupPost.h"
#import <AFHTTPSessionManager.h>


typedef enum {
    typeIDUser,
    typeIDGroup
} typeID;

@interface VKGroupPost ()

@property (nonatomic, strong) VKPostLoad completionBlock;

@end



@implementation VKGroupPost


- (instancetype)initWithResponseObject:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        //текст
        self.text = [dictionary objectForKey:@"text"];
        
        
        //дата
        NSString * dateString = [dictionary objectForKey:@"date"];
        NSTimeInterval time = [dateString doubleValue];
        self.date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
        
        
        //отправитель
        NSNumber * number = [dictionary objectForKey:@"from_id"];
        [self infoFromID:number];
        
    }
    return self;
}

- (void) postWithDictionary:(NSDictionary *)dict completionBlock:(VKPostLoad)completionBlock {
    
    
    VKGroupPost * post = [[VKGroupPost alloc] init];
    
    post.text = [dict objectForKey:@"text"];
    
    post.index = [[dict objectForKey:@"id"] integerValue];
    
    //дата
    NSString * dateString = [dict objectForKey:@"date"];
    NSTimeInterval time = [dateString doubleValue];
    post.date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    
    
    //отправитель
    NSNumber * number = [dict objectForKey:@"from_id"];
    NSInteger num = [number integerValue];
    NSString * str = [NSString stringWithFormat:@"%li", num];
    
    NSURL * baseURL = [[NSURL alloc] initWithString:@"https://api.vk.com/method/"];
    AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    
    NSString * method = @"";
    NSString * keyID = @"";
    NSString * stringID = @"";
    
    typeID type = -1;
    
    
    if ([str hasPrefix:@"-"]) {
        method = @"groups.getById";
        keyID = @"group_id";
        stringID = [str substringFromIndex:1];
        type = typeIDGroup;
        
    } else {
        method = @"users.get";
        keyID = @"user_ids";
        stringID = str;
        type = typeIDUser;
    }
    
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 stringID, keyID,
                                 @"photo_100", @"fields",
                                 VK_API_VERSION, @"version", nil];
    
    [manager GET:method
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSDictionary * dict = [[responseObject objectForKey:@"response"] firstObject];
             
             //имя
             if (type == typeIDUser) {
                 NSString * firstName = [dict objectForKey:@"first_name"];
                 NSString * lastName = [dict objectForKey:@"last_name"];
                 post.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                 
             } else if (type == typeIDGroup) {
                 post.name = [dict objectForKey:@"name"];
             }
             
             //фото
             NSString * stringURL = [dict objectForKey:@"photo_100"];
             post.url = [NSURL URLWithString:stringURL];
             
             
             if (completionBlock) {
                 completionBlock(post);
             }
             
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
         }];
}


- (void) infoFromID:(NSNumber *)numberID {
    NSInteger num = [numberID integerValue];
    NSString * str = [NSString stringWithFormat:@"%li", num];
    
    NSURL * baseURL = [[NSURL alloc] initWithString:@"https://api.vk.com/method/"];
    AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    
    NSString * method = @"";
    NSString * keyID = @"";
    NSString * stringID = @"";
    
    typeID type = -1;
    
    
    if ([str hasPrefix:@"-"]) {
        method = @"groups.getById";
        keyID = @"group_id";
        stringID = [str substringFromIndex:1];
        type = typeIDGroup;
        
    } else {
        method = @"users.get";
        keyID = @"user_ids";
        stringID = str;
        type = typeIDUser;
    }

    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     stringID, keyID,
                                     @"photo_100", @"fields",
                                     VK_API_VERSION, @"version", nil];
    
    [manager GET:method
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSDictionary * dict = [[responseObject objectForKey:@"response"] firstObject];
             
             //имя
             if (type == typeIDUser) {
                 NSString * firstName = [dict objectForKey:@"first_name"];
                 NSString * lastName = [dict objectForKey:@"last_name"];
                 self.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                 
             } else if (type == typeIDGroup) {
                 self.name = [dict objectForKey:@"name"];
             }
             
             //фото
             NSString * stringURL = [dict objectForKey:@"photo_100"];
             self.url = [NSURL URLWithString:stringURL];
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
         }];
}

@end
