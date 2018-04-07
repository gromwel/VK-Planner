//
//  CoreDataManager.h
//  VK GPM
//
//  Created by Clyde Barrow on 05.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс реализующий паттерн singleton взаимодействия с кор датой

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class VKToken;

@interface CoreDataManager : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;
+ (CoreDataManager *) sharedManager;


    
- (void) deleteAllToken;
- (VKToken *) newTokenWithDictionary:(NSDictionary *)dict;
- (VKToken *) token;

@end
