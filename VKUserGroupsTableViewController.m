//
//  VKUserGroupsTableViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 09.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKUserGroupsTableViewController.h"
#import "CoreDataManager.h"
#import "VKRequestManager.h"
#import "VKUser.h"
#import "VKToken+CoreDataClass.h"
#import "VKGroup.h"
#import <UIImageView+AFNetworking.h>
#import <UIImage+AFNetworking.h>
#import "VKUserGroupsTableViewController.h"
#import "VKHelpFunction.h"
#import "VKGroupTableViewCell.h"
#import "VKGroupWallTableViewController.h"



@interface VKUserGroupsTableViewController ()

@property (nonatomic, strong) NSMutableArray * groupsArray;
@property (nonatomic, assign) BOOL firstStart;
@property (nonatomic, strong) VKUser * currentUser;


@end

@implementation VKUserGroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstStart = YES;
    self.groupsArray = [[NSMutableArray alloc] init];
    self.currentUser = [[VKUser alloc] init];
    
    
    
    
    
    //
    
    //1. добавление кнопки выйти
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Выйти"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logout)] ;
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.navigationItem.title = @"Управление";
    
    
    
    //2.рефреш контроллер
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getGroupsRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Обновление..."];
    //[self.refreshControl beginRefreshing];

    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
    if (self.firstStart) {
        [[VKRequestManager sharedManager] autorisationUserWithSplashScreen];
        VKToken * token = [[CoreDataManager sharedManager] token];
        if (token) {
            
                [self getGroups];
                self.firstStart = NO;
        }
        
        
    }
    
    //2.добавление аватарки
    VKToken * token = [[CoreDataManager sharedManager] token];
    [[VKRequestManager sharedManager] getUserWithUserID:token.userID
                                              onSuccess:^(VKUser *user) {
                                                  
                                                  [self createAvatarBarButtonItemWithURL:user.photo];
                                                  
                                              } onFailure:^(NSError *error) {
                                                  
                                              }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}



- (void) createAvatarBarButtonItemWithURL:(NSURL *)url {
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    UINavigationController * navigation = [[UINavigationController alloc] init];
    CGFloat lenght = navigation.navigationBar.frame.size.height/3 * 2;
    CGFloat heightBar = navigation.navigationBar.frame.size.height;
    
    
    UIButton * customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, heightBar, heightBar);
    customButton.contentMode = UIViewContentModeScaleToFill;
    customButton.imageView.layer.cornerRadius = lenght/2;
    customButton.imageView.layer.masksToBounds = YES;
    

    
    [customButton addTarget:self action:@selector(rightButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    __weak UIButton * weakButton = customButton;
    [customButton.imageView setImageWithURLRequest:request
                                  placeholderImage:nil
                                           success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                               
                                               UIImage * after = [UIImage imageWithCGImage:image.CGImage
                                                                                     scale:CGImageGetHeight(image.CGImage)/lenght
                                                                               orientation:UIImageOrientationUp];
                                               
                                               [weakButton setImage:after forState:UIControlStateNormal];
                                               
                                           } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                               NSLog(@"ERROR - %@", error.description);
                                           }];
    
    UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithCustomView:weakButton];
    self.navigationItem.rightBarButtonItem = button;
}



- (void) rightButton {
    NSLog(@"AVATAR");
    [[VKRequestManager sharedManager] logoutUser];
}



- (void) logout {
    [[VKRequestManager sharedManager] logoutUser];
}






- (void) getGroupsRefresh {
    
    [self.groupsArray removeAllObjects];
    
    [[VKRequestManager sharedManager] getGroupsWithOffset:self.groupsArray.count
                                                    count:15
                                                 onSucces:^(NSArray *groups) {
                                                     
                                                     
                                                     [self.tableView reloadData];
                                                     
                                                     //1.добавить группы в массив
                                                     [self.groupsArray addObjectsFromArray:groups];
                                                     
                                                     //2.создать массив path для добавления в таблицу
                                                     NSMutableArray * mArray = [[NSMutableArray alloc] init];
                                                     
                                                     for (int i = (int)(self.groupsArray.count - groups.count); i < self.groupsArray.count; i++) {
                                                         NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:0];
                                                         [mArray addObject:path];
                                                     }
                                                     
                                                     [self.refreshControl endRefreshing];
                                                     
                                                     //3.добавить ячейки в баблицу
                                                     [self.tableView beginUpdates];
                                                     [self.tableView insertRowsAtIndexPaths:mArray withRowAnimation:UITableViewRowAnimationFade];
                                                     [self.tableView endUpdates];
                                                     
                                                     
                                                 }
                                                onFailure:^(NSError *error, NSInteger statusCode) {
                                                    
                                                    
                                                    
                                                    
                                                }];
}

- (void) getGroups {
    
    [[VKRequestManager sharedManager] getGroupsWithOffset:self.groupsArray.count
                                                    count:15
                                                 onSucces:^(NSArray *groups) {
                                                     
                                                     //1.добавить группы в массив
                                                     [self.groupsArray addObjectsFromArray:groups];

                                                     //2.создать массив path для добавления в таблицу
                                                     NSMutableArray * mArray = [[NSMutableArray alloc] init];
                                                     
                                                     for (int i = (int)(self.groupsArray.count - groups.count); i < self.groupsArray.count; i++) {
                                                         NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:0];
                                                         [mArray addObject:path];
                                                     }

                                                     //3.добавить ячейки в баблицу
                                                     [self.tableView beginUpdates];
                                                     [self.tableView insertRowsAtIndexPaths:mArray withRowAnimation:UITableViewRowAnimationFade];
                                                     [self.tableView endUpdates];
                                                     
                                                     [self.refreshControl endRefreshing];
                                                     
                                                 }
                                                onFailure:^(NSError *error, NSInteger statusCode) {
                                                    
                                                    
                                                    
                                                    
                                                }];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"GroupCell";
    VKGroupTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    
    /*
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
     */
    
    VKGroup * group = [self.groupsArray objectAtIndex:indexPath.row];
    cell.labelTitle.text = group.name;
    cell.labelSubtitle.text = group.type;
    [cell.imageGroupAvatar setImageWithURL:group.photoURL];
    cell.imageGroupAvatar.layer.masksToBounds = YES;
    cell.imageGroupAvatar.layer.cornerRadius = cell.imageGroupAvatar.frame.size.height/2;
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VKGroupWallTableViewController * vc = [[VKGroupWallTableViewController alloc] init];
    VKGroup * group = [self.groupsArray objectAtIndex:indexPath.row];
    vc.group = group;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
