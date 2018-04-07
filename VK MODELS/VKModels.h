//
//  VKModels.h
//  VK GPM
//
//  Created by Clyde Barrow on 03.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс на основе которого будут другие классы токенов, сообщений, групп

#import <Foundation/Foundation.h>

@interface VKModels : NSObject

- (instancetype)initWithResponseObject:(NSDictionary *)dictionary;

@end
