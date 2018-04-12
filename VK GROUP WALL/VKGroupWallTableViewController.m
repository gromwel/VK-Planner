//
//  VKGroupWallTableViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 11.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс который показывает таблицу с сообщениями стены группы



#import "VKGroupWallTableViewController.h"
#import "VKRequestManager.h"
#import "VKGroupPost.h"
#import "VKNewPostViewController.h"

#import <UIImageView+AFNetworking.h>
#import <UIImage+AFNetworking.h>

#import "VKGroupHeaderTableViewCell.h"
#import "VKGroupWallPostTableViewCell.h"

#import "UIColor+VKUIColor.h"

@interface VKGroupWallTableViewController ()


//  Массив постов
@property (nonatomic, strong) NSMutableArray * arrayPosts;
//  Массив отложенных постоов
@property (nonatomic, strong) NSMutableArray * arrayPostponedPosts;
//  Флаг первого запуска
@property (nonatomic, assign) BOOL firstStart;
//  Количество постов
@property (nonatomic, assign) NSInteger count;
//  Количество отложенных постов
@property (nonatomic, assign) NSInteger countPostponed;
//  Индекс отложенного поста
@property (nonatomic, assign) NSInteger postponedPostIndex;
//  Флаг показа отложенных постов
@property (nonatomic, assign) BOOL showPostponed;


@end




@implementation VKGroupWallTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Установка начальных значений свойств
    self.firstStart = YES;
    self.showPostponed = NO;
    self.postponedPostIndex = NSNotFound;
    
    //  Инициализация свойств
    self.arrayPosts = [[NSMutableArray alloc] init];
    self.arrayPostponedPosts = [[NSMutableArray alloc] init];
    
    
    //  Пустая кнопка назад сделана через сториборд
    
    
    //  Тайтл
    self.navigationItem.title = self.group.name;
    
    
    //  Создание и установка кнопки
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(newPost)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    
    //  Добавление рефреша
    self.refreshControl = [[UIRefreshControl alloc] init];
    NSAttributedString * string = [[NSAttributedString alloc] initWithString:@"Обновление..." attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.refreshControl.attributedTitle = string; //[[NSAttributedString alloc] initWithString:@"Обновление..."];
    
    self.refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl.backgroundColor = [UIColor additionalVKColor];
    [self.refreshControl addTarget:self action:@selector(getPostsReload) forControlEvents:UIControlEventValueChanged];
    
    
    [self.refreshControl beginRefreshing];
}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //  Если первый старт
    if (self.firstStart) {
        
        //  Загружаем посты типа Опубликованные
        [self getMorePostsPostponed:VKPostResponseTypePublished];
        //  Меняем флаг
        self.firstStart = NO;
    }
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}




//  Новый пост
- (void) newPost {
    //  Запрашиваем посты из группы
    [[VKRequestManager sharedManager] newWallMessageWithGroup:self.group
                                                    onSuccess:^(id responseObject, VKPostType postType) {
                                                        
                                                        //  Если ответ пришел
                                                        if (responseObject) {

                                                            //  Если тип пришедших сообщений ОПУБЛИКОВАННЫЕ
                                                            if (postType == VKPostTypePublished) {
                                                                //  Запрос только последнего поста
                                                                [self getLastPost];
                                                                
                                                            //  Если тип пришедших сообщений ОТЛОЖЕННЫЕ
                                                            } else if (postType == VKPostTypePostponed) {
                                                                
                                                                
                                                                //  Если отложенные и до этого отложенных не было
                                                                if (self.countPostponed == 0) {
                                                                    //
                                                                    [self getMorePostsPostponed:VKPostResponseTypePostponedOnlyCount];
                                                                
                                                                
                                                                //  Если отложенные и до этого отложенные не показываются
                                                                } else if ((self.countPostponed > 0) & !self.showPostponed) {
                                                                    //  Очистка массива отложенных
                                                                    [self.arrayPostponedPosts removeAllObjects];
                                                                
                                                                
                                                                //  Если отложенные и до этого отложенные показываются
                                                                } else if ((self.countPostponed > 0) & self.showPostponed) {
                                                                    
                                                                    //  Берем коллекцию из пришедшего ответа
                                                                    NSDictionary * dict = [responseObject objectForKey:@"response"];
                                                                    //  Из коллекции количество всех оложенных постов в группе
                                                                    self.postponedPostIndex = [[dict objectForKey:@"post_id"] integerValue];
                                                                    
                                                                    //  Скрываем отложенные
                                                                    self.showPostponed = !self.showPostponed;
                                                                    [self hidePostponedPost];
                                                                    
                                                                    //  Удаляем отложенные из массива
                                                                    [self.arrayPostponedPosts removeAllObjects];
                                                                    
                                                                    //  Показываем отложенные
                                                                    self.showPostponed = !self.showPostponed;
                                                                    [self showPostponedPost];
                                                                }
                                                            }
                                                        }
                                                    } onFailure:^(NSError *error) {
                                                        NSLog(@"ERROR - %@", error.description);
                                                    }];
}





