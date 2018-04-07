//
//  VKAccessToken.h
//  VK GPM
//
//  Created by Clyde Barrow on 03.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс токена

#import <Foundation/Foundation.h>

@interface VKAccessToken : NSObject

//  Проперти токена
@property (nonatomic, strong) NSString * token;
@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSDate * expirationDate;
@property (nonatomic, assign) BOOL offline;


//  Инициализация токена из коллекции
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
