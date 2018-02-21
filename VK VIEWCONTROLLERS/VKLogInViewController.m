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


@interface VKLogInViewController () <UIWebViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) VKLogiCompletionBlock completionBlock;
@property (nonatomic, strong) UIWebView * webView;

@end



@implementation VKLogInViewController
//инициализация с блоком который вернет токен методу откуда инициализируется
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
    
    //1. Создать веб вью и подключить делегат
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    UIWebView * webView = [[UIWebView alloc] initWithFrame:rect];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    self.webView = webView;
    
    //ссылка авторизации
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
    
    
    //2. добавить на навигейшн и запустить
    [self.view addSubview:webView];
    
    
    //3. добавить кнопку закрытия
    //UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Закрыть" style:UIBarButtonItemStyleBordered target:self action:@selector(closeWebViewReturnNil)];
    
    //self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.title = @"Авторизация";
    
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //self.navigationItem.hidesBackButton = YES;
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self closeWebViewReturnNil];
    
}


- (void)dealloc {
    //отписка делегата
    self.webView.delegate = nil;
}


- (void) closeWebViewReturnNil {
    
    
    //если блок обьявлен то ничего туда не передаем, так как токен еще не пришел
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    
    self.webView.delegate = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void) dismissWebView {
    //отписывание делегата
    self.webView.delegate = nil;
    //закрытие веб вью
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"REQUEST - %@", request);
    
    NSString * fragment = request.URL.fragment;
    
    //если пришел эррор и это не отмена юзером автоизации
    if ([NSString stringWithFormat:@"%@", request.URL] && !([[NSString stringWithFormat:@"%@", request.URL] rangeOfString:@"error"].location == NSNotFound)  && ([[NSString stringWithFormat:@"%@", request.URL] rangeOfString:@"error_description=User%20denied%20your%20request"].location == NSNotFound)) {
        
        NSString * message = @"";
        
        //распарсим ошибку что бы показать пользователю
        NSArray * firstArray = [fragment componentsSeparatedByString:@"&"];
        if (firstArray.count > 0) {
            for (NSString * string in firstArray) {
                NSArray * secondArray = [string componentsSeparatedByString:@"="];
                if ((secondArray.count == 2) && [secondArray.firstObject isEqualToString:@"error_description"]) {
                    message = secondArray.lastObject;
                }
            }
        }
        
        if (self.completionBlock) {
            self.completionBlock(nil);
        }
        
        [self alertSheetWithTitle:@"Ошибка авторизации" message:message];
        return NO;
    }
    
    
    //если доступ запрещен юзером то передаем в блок нил
    if (fragment && !([fragment rangeOfString:@"error_description=User%20denied%20your%20request"].location == NSNotFound)) {
        [self closeWebViewReturnNil];
        return NO;
    }
    
    
    //если доступ дали
    if (fragment && !([fragment rangeOfString:@"access_token"].location == NSNotFound)) {
        
        //создаем токен
        NSDictionary * dict = [self parsingRequst:request.URL.fragment];
        VKToken * token = [[CoreDataManager sharedManager] newTokenWithDictionary:dict];
        
        //возвращаем токен
        if (self.completionBlock) {
            self.completionBlock(token);
        }
        
        
        //берем юзера
        [[VKRequestManager sharedManager] getUserWithUserID:token.userID
                                                  onSuccess:^(VKUser *user) {
                                                      
                                                      //показываем алерт с именем
                                                      NSString * userName = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                                                      [self alertSheetWithTitle:@"Вы авторизованы как" message:userName];
                                                      
                                                  } onFailure:^(NSError *error) {
                                                      
                                                      //показываем алерт с ошибкой
                                                      [self alertSheetWithTitle:@"Ошибка" message:error.description];
                                                      
                                                  }];
        return NO;
    }
    return YES;
}


//парсинг фрагмента юрл на дикшинари для токена
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


//алерт
- (void) alertSheetWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:controller
                       animated:YES
                     completion:^{
                         //когда алерт появится ставим таймер на 08
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             //закрываем алерт
                             [self dismissViewControllerAnimated:YES completion:^{
                                 //по закрытии алерта закрываем вебвью
                                 [self dismissWebView];
                             }];
                         });
                     }];
}


@end