//  Загружаем посты при открытии стены и далее по прокрутке
- (void) getMorePostsPostponed:(VKPostResponseType)responseType {
    
    //  Определяем переменные
    NSInteger section = 3;
    NSInteger arrayCount = self.arrayPosts.count;
    NSInteger countRequest = 20;
    
    
    //  Если тип запрашиваемых сообщений ОТЛОЖЕННЫЕ то переопределяем переменные
    if (responseType == VKPostResponseTypePostponed) {
        section = 1;
        countRequest = 5;
        arrayCount = self.arrayPostponedPosts.count;
    }
    
    
    //  Запрос постов по параметрам
    [[VKRequestManager sharedManager] getPostsOnWallGroupID:self.group.groupID
                                                     offset:arrayCount
                                                      count:countRequest
                                               responseType:responseType
                                                  onSuccess:^(NSArray *posts, NSInteger count) {
                                                      
                                                      //    Если запрашиваются только количество сообщений и это количество больше 0
                                                      if (responseType == VKPostResponseTypePostponedOnlyCount & count > 0) {
                                                          
                                                          
                                                          NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:2];
                                                          self.countPostponed = count;
                                                          [self.tableView beginUpdates];
                                                          [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
                                                          [self.tableView endUpdates];
                                                          
                                                      }
                                                      
                                                      //    Если запрашиваются отложенные посты
                                                      if (responseType == VKPostResponseTypePostponed) {
                                                          
                                                          //    Запишем количество отложенных и добавим в массив отложенных
                                                          self.countPostponed = count;
                                                          [self.arrayPostponedPosts addObjectsFromArray:posts];
                                                      
                                                          
                                                      //    Если любые другие
                                                      } else {
                                                          
                                                          //    Записываем количество опубликованных сообщений и добавляем в массив опубликованных
                                                          self.count = count;
                                                          [self.arrayPosts addObjectsFromArray:posts];
                                                      }
                                                      
                                                      
                                                      NSInteger countPosts = self.arrayPosts.count;
                                                      
                                                      //    Если запрашиваются отложенные посты
                                                      if (responseType == VKPostResponseTypePostponed) {
                                                          countPosts = self.arrayPostponedPosts.count;
                                                      }
                                                      
                                                      
                                                      
                                                      //    2
                                                      //    Просчет всех path добавляемых сообщений в один массив
                                                      NSMutableArray * arrayPath = [[NSMutableArray alloc] init];
                                                      for (int i = (int)(countPosts - posts.count); i < countPosts; i ++) {
                                                          NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:section];
                                                          [arrayPath addObject:path];
                                                      }
                                                      
                                                      //    Завершение анимации рефреша
                                                      [self.refreshControl endRefreshing];
                                                      
                                                      
                                                      //    3
                                                      //    Добавление ячеек в таблицу
                                                      [self.tableView beginUpdates];
                                                      [self.tableView insertRowsAtIndexPaths:arrayPath withRowAnimation:UITableViewRowAnimationTop];
                                                      [self.tableView endUpdates];
                                                      
                                                      
                                                      //    Если запрашиваются отложенные посты
                                                      if (responseType == VKPostResponseTypePostponed) {
                                                          
                                                          //    По умолчанию номер ячейки к которой скролим это последняя ячейка секции отложенных
                                                          NSInteger row = self.arrayPostponedPosts.count - 1;
                                                          
                                                          //    Если есть индекс отложенного сообщения
                                                          if (self.postponedPostIndex != NSNotFound) {
                                                              
                                                              
                                                              //    Перебираем массив отложенных сообщений
                                                              for (VKGroupPost * post in self.arrayPostponedPosts) {
                                                                  //    Если индекс перебираемого сообщения равен индексу отложенного
                                                                  if (post.index == self.postponedPostIndex) {
                                                                      //    Переопределяем ячейку
                                                                      row = [self.arrayPostponedPosts indexOfObject:post];
                                                                  }
                                                              }
                                                              
                                                              //    Считаем path
                                                              NSIndexPath * path = [NSIndexPath indexPathForRow:row inSection:1];
                                                              
                                                              //    Выделяем добавленное сообщение на 0.8 секунды
                                                              [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
                                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                  [self.tableView deselectRowAtIndexPath:path animated:YES];
                                                              });
                                                              
                                                              
                                                          // Если нет индекса отложенного сообщения
                                                          } else {
                                                              
                                                              //    Считаем path
                                                              NSIndexPath * path = [NSIndexPath indexPathForRow:row inSection:1];
                                                              //    Скролим до последнего сообщения
                                                              [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                                          }
                                                          
                                                          
                                                      //    Если запрашиваются опубликованные посты
                                                      } else if (responseType == VKPostResponseTypePublished) {
                                                          
                                                          //    Определяем количество ячеек в секции где кнопка ПОКАЗАТЬ ОТЛОЖЕННЫЕ
                                                          NSInteger rows = [self.tableView numberOfRowsInSection:2];
                                                          
                                                          //    Если количество 0 то запрашиваем отложенные через секунду
                                                          if (rows == 0) {
                                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                  [self getMorePostsPostponed:VKPostResponseTypePostponedOnlyCount];
                                                              });
                                                          }
                                                      }
                                                      
                                                  } onFailure:^(NSError *error) {
                                                      NSLog(@"ERROR - %@", error.description);
                                                  }];
}






