//
//  VKGroupWallPostTableViewCell.h
//  VK GPM
//
//  Created by Clyde Barrow on 17.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VKGroupWallPostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageGroup;
@property (weak, nonatomic) IBOutlet UILabel *labelNameGroup;
@property (weak, nonatomic) IBOutlet UILabel *labelDateMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelTextMessage;

@end
