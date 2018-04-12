//
//  VKLogInViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 02.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKLogInViewController.h"
#import "VKRequestManager.h"
#import "VKUser.h"
#import "VKToken+CoreDataClass.h"
#import "CoreDataManager.h"
#import "UIColor+VKUIColor.h"


@interface VKLogInViewController () <UIWebViewDelegate, UINavigationControllerDelegate>

//  Блок исполнения
@property (nonatomic, strong) VKLogiCompletionBlock completionBlock;
@property (nonatomic, strong) UIWebView * webView;

@end


@implementation VKLogInViewController

#pragma mark - Initialisation
//  Инициализация с блоком который вернет токен методу откуда инициализируется
- (instancetype)initWithCompletionBlock:(VKLogiCompletionBlock)completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Создание веб вью и подключить делегат
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    UIWebView * webView = [[UIWebView alloc] initWithFrame:rect];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    self.webView = webView;
    
    //  Ссылка авторизации
    NSString * stringURL = @"https://oauth.vk.com/authorize?"
                            "client_id=6356189&"
                            "display=mobile&"
                            "redirect_uri=https://oauth.vk.com/blank.html&"
                            "scope=140491935&"  //274462 //140491935 //136297631
                            "response_type=token&"
                            "v=5.71&"
                            "revoke=1&"
                            "state=THISISSPARTA";
    
    NSURL * url = [NSURL URLWithString:stringURL];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    
    //  Добавить на навигейшн и запустить
    [self.view addSubview:webView];
    
    //  Тайтл вью
    self.navigationItem.title = @"Авторизация";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}



- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //  Скрытие навигейшн бара перед закрытием вью
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //  Закрытие вью
    [self closeWebViewReturnNil];
}



- (void)dealloc {
    //  Отписка делегата
    self.webView.delegate = nil;
}


//  Закрытие вью и возвращение нила
- (void) closeWebViewReturnNil {
    
    //  Если блок обьявлен то ничего туда не передаем, так как токен еще не пришел
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    
    //  Отписка делегата
    self.webView.delegate = nil;
    //  Показ рут кантроллера
    [self.navigationController popToRootViewControllerAnimated:YES];
}


// Закрытие вью
- (void) dismissWebView {
    // Отписывание делегата
    self.webView.delegate = nil;
    // Закрытие веб вью
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIWebViewDelegate
//  Метод определяющий выполнять ли запрос и можно просмотреть этот запрос
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //  Берем часть запроса
    NSString * fragment = request.URL.fragment;
    
    
    //  Если пришел юрл
    //  И этот юрл содержит строчку error
    //  И это не отмена самим юзером автоизации
    if ([NSString stringWithFormat:@"%@", request.URL] &&
        !([[NSString stringWithFormat:@"%@", request.URL] rangeOfString:@"error"].location == NSNotFound) &&
        ([[NSString stringWithFormat:@"%@", request.URL] rangeOfString:@"error_description=User%20denied%20your%20request"].location == NSNotFound))
        {
        
        NSString * message = @"";
        
        //  Распарсим ошибку что бы показать пользователю
        NSArray * firstArray = [fragment componentsSeparatedByString:@"&"];
        if (firstArray.count > 0) {
            for (NSString * string in firstArray) {
                NSArray * secondArray = [string componentsSeparatedByString:@"="];
                if ((secondArray.count == 2) && [secondArray.firstObject isEqualToString:@"error_description"]) {
                    message = secondArray.lastObject;
                }
            }
        }
        
        //  Если есть блок реализации то вернем в него нил
        if (self.completionBlock) {
            self.completionBlock(nil);
        }
        
        //Покажем алерт с пришедшей ошибкой
        [self alertSheetWithTitle:@"Ошибка авторизации" message:message];
        return NO;
    }
    
    
    
    
    
    //  Если доступ запрещен юзером то передаем в блок нил
    if (fragment && !([fragment rangeOfString:@"error_description=User%20denied%20your%20request"].location == NSNotFound)) {
        [self closeWebViewReturnNil];
        return NO;
    }
    
    
    
    //  Если пришел токен
    if (fragment && !([fragment rangeOfString:@"access_token"].location == NSNotFound)) {
        
        //  Создаем объект класса токен из коллекции ключ-значение
        //  Парсим юрл что бы получить коллекцию
        NSDictionary * dict = [self parsingRequst:fragment];
        VKToken * token = [[CoreDataManager sharedManager] newTokenWithDictionary:dict];
        
        
        //  Возвращаем токен
        if (self.completionBlock) {
            self.completionBlock(token);
        }
        
        
        //  Отправляем запрос на юзера
        [[VKRequestManager sharedManager] getUserWithUserID:token.userID
                                                  onSuccess:^(VKUser *user) {
                                                      
                                                      //    Показываем алерт с именем
                                                      NSString * userName = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                                                      [self alertSheetWithTitle:@"Вы авторизованы как" message:userName];
                                                      
                                                  } onFailure:^(NSError *error) {
                                                      
                                                      //    Показываем алерт с ошибкой
                                                      [self alertSheetWithTitle:@"Ошибка" message:error.description];
                                                      
                                                  }];
        return NO;
    }
    
    
    return YES;
}


//  Парсинг фрагмента юрл на коллекию ключ-значение для токена
- (NSDictionary *) parsingRequst:(NSString *)fragment {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    NSArray * firstArray = [fragment componentsSeparatedByString:@"&"];
    
    if (firstArray.count > 0) {
        for (NSString * string in firstArray) {
            NSArray * secondArray = [string componentsSeparatedByString:@"="];
            if (secondArray.count == 2) {
                [dict setObject:secondArray.lastObject forKey:secondArray.firstObject];
            }
        }
    }
    
    return dict;
}


//  Показ алерта
- (void) alertSheetWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:controller
                       animated:YES
                     completion:^{
                         
                         // Когда алерт появится ставим таймер на 08
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             // Закрываем алерт
                             [self dismissViewControllerAnimated:YES completion:^{
                                 // По закрытии алерта закрываем вебвью
                                 [self dismissWebView];
                             }];
                         });
                         
                         
                     }];
}


@end
