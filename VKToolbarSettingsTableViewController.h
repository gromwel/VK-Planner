//
//  VKToolbarSettingsTableViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VKToolbarSettingsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray * arrayButtons;

- (IBAction)switchValueChanged:(id)sender;

@end
