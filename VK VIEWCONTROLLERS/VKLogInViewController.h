//
//  VKLogInViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 02.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKToken+CoreDataClass.h"

@class VKAccessToken;
typedef void(^VKLogiCompletionBlock)(VKToken * token);

@interface VKLogInViewController : UIViewController

- (instancetype)initWithCompletionBlock:(VKLogiCompletionBlock)completionBlock;

@end
