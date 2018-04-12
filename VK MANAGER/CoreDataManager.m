//
//  CoreDataManager.m
//  VK GPM
//
//  Created by Clyde Barrow on 05.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "CoreDataManager.h"
#import "VKToken+CoreDataClass.h"
#import "VKToken+CoreDataProperties.h"
#import "UIColor+VKUIColor.h"

@implementation CoreDataManager


#pragma mark - Singleton
+ (CoreDataManager *) sharedManager {
    static CoreDataManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CoreDataManager alloc] init];
    });
    return manager;
}



#pragma mark - Core Data stack
@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"VK_GPM"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    return _persistentContainer;
}


#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}





#pragma mark - MethodsWithToken
//  Создание нового токена из коолекции полученной с сервера
- (VKToken *) newTokenWithDictionary:(NSDictionary *)dict {
    
    //  Проверяем на наличие токенов а кор дате
    NSError * error = nil;
    NSArray * array = [self.persistentContainer.viewContext executeFetchRequest:[VKToken fetchRequest]
                                                                          error:&error];
    
    //  Если токен есть то удаляем его
    if (array.count > 0) {
        [self deleteAllToken];
    }
    
    //  Создаем токен
    VKToken * token = [NSEntityDescription insertNewObjectForEntityForName:@"VKToken"
                                                    inManagedObjectContext:self.persistentContainer.viewContext];
    
    //  Определяем его параметры
    token.token = [dict objectForKey:@"access_token"];
    token.userID = [dict objectForKey:@"user_id"];
    
    
    //  Проверяем наличие времени существования токена
    if ([[dict objectForKey:@"expires_in"] doubleValue] == 0) {
        token.offline = YES;
    } else {
        token.offline = NO;
        NSTimeInterval interval = [[dict objectForKey:@"expires_in"] doubleValue];
        token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    }
    
    
    //  Сохраняем
    [self saveContext];
    return token;
}



//  Удаление всех токенов в кор дате
- (void) deleteAllToken {
    NSManagedObjectContext * context = self.persistentContainer.viewContext;
    NSError * error = nil;
    NSArray * array = [context executeFetchRequest:[VKToken fetchRequest]
                                             error:&error];
    for (VKToken * token in array) {
        [context deleteObject:token];
    }
    [self saveContext];
}



//  Возвращаем токен из кор даты
- (VKToken *) token {
    NSError * error = nil;
    NSArray * array = [self.persistentContainer.viewContext executeFetchRequest:[VKToken fetchRequest]
                                                                          error:&error];
    
    //  Так как должен быть только один токен, проверяем на случай если токенов больше
    if (array.count == 1) {
        VKToken * token = [array firstObject];
        return token;
    } else {
        NSLog(@"НЕПОНЯТНО СКОЛЬКО ТОКЕНОВ = %li", array.count);
    }
    return nil;
}

@end
