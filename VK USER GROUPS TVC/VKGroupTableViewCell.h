//
//  VKGroupTableViewCell.h
//  VK GPM
//
//  Created by Clyde Barrow on 11.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VKGroupTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageGroupAvatar;


@end
