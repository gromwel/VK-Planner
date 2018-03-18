//
//  VKRequestManager.m
//  VK GPM
//
//  Created by Clyde Barrow on 02.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

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
+ (VKRequestManager *) sharedManager {
    static VKRequestManager * manager = nil;
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VKRequestManager alloc] init];
    });
    
    return manager;
}


- (void) setAccessToken:(VKToken *)accessToken {
    //NSLog(@"ACCESS TOKEN SET");
    //NSLog(@"TOKEN - %@", accessToken);
    _accessToken = accessToken;
}


- (instancetype)init {
    
    self = [super init];
    if (self) {
        NSURL * baseURL = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        
        if ([[CoreDataManager sharedManager] token]) {
            self.accessToken = [[CoreDataManager sharedManager] token];
        }
    }
    return self;
}



#pragma mark - logInUser
- (void) autorisationUser {
    
    VKLogInViewController * vc = [[VKLogInViewController alloc] initWithCompletionBlock:^(VKToken *token) {
        self.accessToken = token;
    }];
    
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController * currentVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [currentVC presentViewController:navc animated:YES completion:^{}];
}


- (void) autorisationUserWithSplashScreen {
    
    if (![[CoreDataManager sharedManager] token]) {
        
        //1. Splash screen
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VKStartAutorizationViewController * splashScreenVK = [storyboard instantiateViewControllerWithIdentifier:@"VKStartAutorizationViewController"];
        
        [splashScreenVK takeToken:^(VKToken *token) {
            if (token) {
                self.accessToken = token;
            }
        }];
        
        
        //2. Nav Controller
        UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:splashScreenVK];
        //navigation.navigationBar.barStyle = UIBarStyleBlack;
        //navigation.navigationBar.barTintColor = [UIColor colorWithRed:99.f/255.f green:136.f/255.f blue:179.f/255.f alpha:1];
        
        //3. Current View
        UIViewController * current = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        
        
        //4. Present
        [current presentViewController:navigation animated:YES completion:^{}];
        
    } else {
        
        
        
    }
}


- (void) newWallMessageWithGroup:(VKGroup *)group onSuccess:(void(^)(id responseObject))success onFailure:(void(^)(NSError * error))failure {
    //1.создание вью нового сообщения с навигейшеном
    VKNewPostViewController * newPost = [[VKNewPostViewController alloc] init];
    newPost.group = group;
    
    [newPost sendPost:^(id response) {
        
        if ([response isKindOfClass:[NSError class]]) {
            if (failure) {
                failure(response);
            }
        } else {
            //NSLog(@"RESPONSE - %@", response);
            if (success) {
                success(response);
            }
        }
        
    }];
    
    //навигейшн
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:newPost];
    
    //2.берем текущий контроллер
    UIViewController * current = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    //3.презент
    [current presentViewController:navc animated:YES completion:^{
        //курсор
        //[newPost.textView becomeFirstResponder];
    }];
}


- (void) logoutUser {
    UIAlertController * alert = [[UIAlertController alloc] init];
    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Отмена"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                          }];
    UIAlertAction * actionLogout = [UIAlertAction actionWithTitle:@"Выйти"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [[CoreDataManager sharedManager] deleteAllToken];
                                                              [self autorisationUserWithSplashScreen];
                                                              
                                                              
                                                              //удаление настроек
                                                              [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"buttons"];;
                                                          }];
    [alert addAction:actionCancel];
    [alert addAction:actionLogout];
    
    UIViewController * vc = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    [vc presentViewController:alert animated:YES completion:^{
    }];
}


- (void) postWallMessageWithOwnerID:(NSString *)ownerID
                            message:(NSString *)message
                        publishDate:(NSInteger)publishDate
                                ads:(NSInteger)flagAds
                             signed:(NSInteger)flagSigned
                          onSuccess:(void(^)(id successesMessage))success
                          onFailure:(void(^)(NSError * error))failure {
    
    if (![ownerID hasPrefix:@"-"]) {
        ownerID = [@"-" stringByAppendingString:ownerID];
    }
    

    
    NSString * method = @"wall.post";
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 ownerID, @"owner_id",
                                 message, @"message",
                                 @(flagSigned), @"signed",
                                 @(flagAds), @"mark_as_ads",
                                 @"1", @"from_group",
                                 @"", @"publish_date",
                                 self.accessToken.token, @"access_token",
                                 VK_API_VERSION, @"version", nil];
    
    [self.sessionManager POST:method
                   parameters:parameters
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          if (success) {
                              success(responseObject);
                          }
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          if (failure) {
                              failure(error);
                          }
                      }];
}


