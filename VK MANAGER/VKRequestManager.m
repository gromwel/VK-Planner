//
//  VKRequestManager.m
//  VK GPM
//
//  Created by Clyde Barrow on 02.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Реализация класса запросов к API vk.com


//  Определяем переменную для версии API
#define VK_API_VERSION              @"5.8"


#import "VKRequestManager.h"
#import "VKLogInViewController.h"
#import <AFHTTPSessionManager.h>
#import "VKUser.h"
#import "VKToken+CoreDataClass.h"
#import "VKStartAutorizationViewController.h"
#import "CoreDataManager.h"
#import "VKGroup.h"
#import "VKGroupPost.h"
#import "VKNewPostViewController.h"


@interface VKRequestManager()

@property (nonatomic, strong) AFHTTPSessionManager * sessionManager;
@property (nonatomic, strong) VKToken * accessToken;
@property (nonatomic, strong) NSMutableArray * loadPosts;
@property (nonatomic, assign) NSInteger postsCount;

@end



@implementation VKRequestManager

#pragma mark - singletonInit
//  Инициализация синглтона
+ (VKRequestManager *) sharedManager {
    static VKRequestManager * manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VKRequestManager alloc] init];
    });
    
    return manager;
}


//  Установка токена
- (void) setAccessToken:(VKToken *)accessToken {
    _accessToken = accessToken;
}


//  Инициализация объекта класса
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        //  Установка атрибутов свойств необходимых для запросов
        NSURL * baseURL = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        
        //  Если в кор дате есть токен то устанавливаем его
        if ([[CoreDataManager sharedManager] token]) {
            self.accessToken = [[CoreDataManager sharedManager] token];
        }
    }
    return self;
}



#pragma mark - logInUserMethods
//  Авторизация юзера без экрана
- (void) autorisationUser {
    
    //  Берем токен
    VKLogInViewController * vc = [[VKLogInViewController alloc] initWithCompletionBlock:^(VKToken *token) {
        if (token) {
            self.accessToken = token;
        }
    }];
    
    //  Создаем навигейшн с рутом -
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //  Вычисляем текущий вью что бы из него показать
    UIViewController * currentVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    //  Презентуем вью
    [currentVC presentViewController:navc animated:YES completion:^{}];
}



//  Авторизация юзера с экраном
- (void) autorisationUserWithSplashScreen {
    
    //  Если в памяти нет токена
    if (![[CoreDataManager sharedManager] token]) {
        
        //1. Создаем вьюконтроллер из сториборда
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VKStartAutorizationViewController * splashScreenVK = [storyboard instantiateViewControllerWithIdentifier:@"VKStartAutorizationViewController"];
        
        //  Берем токен
        [splashScreenVK takeToken:^(VKToken *token) {
            if (token) {
                self.accessToken = token;
            }
        }];
        
        
        //2. Навигейшн контроллер с рут контроллером -
        UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:splashScreenVK];
        
        //3. Берем текущий вью что бы из него вызвать экран авторизации
        UIViewController * current = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        
        //4. Показываем экран авторизации
        [current presentViewController:navigation animated:YES completion:^{}];
        
    
    //  Если в памяти есть токен
    } else {
    }
}



//  Выход из аккаунта
//  Так как vk не дает API для полного выхода из аккаунта
//  Просто удаляем токен из памяти
- (void) logoutUser {
    
    //  Создаем алерт контролеер с вопросом о выходе
    UIAlertController * alert = [[UIAlertController alloc] init];
    
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Отмена"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                          }];
    
    UIAlertAction * actionLogout = [UIAlertAction actionWithTitle:@"Выйти"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              //    Удаляем токен
                                                              [[CoreDataManager sharedManager] deleteAllToken];
                                                              [self autorisationUserWithSplashScreen];
                                                              
                                                              
                                                              //    Удаляем настройки кнопок в окне нового сообщения
                                                              [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"buttons"];;
                                                          }];
    
    [alert addAction:actionCancel];
    [alert addAction:actionLogout];
    
    //  Показываем алерт
    UIViewController * vc = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    [vc presentViewController:alert animated:YES completion:^{
    }];
}




