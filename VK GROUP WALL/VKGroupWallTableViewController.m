//
//  VKGroupWallTableViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 11.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKGroupWallTableViewController.h"
#import "VKRequestManager.h"
#import "VKGroupPost.h"
#import "VKNewPostViewController.h"

#import <UIImageView+AFNetworking.h>
#import <UIImage+AFNetworking.h>

#import "VKGroupHeaderTableViewCell.h"
#import "VKGroupWallPostTableViewCell.h"

@interface VKGroupWallTableViewController ()

@property (nonatomic, strong) NSMutableArray * arrayPosts;
@property (nonatomic, assign) BOOL firstStart;

@property (nonatomic, assign) NSInteger count;

@end

@implementation VKGroupWallTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstStart = YES;
    self.arrayPosts = [[NSMutableArray alloc] init];
    
    
    //пустая кнопка назад сделана через сториборд
    
    self.navigationItem.title = self.group.name;
    
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(newPost)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    
    

    
    //добавление рефреша
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Обновление..."];
    //self.refreshControl.backgroundColor = [UIColor colorWithHue:0.1060 saturation:0.8142 brightness:0.8863 alpha:1.0];
    [self.refreshControl addTarget:self action:@selector(getPostsReload) forControlEvents:UIControlEventValueChanged];
    
    
    [self.refreshControl beginRefreshing];
    
    
    
    
    




    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.firstStart) {
        
        //
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self getMorePosts];
//            self.firstStart = NO;
//        });
        //
        
        [self getMorePosts];
        self.firstStart = NO;
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}


- (void) newPost {
    
    [[VKRequestManager sharedManager] newWallMessageWithGroup:self.group
                                                    onSuccess:^(id responseObject) {
                                                        NSLog(@"RESPONSE - %@", responseObject);
                                                        if (responseObject) {
                                                            [self getNewPost];
                                                        }

                                                    } onFailure:^(NSError *error) {

                                                    }];
    
    
//    VKNewPostViewController * vc = [[VKNewPostViewController alloc] init];
//    vc.group = self.group;
//    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:navc animated:YES completion:^{
//        //установка курсора в текствью
//        [vc.textView becomeFirstResponder];
//    }];
}






- (void) getMorePosts {
    [[VKRequestManager sharedManager] getPostsOnWallGroupID:self.group.groupID
                                                     offset:self.arrayPosts.count
                                                      count:20
                                                  onSuccess:^(NSArray *posts, NSInteger count) {
                                                      
                                                      self.count = count;
                                                      
                                                      //1. добавление в массив новыйх сообщений
                                                      [self.arrayPosts addObjectsFromArray:posts];
                                                      
                                                      //2. просчет всех path
                                                      NSMutableArray * arrayPath = [[NSMutableArray alloc] init];
                                                      for (int i = (int)(self.arrayPosts.count - posts.count); i < self.arrayPosts.count; i ++) {
                                                          
                                                          NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:1];
                                                          [arrayPath addObject:path];
                                                      }
                                                      
                                                      [self.refreshControl endRefreshing];
                                                      
                                                      //3. добавление ячеек в таблицу
                                                      [self.tableView beginUpdates];
                                                      [self.tableView insertRowsAtIndexPaths:arrayPath withRowAnimation:UITableViewRowAnimationTop];
                                                      [self.tableView endUpdates];
                                                      
                                                      
                                                      
                                                  } onFailure:^(NSError *error, NSInteger statusCode) {
                                                      
                                                  }];
}


- (void) getPostsReload {
    NSLog(@"getPostsReload");
    
    [self.arrayPosts removeAllObjects];
    
    [self.tableView reloadData];
    
    [[VKRequestManager sharedManager] getPostsOnWallGroupID:self.group.groupID
                                                     offset:self.arrayPosts.count
                                                      count:20
                                                  onSuccess:^(NSArray *posts, NSInteger count) {
                                                      
                                                      //1. добавление в массив новыйх сообщений
                                                      [self.arrayPosts addObjectsFromArray:posts];
                                                      
                                                      
                                                      //2. просчет всех path
                                                      NSMutableArray * arrayPath = [[NSMutableArray alloc] init];
                                                      for (int i = (int)(self.arrayPosts.count - posts.count); i < self.arrayPosts.count; i ++) {
                                                          
                                                          NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:1];
                                                          [arrayPath addObject:path];
                                                      }
                                                      
                                                      [self.refreshControl endRefreshing];
                                                      
                                                      //3. добавление ячеек в таблицу
                                                      [self.tableView beginUpdates];
                                                      [self.tableView insertRowsAtIndexPaths:arrayPath withRowAnimation:UITableViewRowAnimationTop];
                                                      [self.tableView endUpdates];
                                                      
                                                      
                                                      
                                                      
                                                  } onFailure:^(NSError *error, NSInteger statusCode) {
                                                      
                                                  }];
}



- (void) getNewPost {
    [[VKRequestManager sharedManager] getPostsOnWallGroupID:self.group.groupID
                                                     offset:0
                                                      count:1
                                                  onSuccess:^(NSArray *posts, NSInteger count) {
                                                      
                                                      
                                                      //1. добавление в массив новыйх сообщений
                                                      [self.arrayPosts insertObject:[posts firstObject] atIndex:1];
                                                      
                                                      //2. просчет всех path
                                                      NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:1];
                                                      
                                                      
                                                      [self.refreshControl endRefreshing];
                                                      
                                                      //3. добавление ячеек в таблицу
                                                      [self.tableView beginUpdates];
                                                      [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
                                                      [self.tableView endUpdates];
                                                      
                                                      
                                                  } onFailure:^(NSError *error, NSInteger statusCode) {
                                                      
                                                  }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.arrayPosts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    if (self.count == self.arrayPosts.count ) {
        NSLog(@"то не грузим");
    }
    */
    

    
    
    /*
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    */
    
    
    
    
    
    if (indexPath.section == 0) {
        VKGroupHeaderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VKGroupHeaderTableViewCell"];
        cell.labelNameGroup.text = self.group.name;
        cell.labelTypeGroup.text = self.group.type;
        [cell.imageGroup setImageWithURL:self.group.photoURL];
        return cell;
        
    } else {
        
        if ((indexPath.row == self.arrayPosts.count - 5) & (self.count != self.arrayPosts.count)) {
            NSLog(@"Пора грузить еще");
            [self getMorePosts];
        }
        
        
        VKGroupPost * post = [self.arrayPosts objectAtIndex:indexPath.row];
        VKGroupWallPostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VKGroupWallPostTableViewCell"];
        cell.labelTextMessage.text = post.text;
        cell.labelTextMessage.numberOfLines = 0;
        cell.labelNameGroup.text = post.name;
        [cell.imageGroup setImageWithURL:post.url];
        
        NSDateFormatter * form = [[NSDateFormatter alloc] init];
        [form setDateFormat:@"dd MMM yyyy HH:mm"];
        cell.labelDateMessage.text = [form stringFromDate:post.date];
        
        return cell;
    }
    
    
    /*
    cell.textLabel.text = post.text;
    cell.textLabel.numberOfLines = 0;
    */
    

    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self getNewPosts];
}

@end
