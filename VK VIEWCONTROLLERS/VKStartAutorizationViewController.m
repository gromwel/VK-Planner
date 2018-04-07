//
//  VKStartAutorizationViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 06.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKStartAutorizationViewController.h"
#import "CoreDataManager.h"
#import "VKRequestManager.h"
#import "VKLogInViewController.h"
#import "VKAccessToken.h"

@interface VKStartAutorizationViewController ()

//  Блок реализации
@property (nonatomic, strong) VKTakeTokenBlock completionBlock;

@end

@implementation VKStartAutorizationViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Сглаживание углов кнопки
    self.buttonLogin.layer.cornerRadius = self.buttonLogin.frame.size.height/5;
    
    //  Скрываем навигейшн бар
    self.navigationController.navigationBarHidden = YES;
}



//  Метод установки блока реализации
- (void) takeToken:(VKTakeTokenBlock)success {
    self.completionBlock = success;
}


//  Реализация нажатия на кнопку
- (IBAction)buttonLogin:(id)sender {
    
    //  Инициализация объекта класса который прогружает в веб вью страницу авторизации
    VKLogInViewController * vk = [[VKLogInViewController alloc] initWithCompletionBlock:^(VKToken *token) {
        
        //  Если авторизация успешна и есть реализация блока мы получили токен то возвращаем этот токен
        if (token) {
            if (self.completionBlock) {
                self.completionBlock(token);
            }
        }
        
        //  Если токен не пришел
    }];
    
    [self.navigationController pushViewController:vk animated:YES];
}


@end
