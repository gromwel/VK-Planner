//
//  UIView+UITableViewCell.h
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Расширение класса UITableViewCell

#import <UIKit/UIKit.h>

@interface UIView (UITableViewCell)


//  Определение ячейки на которой расположен переключатель
- (UITableViewCell *) superCell;

@end
