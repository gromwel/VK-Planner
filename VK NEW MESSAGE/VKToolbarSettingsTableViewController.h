//
//  VKToolbarSettingsTableViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс таблицы которая появляется для настройки отображаемых кнопок тулбара нового сообщения


#import <UIKit/UIKit.h>

@interface VKToolbarSettingsTableViewController : UITableViewController

//  Массив кнопок и свойств
@property (nonatomic, strong) NSMutableArray * arrayButtons;

//  Реализация переключения тумблера
- (IBAction)switchValueChanged:(id)sender;

@end
