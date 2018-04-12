//
//  VKHelpFunction.h
//  VK GPM
//
//  Created by Clyde Barrow on 11.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс в котором разные методы с общей функционалностью


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum {
    
    VKToolbarButtonTypeAds,                 //  Реклама
    VKToolbarButtonTypeClip,                //  Прикрепленные файлы
    VKToolbarButtonTypeContact,             //  Контакт
    VKToolbarButtonTypeOther,               //  Скрытые кнопки
    VKToolbarButtonTypePhoto,               //  Фото
    VKToolbarButtonTypePlace,               //  Геопозиция
    VKToolbarButtonTypePoll,                //  Опрос
    VKToolbarButtonTypeShare,               //  Поделиться
    VKToolbarButtonTypeSettings,            //  Настройки
    VKToolbarButtonTypeSigned,              //  Подпись
    VKToolbarButtonTypeTimer                //  Отложенная запись
    
} VKToolbarButtonType;



@interface VKHelpFunction : NSObject

//  Кнопка из ссылки на картинку
- (UIBarButtonItem *) makeImageBarButtonItemWithURL:(NSURL *)stringURL;

//  Кнопка из ID юзера
- (UIBarButtonItem *) makeImageBarButtonItemWithUserID:(NSString *)userID;

//  Картинка из типа кнопки
- (UIImage *) imageWithButtonType:(VKToolbarButtonType)type;

@end
