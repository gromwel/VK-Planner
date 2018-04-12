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
#import "UIColor+VKUIColor.h"



@interface VKUserGroupsTableViewController ()

//  Массив групп
@property (nonatomic, strong) NSMutableArray * groupsArray;

//  Флаг первого запуска
@property (nonatomic, assign) BOOL firstStart;

//  Нынешний юзер
@property (nonatomic, strong) VKUser * currentUser;


@end

@implementation VKUserGroupsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Определение и инициализация переменных
    self.firstStart = YES;
    self.groupsArray = [[NSMutableArray alloc] init];
    self.currentUser = [[VKUser alloc] init];
    
    
    //  Добавление кнопки выйти
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Выйти"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logout)] ;
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    //  Устанока тайтла
    self.navigationItem.title = @"Управление";
    self.navigationController.navigationBar.barTintColor = [UIColor basicVKColor];
    
    
    //  Рефреш контроллер
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getGroupsRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Обновление..."];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //  Ели первый старт то запускаем метод старта с экраном
    if (self.firstStart) {
        
        //  Если есть токен то берем группы и меняем флаг иниче запускаем авторизацию
        if ([[CoreDataManager sharedManager] token]) {
            [self getGroups];
            self.firstStart = NO;
        } else {
            [[VKRequestManager sharedManager] autorisationUserWithSplashScreen];
        }
    }
    
    
    //  Добавление аватарки
    VKToken * token = [[CoreDataManager sharedManager] token];
    
    //  Запрос юзера
    [[VKRequestManager sharedManager] getUserWithUserID:token.userID
                                              onSuccess:^(VKUser *user) {
                                                  
                                                  //    Создание аваторки кнопки
                                                  [self createAvatarBarButtonItemWithURL:user.photo];
                                                  
                                              } onFailure:^(NSError *error) {
                                              }];
}




- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}



//  Создание аватарки кнопки из ссылки на картинку
- (void) createAvatarBarButtonItemWithURL:(NSURL *)url {
    
    //  Создаем реквест
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    //  Создаем навигейшн
    UINavigationController * navigation = [[UINavigationController alloc] init];
    CGFloat lenght = navigation.navigationBar.frame.size.height/3 * 2;
    CGFloat heightBar = navigation.navigationBar.frame.size.height;
    
    
    //  Кастомная кнопка
    UIButton * customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, heightBar, heightBar);
    customButton.contentMode = UIViewContentModeScaleToFill;
    customButton.imageView.layer.cornerRadius = lenght/2;
    customButton.imageView.layer.masksToBounds = YES;
    

    //  Добавляем таргет к кнопке
    [customButton addTarget:self action:@selector(rightButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    //  Загрузка картинки в кнопку
    __weak UIButton * weakButton = customButton;
    [customButton.imageView setImageWithURLRequest:request
                                  placeholderImage:nil
                                           success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                               
                                               //   Ресайз изображения после загрузки и установка
                                               UIImage * after = [UIImage imageWithCGImage:image.CGImage
                                                                                     scale:CGImageGetHeight(image.CGImage)/lenght
                                                                               orientation:UIImageOrientationUp];
                                               
                                               [weakButton setImage:after forState:UIControlStateNormal];
                                               
                                               
                                           } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                               NSLog(@"ERROR - %@", error.description);
                                           }];
    
    
    //  Создание бар баттона и установка
    UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithCustomView:weakButton];
    self.navigationItem.rightBarButtonItem = button;
}



//  Правая кнопка
- (void) rightButton {
    [[VKRequestManager sharedManager] logoutUser];
}


//  Разлогин
- (void) logout {
    [[VKRequestManager sharedManager] logoutUser];
}


//  Перезагрузка групп
- (void) getGroupsRefresh {
    
    //  Очистка массива
    [self.groupsArray removeAllObjects];
    
    //  Запрос групп пользователя
    [[VKRequestManager sharedManager] getGroupsWithOffset:self.groupsArray.count
                                                    count:1000
                                                 onSucces:^(NSArray *groups) {
                                                     
                                                     // Перезагрузка таблицы (пустая)
                                                     [self.tableView reloadData];
                                                     
                                                     // Добавить группы в массив
                                                     [self.groupsArray addObjectsFromArray:groups];
                                                     
                                                     // Создать массив path для добавления в таблицу
                                                     NSMutableArray * mArray = [[NSMutableArray alloc] init];
                                                     
                                                     for (int i = (int)(self.groupsArray.count - groups.count); i < self.groupsArray.count; i++) {
                                                         NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:0];
                                                         [mArray addObject:path];
                                                     }
                                                     
                                                     // Завершение рефреша
                                                     [self.refreshControl endRefreshing];
                                                     
                                                     // Добавить ячейки в баблицу
                                                     [self.tableView beginUpdates];
                                                     [self.tableView insertRowsAtIndexPaths:mArray withRowAnimation:UITableViewRowAnimationFade];
                                                     [self.tableView endUpdates];
                                                     
                                                 }
                                                onFailure:^(NSError *error) {
                                                    NSLog(@"ERROR - %@", error.description);
                                                }];
}



//  Запрос групп
- (void) getGroups {
    
    //  Запрос групп
    [[VKRequestManager sharedManager] getGroupsWithOffset:self.groupsArray.count
                                                    count:1000
                                                 onSucces:^(NSArray *groups) {
                                                     
                                                     // Добавить группы в массив
                                                     [self.groupsArray addObjectsFromArray:groups];

                                                     // Создать массив path для добавления в таблицу
                                                     NSMutableArray * mArray = [[NSMutableArray alloc] init];
                                                     
                                                     for (int i = (int)(self.groupsArray.count - groups.count); i < self.groupsArray.count; i++) {
                                                         NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:0];
                                                         [mArray addObject:path];
                                                     }

                                                     // Добавить ячейки в баблицу
                                                     [self.tableView beginUpdates];
                                                     [self.tableView insertRowsAtIndexPaths:mArray withRowAnimation:UITableViewRowAnimationFade];
                                                     [self.tableView endUpdates];
                                                     
                                                     // Завершение рефреша
                                                     [self.refreshControl endRefreshing];
                                                     
                                                 }
                                                onFailure:^(NSError *error) {
                                                    NSLog(@"ERROR - %@", error.description);
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
    
    //  Создание таблицы записей стены
    VKGroupWallTableViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupWall"];
    
    //  Создание группы той на которую нажали и установка ее в проперти таблицы записей стены
    VKGroup * group = [self.groupsArray objectAtIndex:indexPath.row];
    vc.group = group;
    
    //  Добавление на навигейшн таблицу
    [self.navigationController pushViewController:vc animated:YES];
}

@end
