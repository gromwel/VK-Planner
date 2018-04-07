//
//  VKHelpFunction.m
//  VK GPM
//
//  Created by Clyde Barrow on 11.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKHelpFunction.h"
#import <UIImage+AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "VKToken+CoreDataClass.h"
#import "VKToken+CoreDataProperties.h"
#import "CoreDataManager.h"
#import "VKRequestManager.h"
#import "VKUser.h"



@implementation VKHelpFunction

//  Метод возвращающий кнопку сделанную из ссылки на картинку
- (UIBarButtonItem *) makeImageBarButtonItemWithURL:(NSURL *)stringURL {
    
    //  Создаем навигейшн контроллер
    UINavigationController * navigation = [[UINavigationController alloc] init];
    
    //  Размер грани будущей кнопки
    CGFloat lenght = navigation.navigationBar.frame.size.height/3 * 2;
    
    //  Создаем имейдж вью с заданным ребром
    UIImageView * customView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, lenght, lenght)];
    customView.backgroundColor = [UIColor redColor];
    customView.contentMode = UIViewContentModeScaleAspectFit;
    
    //  Сделаем вик ссылку на имейдж вью, что бы
    __weak UIImageView * weakView = customView;
    [customView setImageWithURLRequest:[NSURLRequest requestWithURL:stringURL]
                      placeholderImage:nil
                               success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                   
                                   //   Изображение после изменения размера
                                   UIImage * after = [UIImage imageWithCGImage:image.CGImage
                                                                        scale:CGImageGetHeight(image.CGImage)/lenght
                                                                  orientation:UIImageOrientationUp];
                                   //   Устанавливаем новое изображение
                                   weakView.image = after;
                                   
                               } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                   NSLog(@"ERROR - %@", error.description);
                               }];
    
    
    //  Настройка изображения
    customView.layer.cornerRadius = lenght/2;
    customView.layer.masksToBounds = YES;
    customView.layer.borderColor = [[UIColor grayColor] CGColor];
    //customView.layer.borderWidth = 2.f;
    
    // Создание кнопки на основе изображения
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    return barButton;
}



//  Кнопка на основе ID юзера
- (UIBarButtonItem *) makeImageBarButtonItemWithUserID:(NSString *)userID {
    
    //  Берем токен из памяти
    VKToken * token = [[CoreDataManager sharedManager] token];
    
    //  Создаем объекты для работы в блоке
    __block NSURL * stringURL = [[NSURL alloc] init];;
    __block UIBarButtonItem * barButton = [[UIBarButtonItem alloc] init];
    
    //  Запрашиваем информации о юзере
    [[VKRequestManager sharedManager] getUserWithUserID:token.userID
                                              onSuccess:^(VKUser *user) {
                                                  
                                                //  Создаем кнопку на основе ссылки на изображение
                                                stringURL = user.photo;
                                                barButton = [self makeImageBarButtonItemWithURL:stringURL];
                                                  
                                              } onFailure:^(NSError *error) {
                                                  NSLog(@"ERROR - %@", error.description);
                                              }];
    
    
    return barButton;
}




//  Изображение на основе типа кнопки
- (UIImage *) imageWithButtonType:(VKToolbarButtonType)type {
    
    //  Берем имя картинки на основе тика
    NSString * imageName = [self nameWithType:type];
    
    //  Создаем объект картинки по имени и определяем размер ее
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize size = CGSizeMake(20, 20);
    
    
    //  Установка картинки
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage * returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    return returnImage;
}


//  Имя картинки на основе типа картинки
- (NSString *) nameWithType:(VKToolbarButtonType)type {
    NSString * imageName = nil;
    
    if (type == VKToolbarButtonTypeAds) {
        imageName = @"Ads";
    } else if (type == VKToolbarButtonTypeClip) {
        imageName = @"Clip";
    } else if (type == VKToolbarButtonTypeContact) {
        imageName = @"Contact";
    } else if (type == VKToolbarButtonTypeOther) {
        imageName = @"Other";
    } else if (type == VKToolbarButtonTypePhoto) {
        imageName = @"Photo";
    } else if (type == VKToolbarButtonTypePlace) {
        imageName = @"Place";
    } else if (type == VKToolbarButtonTypePoll) {
        imageName = @"Poll";
    } else if (type == VKToolbarButtonTypeShare) {
        imageName = @"Share";
    } else if (type == VKToolbarButtonTypeSettings) {
        imageName = @"Settings";
    } else if (type == VKToolbarButtonTypeSigned) {
        imageName = @"Signed";
    } else if (type == VKToolbarButtonTypeTimer) {
        imageName = @"Timer";
    }
    
    return imageName;
}

@end
