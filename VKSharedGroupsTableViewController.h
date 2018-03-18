//
//  VKSharedGroupsTableViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 16.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKGroup.h"


typedef void(^VKTakeSharedGroupsBlock)(NSArray * groups);

@interface VKSharedGroupsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray * arraySharedGroups;
@property (nonatomic, strong) VKGroup * currentGroup;


- (instancetype)initWithCompletionBlock:(VKTakeSharedGroupsBlock)completionBlock;

@end
