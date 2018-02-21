//
//  VKHelpFunction.m
//  VK GPM
//
//  Created by Clyde Barrow on 11.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKHelpFunction.h"
#import <UIImage+AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "VKToken+CoreDataClass.h"
#import "VKToken+CoreDataProperties.h"
#import "CoreDataManager.h"
#import "VKRequestManager.h"
#import "VKUser.h"



@implementation VKHelpFunction


- (UIBarButtonItem *) makeImageBarButtonItemWithURL:(NSURL *)stringURL {
    
    
    UINavigationController * navigation = [[UINavigationController alloc] init];
    CGFloat lenght = navigation.navigationBar.frame.size.height/3 * 2;
    
    UIImageView * customView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, lenght, lenght)];
    customView.backgroundColor = [UIColor redColor];
    customView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    __weak UIImageView * weakView = customView;
    [customView setImageWithURLRequest:[NSURLRequest requestWithURL:stringURL]
                      placeholderImage:nil
                               success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                   NSLog(@"log");
                                   UIImage * after = [UIImage imageWithCGImage:image.CGImage
                                                                        scale:CGImageGetHeight(image.CGImage)/lenght
                                                                  orientation:UIImageOrientationUp];
                                   
                                   weakView.image = after;
                                   
                               } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                   NSLog(@"ERROR - %@", error.description);
                               }];
    
    customView.layer.cornerRadius = lenght/2;
    customView.layer.masksToBounds = YES;
    customView.layer.borderColor = [[UIColor grayColor] CGColor];
    //customView.layer.borderWidth = 2.f;
        
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    return barButton;
    
}


- (UIBarButtonItem *) makeImageBarButtonItemWithUserID:(NSString *)userID {
    
    
    
    VKToken * token = [[CoreDataManager sharedManager] token];
    __block NSURL * stringURL = [[NSURL alloc] init];;
    
    
    __block UIBarButtonItem * barButton = [[UIBarButtonItem alloc] init];
    
    [[VKRequestManager sharedManager] getUserWithUserID:token.userID
                                              onSuccess:^(VKUser *user) {
                                                  
                                                stringURL = user.photo;
                                                barButton = [self makeImageBarButtonItemWithURL:stringURL];
                                                  
                                              } onFailure:^(NSError *error) {
                                                  
                                              }];
    
    
    return barButton;
}




- (UIImage *) imageWithButtonType:(VKToolbarButtonType)type {
    
    NSString * imageName = [self nameWithType:type];
    
    UIImage * image = [UIImage imageNamed:imageName];
    CGSize size = CGSizeMake(20, 20);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage * returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}


- (NSString *) nameWithType:(VKToolbarButtonType)type {
    NSString * imageName = nil;
    
    if (type == VKToolbarButtonTypeAds) {
        imageName = @"Ads";
    } else if (type == VKToolbarButtonTypeClip) {
        imageName = @"Clip";
    } else if (type == VKToolbarButtonTypeContact) {
        imageName = @"Contact";
    } else if (type == VKToolbarButtonTypeOther) {
        imageName = @"Other";
    } else if (type == VKToolbarButtonTypePhoto) {
        imageName = @"Photo";
    } else if (type == VKToolbarButtonTypePlace) {
        imageName = @"Place";
    } else if (type == VKToolbarButtonTypePoll) {
        imageName = @"Poll";
    } else if (type == VKToolbarButtonTypeShare) {
        imageName = @"Share";
    } else if (type == VKToolbarButtonTypeSettings) {
        imageName = @"Settings";
    } else if (type == VKToolbarButtonTypeSigned) {
        imageName = @"Signed";
    } else if (type == VKToolbarButtonTypeTimer) {
        imageName = @"Timer";
    }
    
    return imageName;
}

@end
