//
//  VKGroup.h
//  VK GPM
//
//  Created by Clyde Barrow on 10.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//
//  Класс группы

#import "VKModels.h"

@interface VKGroup : VKModels

//  Имя и тип группы
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * type;

//  Ссылка на фото
@property (nonatomic, strong) NSURL * photoURL;

//  ID группы
@property (nonatomic, strong) NSString * groupID;

@end