#pragma mark - POSTRequests
//  Отправка сообщения на стену группы
- (void) postWallMessageWithOwnerID:(NSString *)ownerID
                            message:(NSString *)message
                        publishDate:(NSInteger)publishDate
                                ads:(NSInteger)flagAds
                             signed:(NSInteger)flagSigned
                          onSuccess:(void(^)(id successesMessage))success
                          onFailure:(void(^)(NSError * error))failure {
    
    
    //  ID группы должен содержать тире, если его нет то надо добавить
    if (![ownerID hasPrefix:@"-"]) {
        ownerID = [@"-" stringByAppendingString:ownerID];
    }

    
    //  Определение метода и параметров
    NSString * method = @"wall.post";
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 ownerID, @"owner_id",
                                 message, @"message",
                                 @(flagSigned), @"signed",
                                 @(flagAds), @"mark_as_ads",
                                 @"1", @"from_group",
                                 @(publishDate), @"publish_date",
                                 self.accessToken.token, @"access_token",
                                 VK_API_VERSION, @"version", nil];
    
    
    //  Отправка нового сообщения стены
    [self.sessionManager POST:method
                   parameters:parameters
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          
                          //    Если есть реализация блока то передаем туда ответ от vk
                          if (success) {
                              success(responseObject);
                          }
                          
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          
                          //    Если есть реализация блока отказа то передаем туда пришедший ответ от vk
                          if (failure) {
                              failure(error);
                          }
                      }];
}






#pragma mark - GETRequests
//  Запращиваем сообщения стены группы по ее ID
- (void) getPostsOnWallGroupID:(NSString *)groupID offset:(NSInteger)offset count:(NSInteger)count responseType:(VKPostResponseType)responseType onSuccess:(void(^)(NSArray * posts, NSInteger count))success onFailure:(void(^)(NSError * error))failure {
    
    //  ID группы должно содержать тире, если его нет - надо добавить
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    
    //  Определяем фильтр
    NSString * filterKey = @"all";
    
    //  Если необходимо получить отложенные сообщения то меняем фильтр
    if (responseType == VKPostResponseTypePostponed | responseType == VKPostResponseTypePostponedOnlyCount) {
        filterKey = @"postponed";
    }
    
    
    // Определение метода и параметров запроса
    NSString * method = @"wall.get";
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 groupID, @"owner_id",
                                 @(offset), @"offset",
                                 @(count), @"count",
                                 filterKey, @"filter",
                                 @(0), @"extended",
                                 @"first_name", @"fields",
                                 self.accessToken.token, @"access_token",
                                 VK_API_VERSION, @"version", nil];
    
    
    //  Отправка запроса на получение сообщений
    [self.sessionManager GET:method
                  parameters:parameters
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         // Берем массив сообщений из полученного ответа и общее количество сообщений стены группы
                         NSArray * arrayPosts = [responseObject objectForKey:@"response"];
                         NSInteger countPosts = [[arrayPosts firstObject] integerValue];
                         
                         // Если метод должен вернуть только общее количество сообщений
                         if (responseType == VKPostResponseTypePostponedOnlyCount | responseType == VKPostResponseTypePublichedOnlyCount) {
                            
                            //  Если есть реализация блока то передаем только количество сообщений
                            if (success) {
                                success(nil, countPosts);
                            }
                             
                        
                         // Если метод возвращает не только количество но и сами сообщения
                         } else if (responseType == VKPostResponseTypePostponed | responseType == VKPostResponseTypePublished) {
                                 
                            
                            self.loadPosts = [[NSMutableArray alloc] init];
                            self.postsCount = arrayPosts.count;
                            
                             
                            //  Если массив полученных сообщений содержит хоть один объект (больше одного, так как первый объект в массиве это не сообщение)
                            if (arrayPosts.count > 1) {
                                
                                //  Каждый объект в массиве представляет собой коллекцию ключ-значение
                                for (int i = 1; i < arrayPosts.count; i ++) {
                                    NSDictionary * dict = [arrayPosts objectAtIndex:i];
                                    
                                    //  Из каждой коллекции создаем объект класса VKGroupPost
                                    [[VKGroupPost alloc] postWithDictionary:dict completionBlock:^(VKGroupPost *post) {
                                        
                                        //  Когда объект создан, добавляем его в массив полученных сообщений
                                        [self.loadPosts addObject:post];
                                        
                                        //  Когда весь массив полученных сообщений обработан
                                        if (self.loadPosts.count == self.postsCount - 1) {
                                            
                                            //  Сортировка массива сообщений по дате их публикации
                                            [self.loadPosts sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                                
                                                VKGroupPost * post1 = (VKGroupPost *)obj1;
                                                VKGroupPost * post2 = (VKGroupPost *)obj2;
                                                
                                                NSTimeInterval intDate1 = [post1.date timeIntervalSince1970];
                                                NSTimeInterval intDate2 = [post2.date timeIntervalSince1970];
                                                    
                                                if (intDate1 < intDate2) {
                                                    return NSOrderedDescending;
                                                } else if (intDate1 > intDate2) {
                                                    return NSOrderedAscending;
                                                }
                                                
                                                return NSOrderedSame;
                                            }];
                                            
                                            
                                            //  Если есть реализация блока то передаем массив с сортированными сообщениями
                                            if (success) {
                                                success(self.loadPosts, countPosts);
                                            }
                                        }
                                    }];
                                }
                            }
                        }
                         
                     
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         // Если есть реализация блока отказа и пришел отказ то передаем это сообщение
                         if (failure) {
                             failure(error);
                         }
                     }];
}








