//
//  VKToolbarSettingsTableViewCell.m
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKToolbarSettingsTableViewCell.h"
#import "UIColor+VKUIColor.h"

@implementation VKToolbarSettingsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.switchOutlet.onTintColor = [UIColor additionalVKColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
