//
//  VKNewPostViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 13.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKGroup.h"




typedef void(^VKSendMessageBlock)(id response);

@interface VKNewPostViewController : UIViewController

@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) VKGroup * group;

- (void) sendPost:(VKSendMessageBlock)success;

@end
