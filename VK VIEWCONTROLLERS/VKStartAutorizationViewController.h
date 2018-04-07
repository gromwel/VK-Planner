//
//  VKStartAutorizationViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 06.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Этот класс реализует появление экрана с кнопкой авторизации
//  И получение токена


#import <UIKit/UIKit.h>


@class VKToken;
typedef void(^VKTakeTokenBlock)(VKToken * token);



@interface VKStartAutorizationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;


//  Нажатие на кнопку
- (IBAction)buttonLogin:(id)sender;

//  Метод инициализации класса и возвращения токета по исполнению
- (void) takeToken:(VKTakeTokenBlock)success;



@end