//  Перезагрузка постов по пулл то рефреш
- (void) getPostsReload {
    
    //  Чистим массив опубликованных постов и перезагружаем таблицу
    [self.arrayPosts removeAllObjects];
    [self.tableView reloadData];
    
    //  Скрыть отложенные посты если показаны
    if (self.showPostponed) {
        self.showPostponed = !self.showPostponed;
        [self hidePostponedPost];
    }
    
    
    //  Запрос постов опубликованных
    [[VKRequestManager sharedManager] getPostsOnWallGroupID:self.group.groupID
                                                     offset:self.arrayPosts.count
                                                      count:20
                                               responseType:VKPostResponseTypePublished
                                                  onSuccess:^(NSArray *posts, NSInteger count) {
                                                      
                                                      //    Добавление в массив (обнуленный) новыйх сообщений
                                                      [self.arrayPosts addObjectsFromArray:posts];
                                                      
                                                      //    Просчет всех path
                                                      NSMutableArray * arrayPath = [[NSMutableArray alloc] init];
                                                      for (int i = (int)(self.arrayPosts.count - posts.count); i < self.arrayPosts.count; i ++) {
                                                          NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:3];
                                                          [arrayPath addObject:path];
                                                      }
                                                      
                                                      //    Остановка анимации рефреша
                                                      [self.refreshControl endRefreshing];
                                                      
                                                      //    Добавление ячеек в таблицу
                                                      [self.tableView beginUpdates];
                                                      [self.tableView insertRowsAtIndexPaths:arrayPath withRowAnimation:UITableViewRowAnimationTop];
                                                      [self.tableView endUpdates];

                                                  } onFailure:^(NSError *error) {
                                                      NSLog(@"ERROR - %@", error.description);
                                                  }];
}



//  Загрузка последнего добавленного поста
- (void) getLastPost {
    
    //  Запрос последнего сообщения опубликованного
    [[VKRequestManager sharedManager] getPostsOnWallGroupID:self.group.groupID
                                                     offset:0
                                                      count:1
                                               responseType:VKPostResponseTypePublished
                                                  onSuccess:^(NSArray *posts, NSInteger count) {
                                                      
                                                      //    Добавление в массив новыйх сообщений
                                                      [self.arrayPosts insertObject:[posts firstObject] atIndex:0];
                                                      
                                                      //    Просчет всех path
                                                      NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:3];
                                                      
                                                      //    Финишь анимации рефреша
                                                      [self.refreshControl endRefreshing];
                                                      
                                                      //    Добавление ячеек в таблицу
                                                      [self.tableView beginUpdates];
                                                      [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
                                                      [self.tableView endUpdates];
                                                      
                                                  } onFailure:^(NSError *error) {
                                                      NSLog(@"ERROR  - %@", error.description);
                                                  }];
}


