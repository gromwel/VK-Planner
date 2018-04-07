//
//  VKUser.h
//  VK GPM
//
//  Created by Clyde Barrow on 03.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//
//  Класс юзера

#import <Foundation/Foundation.h>
#import "VKModels.h"


@interface VKUser : VKModels

//  Имя, никнейм, домен, статус
@property (nonatomic, strong) NSString * domain;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * nickName;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * screenName;


//  ID пользователя и платфорбма
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger lastSeenPlatform;


//  Флаги С МОБИЛЬНОГО и ОНЛАЙН
@property (nonatomic, assign) BOOL hasMobile;
@property (nonatomic, assign) BOOL online;


//  Дата
@property (nonatomic, strong) NSDate * lastSeenTime;


//  Ссылка на фото
@property (nonatomic, strong) NSURL * photo;


@end
