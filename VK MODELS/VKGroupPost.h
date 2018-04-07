//
//  VKGroupPost.h
//  VK GPM
//
//  Created by Clyde Barrow on 12.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс поста группы


#import "VKModels.h"


@interface VKGroupPost : VKModels

//  Определение блока
typedef void(^VKPostLoad)(VKGroupPost * post);


//  Текст и дата сообщения
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSDate * date;

//  Имя и фото группы или автора
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSURL * url;

//  Индекс сообщения в группе
@property (nonatomic, assign) NSInteger index;

//  Флаг рекламы
@property (nonatomic, assign) BOOL ads;

//  Подпись под сообщением
@property (nonatomic, strong) NSString * signerName;


//  Создание поста из коллекции с блоком выполнения
- (void) postWithDictionary:(NSDictionary *)dict completionBlock:(VKPostLoad)completionBlock;


@end
