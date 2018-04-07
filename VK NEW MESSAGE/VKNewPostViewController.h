//
//  VKNewPostViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 13.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс вызова окна нового сообщения

#import <UIKit/UIKit.h>
#import "VKGroup.h"

//  Энум типа отправляемого сообщения
typedef enum {
    VKPostTypePublished,        //сейчас публикуется
    VKPostTypePostponed         //отложенная публикация
} VKPostType;

//  Присвоение типа блоку
typedef void(^VKSendMessageBlock)(id response, VKPostType postType);



@interface VKNewPostViewController : UIViewController

//
@property (nonatomic, strong) UITextView * textView;
//  Группа из стены которой создан объект нового сообщения
@property (nonatomic, strong) VKGroup * group;
//  Интервал в секуднах через какое время отправить сообщение
@property (nonatomic, assign) NSTimeInterval postponedInterval;


//  Инициализация объекта и установка реализации блока
- (void) sendPost:(VKSendMessageBlock)success;

@end
