//
//  ViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 01.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "ViewController.h"
#import "VKRequestManager.h"
#import "VKToken+CoreDataClass.h"
#import "CoreDataManager.h"
#import "VKStartAutorizationViewController.h"
#import <UIImageView+AFNetworking.h>
#import <UIImage+AFNetworking.h>
#import "VKUser.h"


@interface ViewController ()

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, assign) CGRect startRect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 409, 375, 258)];
//    view.backgroundColor = [UIColor redColor];
//    [self.view addSubview:view];
//    
//    
//    
//    UIView * view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 409)];
//    view2.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:view2];
    
    UIToolbar * toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:nil];
    [toolbar setItems:@[item] animated:NO];

    self.label.inputAccessoryView = toolbar;
    self.textView.inputAccessoryView = toolbar;
    
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 300)];
    view.backgroundColor = [UIColor redColor];
    self.label.inputView = view;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    
}





- (IBAction)showTV:(id)sender {
    self.startRect = self.purpleView.frame;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.purpleView.frame = self.yellowView.frame;
    }];
}

- (IBAction)dismissTV:(id)sender {
    [UIView animateWithDuration:0.4f animations:^{
        self.purpleView.frame = self.startRect;
    }];
}
@end
