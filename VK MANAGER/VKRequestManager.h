//
//  VKRequestManager.h
//  VK GPM
//
//  Created by Clyde Barrow on 02.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VKUser;
@class VKGroup;

@interface VKRequestManager : NSObject

+ (VKRequestManager *) sharedManager;

- (void) autorisationUser;
- (void) autorisationUserWithSplashScreen;
- (void) logoutUser;

- (void) getUserWithUserID:(NSString *)userID onSuccess:(void(^)(VKUser * user))success onFailure:(void(^)(NSError * error))failure;
- (void) getGroupsWithOffset:(NSInteger)offset count:(NSInteger)count onSucces:(void(^)(NSArray * groups))succes onFailure:(void(^)(NSError * error, NSInteger statusCode))failure;
- (void) getPostsOnWallGroupID:(NSString *)groupID offset:(NSInteger)offset count:(NSInteger)count onSuccess:(void(^)(NSArray * posts, NSInteger count))success onFailure:(void(^)(NSError * error, NSInteger statusCode))failure;

- (void) postWallMessageWithOwnerID:(NSString *)ownerID message:(NSString *)message publishDate:(NSInteger)publishDate onSuccess:(void(^)(id successesMessage))success onFailure:(void(^)(NSError * error))failure;



- (void) newWallMessageWithGroup:(VKGroup *)group onSuccess:(void(^)(id responseObject))success onFailure:(void(^)(NSError * error))failure;

@end
