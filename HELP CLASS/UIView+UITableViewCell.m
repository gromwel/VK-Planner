//
//  UIView+UITableViewCell.m
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "UIView+UITableViewCell.h"
#import "UIColor+VKUIColor.h"

@implementation UIView (UITableViewCell)


//  Метод определяющий ячейку на которой расположен переключатель
- (UITableViewCell *) superCell {
    
    //  Если супервью
    if (!self.superview) {
        return nil;
    }
    
    //  Если супервью это селл то возвращаем этот селл
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell *)self.superview;
    }
    
    //  Если это не супер вью то еще раз проделываем эту операцию
    return [self.superview superCell];
}

@end
