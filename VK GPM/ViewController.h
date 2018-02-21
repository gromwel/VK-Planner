//
//  ViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 01.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *label;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIView *purpleView;
@property (weak, nonatomic) IBOutlet UIView *yellowView;
- (IBAction)showTV:(id)sender;
- (IBAction)dismissTV:(id)sender;

@end

