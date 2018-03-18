//
//  VKSharedGroupsTableViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 16.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKSharedGroupsTableViewController.h"
#import "VKRequestManager.h"

@interface VKSharedGroupsTableViewController ()

@property (nonatomic, strong) NSMutableArray * arrayAllUserGroups;
@property (nonatomic, strong) VKTakeSharedGroupsBlock completionBlock;

@end

@implementation VKSharedGroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAllGroups];
    
    //self.arraySharedGroups = [[NSMutableArray alloc] init];
    
    UIBarButtonItem * butoon = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(closeTable)];
    self.navigationItem.rightBarButtonItem = butoon;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (instancetype)initWithCompletionBlock:(VKTakeSharedGroupsBlock)completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}


- (void) closeTable {
    
    for (VKGroup * group in self.arraySharedGroups) {
        NSLog(@"SG %@", group.name);
    }
    
    
    if (self.completionBlock) {
        self.completionBlock(self.arraySharedGroups);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void) loadAllGroups {
    
    [[VKRequestManager sharedManager] getGroupsWithOffset:0
                                                    count:15
                                                 onSucces:^(NSArray *groups) {
                                                     
                                                     NSMutableArray * mGroups = [NSMutableArray arrayWithArray:groups];
                                                     NSArray * names = [groups valueForKeyPath:@"@unionOfObjects.groupID"];
                                                     
                                                     if ([names containsObject:self.currentGroup.groupID]) {
                                                         NSInteger index = [names indexOfObject:self.currentGroup.groupID];
                                                         [mGroups removeObjectAtIndex:index];
                                                     }
                                                     
                                                     self.arrayAllUserGroups = [NSMutableArray arrayWithArray:mGroups];
                                                     [self.tableView reloadData];
                                                     
                                                 } onFailure:^(NSError *error, NSInteger statusCode) {
    
                                                 }];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayAllUserGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    VKGroup * group = [self.arrayAllUserGroups objectAtIndex:indexPath.row];
    cell.textLabel.text = group.name;
    
    
    
    NSArray * array = [self.arraySharedGroups valueForKeyPath:@"@unionOfObjects.groupID"];
    
    if ([array containsObject:group.groupID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VKGroup * group = [self.arrayAllUserGroups objectAtIndex:indexPath.row];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    UITableViewCellAccessoryType type = UITableViewCellAccessoryNone;
    
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        
        NSArray * array = [self.arraySharedGroups valueForKeyPath:@"@unionOfObjects.name"];
        
        if ([array containsObject:group.name]) {
            NSInteger index = [array indexOfObject:group.name];
            
            VKGroup * gr = [self.arraySharedGroups objectAtIndex:index];
            NSLog(@"REM - %@", gr.name);
            [self.arraySharedGroups removeObjectAtIndex:index];
        }
        
        type = UITableViewCellAccessoryNone;
    } else {
        NSLog(@"ADD - %@", group.name);
        [self.arraySharedGroups addObject:group];
        type = UITableViewCellAccessoryCheckmark;
    }
    
//    if ([self.arraySharedGroups containsObject:group]) {
//        [self.arraySharedGroups removeObject:group];
//        type = UITableViewCellAccessoryNone;
//    } else {
//        [self.arraySharedGroups addObject:group];
//        type = UITableViewCellAccessoryCheckmark;
//    }
    
    cell.accessoryType = type;
}


//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellAccessoryCheckmark;
//}





@end