#pragma mark - Table view data source
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    //  Показаны отложенные то добавляем хедеры
    if (self.showPostponed) {
        if (section == 1) {
            return @"Отложенные";
        } else if (section == 3) {
            return @"Опубликованные";
        }
    }
    
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
        
    } else if (section == 1) {
        if (!self.showPostponed) {
            return 0;
        }
        return self.arrayPostponedPosts.count;
        
    } else if (section == 2) {
        if (self.countPostponed > 0) {
            return 1;
        }
        return 0;
    }
    
    return self.arrayPosts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //  Первая секция ШАПКА
    if (indexPath.section == 0) {
        
        //  Создание и настройка ячейки
        VKGroupHeaderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VKGroupHeaderTableViewCell"];
        cell.labelNameGroup.text = self.group.name;
        cell.labelTypeGroup.text = self.group.type;
        [cell.imageGroup setImageWithURL:self.group.photoURL];
        return cell;
        
        
        
    //  Вторая секция ОТЛОЖЕННЫЕ
    } else if (indexPath.section == 1) {
        
        //  Если ячейка вторая и количесво все отложенных больше чем сейчас загружено
        if ((indexPath.row == 2) & (self.countPostponed > self.arrayPostponedPosts.count)) {
            NSLog(@"Пора грузить еще отложенных");
            //[self getMorePostsPostponed:NO];
        }
        

        //  Берем пост из массива
        VKGroupPost * post = [self.arrayPostponedPosts objectAtIndex:indexPath.row];
        
        //  Создаем и настраиваем ячейку
        VKGroupWallPostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VKGroupWallPostTableViewCell"];
        
        cell.labelTextMessage.text = post.text;
        cell.labelTextMessage.numberOfLines = 0;
        cell.labelTextMessage.alpha = 0.5f;
        
        cell.labelNameGroup.text = post.name;
        cell.labelNameGroup.alpha = 0.5f;
            
        [cell.imageGroup setImageWithURL:post.url];
        cell.imageGroup.alpha = 0.5f;
        
        
        //  Если пост имеем подпись
        if (post.signerName) {
            cell.labelCreator.alpha = 1.f;
            NSString * name = [NSString stringWithFormat:@"%@", post.signerName];
            cell.labelCreator.text = name;
            cell.labelCreator.alpha = 0.5f;
        }
            
        NSDateFormatter * form = [[NSDateFormatter alloc] init];
        [form setDateFormat:@"dd MMM yyyy HH:mm"];
        cell.labelDateMessage.text = [form stringFromDate:post.date];
        cell.labelDateMessage.alpha = 0.5f;
        //cell.backgroundColor = [UIColor greenColor];
        
        cell.imageAds.alpha = post.ads;
        
        return cell;
        
        
    //  Третья секция КНОПКА
    } else if (indexPath.section == 2) {
        
        //  Создаем и настраиваем ячейку
        UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.text = @"Показать запланированные";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor additionalVKColor];
        return cell;
        
        
    //  Четвертая секция ОПУБЛИКОВАННЫЕ
    } else {
        
        //  Если осталось 5 ячеек до конца и всего сообщений меньше чем сейчас загруженно
        if ((indexPath.row == self.arrayPosts.count - 5) & (self.count < self.arrayPosts.count)) {
            //  Заргужаем еще
            [self getMorePostsPostponed:VKPostResponseTypePublished];
        }
        
        //  Создаем пост и ячейку
        VKGroupPost * post = [self.arrayPosts objectAtIndex:indexPath.row];
        VKGroupWallPostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VKGroupWallPostTableViewCell"];
        
        //  Настраиваем ячейку
        cell.labelTextMessage.text = post.text;
        cell.labelTextMessage.numberOfLines = 0;
        cell.labelTextMessage.alpha = 1.f;
        
        cell.labelNameGroup.text = post.name;
        cell.labelNameGroup.alpha = 1.f;
        
        [cell.imageGroup setImageWithURL:post.url];
        cell.imageGroup.alpha = 1.f;
        
        cell.imageAds.alpha = post.ads;
        
        //  Если пост имеем подпись
        if (post.signerName) {
            cell.labelCreator.alpha = 1.f;
            NSString * name = [NSString stringWithFormat:@"%@", post.signerName];
            cell.labelCreator.text = name;
        }
        
        
        NSDateFormatter * form = [[NSDateFormatter alloc] init];
        [form setDateFormat:@"dd MMM yyyy HH:mm"];
        cell.labelDateMessage.text = [form stringFromDate:post.date];
        cell.labelDateMessage.alpha = 1.f;
        
        return cell;
    }
    return nil;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  Создаем path для кнопки
    NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:2];
    
    //  Если нажатая ячейка есть ячейка кнопки
    if (indexPath == path) {
        
        //  Переопрежедяем флаг
        self.showPostponed = !self.showPostponed;
        
        //  Берем ячейку кнопки
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        
        //  Меняем текст на кнопке и мвызываем метод скрыть/показать
        if (self.showPostponed) {
            cell.textLabel.text = @"Скрыть запланированные";
            [self showPostponedPost];
            
        } else {
            cell.textLabel.text = @"Показать запланированные";
            [self hidePostponedPost];
        }
    }
}



