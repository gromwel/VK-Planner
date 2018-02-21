//
//  VKStartAutorizationViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 06.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKStartAutorizationViewController.h"
#import "CoreDataManager.h"
#import "VKRequestManager.h"
#import "VKLogInViewController.h"
#import "VKAccessToken.h"

@interface VKStartAutorizationViewController ()

@property (nonatomic, strong) VKTakeTokenBlock completionBlock;

@end

@implementation VKStartAutorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.buttonLogin.layer.cornerRadius = self.buttonLogin.frame.size.height/5;

    self.navigationController.navigationBarHidden = YES;
}


- (void) takeToken:(VKTakeTokenBlock)success {
    self.completionBlock = success;
}





- (IBAction)buttonLogin:(id)sender {
    
    VKLogInViewController * vk = [[VKLogInViewController alloc] initWithCompletionBlock:^(VKToken *token) {
        if (token) {
            if (self.completionBlock) {
                self.completionBlock(token);
            }
        }
    }];
    
    [self.navigationController pushViewController:vk animated:YES];
}
@end
