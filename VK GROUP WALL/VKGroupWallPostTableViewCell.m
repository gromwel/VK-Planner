//
//  VKGroupWallPostTableViewCell.m
//  VK GPM
//
//  Created by Clyde Barrow on 17.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKGroupWallPostTableViewCell.h"

@implementation VKGroupWallPostTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imageGroup.layer.masksToBounds = YES;
    self.imageGroup.layer.cornerRadius = CGRectGetHeight(self.imageGroup.frame)/2;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