//  Скрыть отложенные посты
- (void) hidePostponedPost {
    
    NSMutableArray * arrayPath = [[NSMutableArray alloc] init];
    
    //  Перебираем массив отложенных сообщений и для каждого считаем path
    for (int i = 0; i < self.arrayPostponedPosts.count; i++) {
        NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:1];
        [arrayPath addObject:path];
    }
    
    //  Удаляем из таблицы эти ячейки
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:arrayPath withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}



//  Показать отложенные посты
- (void) showPostponedPost {
    
    //  Если массив отложенных сообщений содержит сообщения
    if (self.arrayPostponedPosts.count > 0) {
        
        NSMutableArray * arrayPaht = [[NSMutableArray alloc] init];
        
        //  Перебираем массив отложенных сообщений и для каждого считаем path
        for (int i = 0; i < self.arrayPostponedPosts.count; i++) {
            NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:1];
            [arrayPaht addObject:path];
        }
        
        //  Добавление ячеек в таблицу
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:arrayPaht withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        
        //  Определим индекс последней ячейки
        NSInteger row = self.arrayPostponedPosts.count - 1;
        
        //  Создаем path с индексом последней ячейки и просскролим до нее
        NSIndexPath * path = [NSIndexPath indexPathForRow:row inSection:1];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        
    //  Если массив не содержит сообщений
    } else {
        //  Запрашиваем отложенные сообщения
        [self getMorePostsPostponed:VKPostResponseTypePostponed];
    }
}





- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //  Если удаление вызвано
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //  Создаем алерт контроллер с вопросом о удалении
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Удаление" message:@"Вы действительно хотите удалить этот пост?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"Удалить" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            NSMutableArray * mArray = [[NSMutableArray alloc] init];
            
            //  Считать пост ID
            if (indexPath.section == 1) {
                mArray = self.arrayPostponedPosts;
                
            } else if (indexPath.section == 3) {
                mArray = self.arrayPosts;
                
            }
            
            VKGroupPost * post = [mArray objectAtIndex:indexPath.row];
            NSString * index = [NSString stringWithFormat:@"%li", post.index];
            
            //  Удалить пост по ID
            [[VKRequestManager sharedManager] deleteWallPostWithPostID:index groupID:self.group.groupID
                                    onSuccess:^(id responseObject) {
                                        
                                        NSString * response = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"response"]];
                                        
                                        if ([response isEqualToString:@"1"]) {
                                            //  Удаление из массива
                                            [mArray removeObject:post];
                                            
                                            //  Удаление ячейки
                                            [tableView beginUpdates];
                                            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                                            [tableView endUpdates];
                                            
                                            
                                        } else if ([responseObject objectForKey:@"error"]) {
                                            NSDictionary * response = [responseObject objectForKey:@"error"];
                                            [self showAlertWithTitle:@"Error" message:[response objectForKey:@"error_msg"]];
                                        } else {
                                            [self showAlertWithTitle:@"Ошибка" message:@"Пост не удален"];
                                        }
                                        
                                    } onFailure:^(NSError *error) {
                                        NSLog(@"ERROR - %@", error.description);
                                    }];
        }];
        
        
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        
        //  Показываем алерт
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
}


//  Алерт контроллер без кнопок
- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:controller animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        });
    }];
}


@end
