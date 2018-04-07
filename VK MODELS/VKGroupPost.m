//
//  VKGroupPost.m
//  VK GPM
//
//  Created by Clyde Barrow on 12.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#define VK_API_VERSION              @"5.8"

#import "VKGroupPost.h"
#import "VKRequestManager.h"
#import "VKUser.h"
#import <AFHTTPSessionManager.h>

//  Энум имя/название
typedef enum {
    typeIDUser,         //  Юзер
    typeIDGroup         //  Группа
} typeID;



@interface VKGroupPost ()

@property (nonatomic, strong) VKPostLoad completionBlock;

//  Это свойство необходимо для того что бы метод получения информации сообщения не закрылся раньше чем пришли данные
@property (nonatomic, assign) NSInteger completeSum;

@end



@implementation VKGroupPost


- (instancetype)initWithResponseObject:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
    }
    return self;
}


//  Создание поста из коллекции
- (void) postWithDictionary:(NSDictionary *)dictionary completionBlock:(VKPostLoad)completionBlock {
    
    //  Создание поста
    VKGroupPost * post = [[VKGroupPost alloc] init];
    
    post.completeSum = 0;
    
    //  Текст и индекс сообщения
    post.text = [dictionary objectForKey:@"text"];
    post.index = [[dictionary objectForKey:@"id"] integerValue];
    
    //  Дата
    NSString * dateString = [dictionary objectForKey:@"date"];
    NSTimeInterval time = [dateString doubleValue];
    post.date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    
    //  Реклама
    post.ads = [[dictionary objectForKey:@"marked_as_ads"] boolValue];

    
    
    //  Создаем реквест менеджера
    NSURL * baseURL = [[NSURL alloc] initWithString:@"https://api.vk.com/method/"];
    AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    
    //  Подпись
    //  Если сообщение содержит подпись
    if ([dictionary objectForKey:@"signer_id"]) {
        
        //  Определение метода, ключа и ID для запроса
        NSString * methodSigner = @"users.get";
        NSString * keyIDSigner = @"user_ids";
        NSString * stringIDSigner = [dictionary objectForKey:@"signer_id"];
        
        
        //  Собираем параметры в коллекцию
        NSDictionary * parametersSigner = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      stringIDSigner, keyIDSigner,
                                      VK_API_VERSION, @"version", nil];
        
        
        //  Запрос информации о юзере
        [manager GET:methodSigner
          parameters:parametersSigner
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 
                 // Получаем из ответа коллекцию
                 NSDictionary * dict = [[responseObject objectForKey:@"response"] firstObject];
                 
                 // Берем имя из коллекции
                 NSString * firstName = [dict objectForKey:@"first_name"];
                 NSString * lastName = [dict objectForKey:@"last_name"];
                 
                 // Устанавливаем имя в свойство
                 post.signerName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                 
                 
                 // Если есть реализация блока и получены все параметры то передаем полученное сообщение
                 // Или устанавливаем флаг получения этого значения
                 if (completionBlock) {
                     if (post.completeSum == 1) {
                         completionBlock(post);
                     } else {
                         post.completeSum = 1;
                     }
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"ERROR - %@", error.description);
             }];
        
        
    //  Если подписи нет устанавливаем флаг получения данных
    } else {
        post.completeSum = 1;
    }
    
    
    
    
    //  Отправитель
    NSNumber * number = [dictionary objectForKey:@"from_id"];
    NSInteger num = [number integerValue];
    NSString * str = [NSString stringWithFormat:@"%li", num];
    
    //  Определяем переменные по умолчанию для юзера
    NSString * method = @"users.get";
    NSString * keyID = @"user_ids";
    NSString * stringID = str;
    typeID type = typeIDUser;
    
    //  Если строка содержит - в начале ID тогда это группа и переопределяем переменные
    if ([str hasPrefix:@"-"]) {
        method = @"groups.getById";
        keyID = @"group_id";
        stringID = [str substringFromIndex:1];
        type = typeIDGroup;
    }
    
    //  Собираем параметры в коллекцию
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 stringID, keyID,
                                 @"photo_100", @"fields",
                                 VK_API_VERSION, @"version", nil];
    
    
    //  Запрос информации
    [manager GET:method
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             // Получаем коллекцию из ответа
             NSDictionary * dict = [[responseObject objectForKey:@"response"] firstObject];
             
             // Если получаем информацию о юзере
             if (type == typeIDUser) {
                 
                 // Берем первое и второе имя и устанавливаем его в свойства поста
                 NSString * firstName = [dict objectForKey:@"first_name"];
                 NSString * lastName = [dict objectForKey:@"last_name"];
                 post.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                 
                 
             // Если получаем информацию о группе
             } else if (type == typeIDGroup) {
                 // Устанавливаем название группы
                 post.name = [dict objectForKey:@"name"];
             }
             
             
             // Фото
             // Устанавливаем ЮРЛ из коллекции
             NSString * stringURL = [dict objectForKey:@"photo_100"];
             post.url = [NSURL URLWithString:stringURL];
             
             
             // Если есть реализация блока и получены все параметры то передаем полученное сообщение
             // Или устанавливаем флаг получения этого значения
             if (completionBlock) {
                 if (post.completeSum == 1) {
                     completionBlock(post);
                 } else {
                     post.completeSum = 1;
                 }
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"ERROR - %@", error.description);
         }];
}


@end
