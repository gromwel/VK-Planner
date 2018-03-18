//
//  VKHelpFunction.h
//  VK GPM
//
//  Created by Clyde Barrow on 11.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    
    VKToolbarButtonTypeAds,
    VKToolbarButtonTypeClip,
    VKToolbarButtonTypeContact,
    VKToolbarButtonTypeOther,
    VKToolbarButtonTypePhoto,
    VKToolbarButtonTypePlace,
    VKToolbarButtonTypePoll,
    VKToolbarButtonTypeShare,
    VKToolbarButtonTypeSettings,
    VKToolbarButtonTypeSigned,
    VKToolbarButtonTypeTimer
    
} VKToolbarButtonType;

@interface VKHelpFunction : NSObject

- (UIBarButtonItem *) makeImageBarButtonItemWithURL:(NSURL *)stringURL;
- (UIBarButtonItem *) makeImageBarButtonItemWithUserID:(NSString *)userID;
- (UIImage *) imageWithButtonType:(VKToolbarButtonType)type;

@end
