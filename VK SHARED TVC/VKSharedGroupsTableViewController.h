//
//  VKSharedGroupsTableViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 16.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс таблицы групп в которые еще можно отправить сообщение

#import <UIKit/UIKit.h>
#import "VKGroup.h"

//  Определение блока
typedef void(^VKTakeSharedGroupsBlock)(NSArray * groups);



@interface VKSharedGroupsTableViewController : UITableViewController

//  Массив групп в которые шарим
@property (nonatomic, strong) NSMutableArray * arraySharedGroups;

//  Группа из которой вызывается метод
@property (nonatomic, strong) VKGroup * currentGroup;


//  Инициализация блока выполнения
- (instancetype)initWithCompletionBlock:(VKTakeSharedGroupsBlock)completionBlock;

@end
