//
//  UIView+UITableViewCell.m
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "UIView+UITableViewCell.h"

@implementation UIView (UITableViewCell)

- (UITableViewCell *) superCell {
    
    if (!self.superview) {
        return nil;
    }
    
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell *)self.superview;
    }
    
    return [self.superview superCell];
}

@end