//  Запрос информации юзера по его ID
- (void) getUserWithUserID:(NSString *)userID onSuccess:(void(^)(VKUser * user))success onFailure:(void(^)(NSError * error))failure {
    
    //  Определение метода и параметров запроса
    NSString * method = @"users.get";
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 userID, @"user_ids",
                                 @"first_name, photo_max_orig, online, domain, has_mobile, status, last_seen, nickname, screen_name", @"fields",
                                 VK_API_VERSION, @"version",
                                nil];
    

    //  Запрос информации о юзере
    [self.sessionManager GET:method
                  parameters:parameters
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         // Берем массив юзеров из пришедшей коллекции
                         NSArray * userArray = [responseObject objectForKey:@"response"];
                         
                         // Если массив юзеров бльше нуля
                         if (userArray.count > 0) {
                             
                             // Создаем объект VKUser из прешедшей коллекции
                             NSDictionary * userDict = [userArray firstObject];
                             VKUser * user = [[VKUser alloc] initWithResponseObject:userDict];
                             
                             // Если есть реализация блока то передаем юзера
                             if (success) {
                                 success(user);
                             }
                             
                         } else {
                             
                             // Если есть реализация блока отказа и юзеров не пришло то передаем нил
                             if (failure) {
                                 failure(nil);
                             }
                         }
                         
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         // Если есть реализация блока отказа и пришел отказа то передаем это сообщение
                         if (failure) {
                             failure(error);
                         }
                     }];
}



//  Запрос групп пользователя где от администратор
- (void) getGroupsWithOffset:(NSInteger)offset count:(NSInteger)count onSucces:(void(^)(NSArray * groups))succes onFailure:(void(^)(NSError * error))failure {
    
    //  Определяем метод и параметры запроса
    NSString * method = @"groups.get";
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 self.accessToken.userID, @"user_id",
                                 @"moder", @"filter",
                                 @"", @"fields",
                                 @(0), @"offset",
                                 @(15), @"count",
                                 @"1", @"extended",
                                 self.accessToken.token, @"access_token",
                                 VK_API_VERSION, @"version", nil];
    
    
    //  Делаем запрос списка групп пользователя которые он администрирует
    [self.sessionManager GET:method
                  parameters:parameters
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         // Берем массив объектов из пришедшей коллекции
                         NSArray * array = [responseObject objectForKey:@"response"];
                         
                         // Если массив больше чем из одного объекта то группы есть
                         if (array.count > 1) {
                             
                             // Создаем массив групп
                             NSMutableArray * groupsArray = [[NSMutableArray alloc] init];
                             
                             // Начинаем цикл со второго объекта так как первый это не группа а общее количество групп
                             for (int i = 1; i < array.count; i++) {
                                 
                                 // Из каждой пришедшей коллекции создаем объект класса VKGroup
                                 NSDictionary * object = [array objectAtIndex:i];
                                 VKGroup * group = [[VKGroup alloc] initWithResponseObject:object];
                                 [groupsArray addObject:group];
                             }
                             
                             // Если есть блок реализации ответа то передаем массив полученных групп
                             if (succes) {
                                 succes(groupsArray);
                             }
                             
                             
                         } else {
                             
                             // Если групп нет а реализация есть то передаем нил
                             if (succes) {
                                 succes(nil);
                             }
                         }
                         
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         // Если есть реализация блока отказа и пришел отказ то передаем это сообщение
                         if (failure) {
                             failure(error);
                         }
                         
                     }];
}


#pragma mark - other
//  Создание окна нового сообщения
- (void) newWallMessageWithGroup:(VKGroup *)group onSuccess:(void(^)(id responseObject, VKPostType postType))success onFailure:(void(^)(NSError * error))failure {
    
    //  Создание вью нового сообщения и устанавливаем группу в свойства
    VKNewPostViewController * newPost = [[VKNewPostViewController alloc] init];
    newPost.group = group;
    
    //  Вызываем метод отправки сообщения
    [newPost sendPost:^(id response, VKPostType postType) {
        
        //  Если пришедший ответ ошибка то передаем эту ошибку если есть реализация блока
        if ([response isKindOfClass:[NSError class]]) {
            if (failure) {
                failure(response);
            }
            
        //  Иначе если есть реализация блока успешного выполнения то передаем ответ и тип сообщения (опубликованный, отложенный)
        } else {
            if (success) {
                success(response, postType);
            }
        }  
    }];
    
    //  Создаем навигейшн контроллер с рутом -
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:newPost];
    
    //  Берем текущий контроллер что бы вызвать из него навигейшн контроллер
    UIViewController * current = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    //  Презентуем контролеер
    [current presentViewController:navc animated:YES completion:^{
    }];
}



@end