- (void) getPostsOnWallGroupID:(NSString *)groupID offset:(NSInteger)offset count:(NSInteger)count onSuccess:(void(^)(NSArray * posts, NSInteger count))success onFailure:(void(^)(NSError * error, NSInteger statusCode))failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    
    NSString * method = @"wall.get";
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 groupID, @"owner_id",
                                 @(offset), @"offset",
                                 @(count), @"count",
                                 @"all", @"filter",
                                 @(0), @"extended",
                                 @"first_name", @"fields",
                                 self.accessToken.token, @"access_token",
                                 VK_API_VERSION, @"version", nil];
    
    [self.sessionManager GET:method
                  parameters:parameters
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSArray * arrayPosts = [responseObject objectForKey:@"response"];
                         NSInteger count = [[arrayPosts firstObject] integerValue];
                         
                         //NSMutableArray * array = [[NSMutableArray alloc] init];
                         
                         self.loadPosts = [[NSMutableArray alloc] init];
                         self.postsCount = arrayPosts.count;

                         if (arrayPosts.count > 1) {
                             for (int i = 1; i < arrayPosts.count; i ++) {
                                 NSDictionary * dict = [arrayPosts objectAtIndex:i];


                                 [[VKGroupPost alloc] postWithDictionary:dict completionBlock:^(VKGroupPost *post) {
                                     [self.loadPosts addObject:post];
                                     
                                     if (self.loadPosts.count == self.postsCount - 1) {
                                         
                                         
                                         [self.loadPosts sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                             
                                             VKGroupPost * post1 = (VKGroupPost *)obj1;
                                             VKGroupPost * post2 = (VKGroupPost *)obj2;
                                             
                                             if (post1.index < post2.index) {
                                                 return NSOrderedDescending;
                                             } else if (post1.index > post2.index) {
                                                 return NSOrderedAscending;
                                             }
                                             return NSOrderedSame;
                                         }];
                                         
                                         if (success) {
                                             success(self.loadPosts, count);
                                         }
                                     }
                                 }];
                         
                                 
                                 
//                                 VKGroupPost * post = [[VKGroupPost alloc] initWithResponseObject:dict];
//                                 [array addObject:post];
                             }
                         }
     
//                         if (success) {
//                             success(array, count);
//                         }
     
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                     }];
}


- (void) getGroupsWithOffset:(NSInteger)offset count:(NSInteger)count onSucces:(void(^)(NSArray * groups))succes onFailure:(void(^)(NSError * error, NSInteger statusCode))failure {
    
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
    
    [self.sessionManager GET:method
                  parameters:parameters
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
                        //1.взять аррей обьектов
                        NSArray * array = [responseObject objectForKey:@"response"];
                        
                        //если массив больше чем из одного объекта то группы есть
                        if (array.count > 1) {
                            
                            //2.создаем массив групп
                            NSMutableArray * groupsArray = [[NSMutableArray alloc] init];
                            
                            //начинаем цикл со второго объекта так как первый это не группа
                            for (int i = 1; i < array.count; i++) {
                                
                                NSDictionary * object = [array objectAtIndex:i];
                                VKGroup * group = [[VKGroup alloc] initWithResponseObject:object];
                                [groupsArray addObject:group];
                            }
                            
                            //3.по окончании цикла возвращаем массив групп
                            if (succes) {
                                succes(groupsArray);
                            }
                            
                        //иначе групп нет
                        } else {
                            if (succes) {
                                succes(nil);
                            }
                        }

                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"ERROR - %@", error.description);
                    }];
}



#pragma mark - GETRequest
- (void) getUserWithUserID:(NSString *)userID onSuccess:(void(^)(VKUser * user))success onFailure:(void(^)(NSError * error))failure {
    
    NSString * method = @"users.get";
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 userID, @"user_ids",
                                 @"first_name, photo_max_orig, online, domain, has_mobile, status, last_seen, nickname, screen_name", @"fields",
                                 VK_API_VERSION, @"version",
                                nil];
    
    //@"photo_max_orig, online, domain, has_mobile, status, last_seen, nickname, screen_name"
    [self.sessionManager GET:method
                  parameters:parameters
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         
                         //NSLog(@"БЕРЕМ ИМЯ\n%@", responseObject);
                         
                         
                         NSArray * userArray = [responseObject objectForKey:@"response"];
                         if (userArray.count > 0) {
                             NSDictionary * userDict = [userArray firstObject];
                             VKUser * user = [[VKUser alloc] initWithResponseObject:userDict];
                             
                             if (success) {
                                 success(user);
                             }
                         } else {
                             if (failure) {
                                 failure(nil);
                             }
                         }
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         if (failure) {
                             failure(error);
                         }
                     }];
}


@end
