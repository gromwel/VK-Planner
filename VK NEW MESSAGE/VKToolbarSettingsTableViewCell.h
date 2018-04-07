//
//  VKToolbarSettingsTableViewCell.h
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс ячейки таблицы которая появляется пдля настройки отображаемых кнопок тулбара нового сообщения

#import <UIKit/UIKit.h>

@interface VKToolbarSettingsTableViewCell : UITableViewCell

//  Переключатель показать/скрыть кнопку
@property (weak, nonatomic) IBOutlet UISwitch *switchOutlet;

@end
