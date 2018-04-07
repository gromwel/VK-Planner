//
//  VKRequestManager.h
//  VK GPM
//
//  Created by Clyde Barrow on 02.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс в котором реализованы методы запроса к vk.com


#import <Foundation/Foundation.h>
#import "VKNewPostViewController.h"


@class VKUser;
@class VKGroup;


//  Энум типа возвращаемых сообщений
//  (только опубликованные, отложенные, только количество отложенных, опубликованных)
typedef enum {
    VKPostResponseTypePublished,                    //  вернуть опубликованные сообщения
    VKPostResponseTypePublichedOnlyCount,           //  вернуть только количество опубликованных сообщений
    VKPostResponseTypePostponed,                    //  вернуть отложенные сообщения
    VKPostResponseTypePostponedOnlyCount            //  вернуть только количество отложенных сообщений
} VKPostResponseType;


@interface VKRequestManager : NSObject


//  Синглтон
+ (VKRequestManager *) sharedManager;

//  Авторизация юзера
- (void) autorisationUser;

//  Вызов экрана авторизации
- (void) autorisationUserWithSplashScreen;

//  Выход из текущего аккаунта
- (void) logoutUser;



//  Получение информации о юзере по его ID
- (void) getUserWithUserID:(NSString *)userID onSuccess:(void(^)(VKUser * user))success onFailure:(void(^)(NSError * error))failure;

//  Получение списка групп залогиненного пользователя
//  В которых он является администратором
- (void) getGroupsWithOffset:(NSInteger)offset count:(NSInteger)count onSucces:(void(^)(NSArray * groups))succes onFailure:(void(^)(NSError * error))failure;

//  Получение записей стены группы по ее ID
- (void) getPostsOnWallGroupID:(NSString *)groupID offset:(NSInteger)offset count:(NSInteger)count responseType:(VKPostResponseType)responseType onSuccess:(void(^)(NSArray * posts, NSInteger count))success onFailure:(void(^)(NSError * error))failure;

//  Публикация записи на стену группы
- (void) postWallMessageWithOwnerID:(NSString *)ownerID message:(NSString *)message publishDate:(NSInteger)publishDate ads:(NSInteger)flagAds signed:(NSInteger)flagSigned onSuccess:(void(^)(id successesMessage))success onFailure:(void(^)(NSError * error))failure;

//  
- (void) newWallMessageWithGroup:(VKGroup *)group onSuccess:(void(^)(id responseObject, VKPostType postType))success onFailure:(void(^)(NSError * error))failure;

@end
