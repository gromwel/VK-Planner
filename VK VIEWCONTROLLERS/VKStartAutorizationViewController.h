//
//  VKStartAutorizationViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 06.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VKToken;
typedef void(^VKTakeTokenBlock)(VKToken * token);

@interface VKStartAutorizationViewController : UIViewController


- (IBAction)buttonLogin:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;


- (void) takeToken:(VKTakeTokenBlock)success;

@end
