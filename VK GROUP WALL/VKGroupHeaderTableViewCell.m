//
//  VKGroupHeaderTableViewCell.m
//  VK GPM
//
//  Created by Clyde Barrow on 17.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKGroupHeaderTableViewCell.h"
#import "UIColor+VKUIColor.h"

@implementation VKGroupHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    self.imageGroup.layer.masksToBounds = YES;
    self.imageGroup.layer.cornerRadius = CGRectGetHeight(self.imageGroup.frame)/2;
    
   // self.backgroundColor = [UIColor additionalVKColor];
    
    self.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
