//
//  VKSharedGroupsTableViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 16.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKSharedGroupsTableViewController.h"
#import "VKRequestManager.h"
#import "UIColor+VKUIColor.h"

@interface VKSharedGroupsTableViewController ()

//  Массив всех групп пользователя
@property (nonatomic, strong) NSMutableArray * arrayAllUserGroups;
//  Блок исполнения
@property (nonatomic, strong) VKTakeSharedGroupsBlock completionBlock;


@end

@implementation VKSharedGroupsTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Загрузка всех групп
    [self loadAllGroups];
    
    //  Создание и установка кнопки правой
    UIBarButtonItem * butoon = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStyleDone
                                                               target:self
                                                               action:@selector(closeTable)];
    self.navigationItem.rightBarButtonItem = butoon;
    
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeView)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    //  Тайтл
    self.title = @"Опубликовать в";
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



//  Инициализация через блок исполнения
- (instancetype)initWithCompletionBlock:(VKTakeSharedGroupsBlock)completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void) closeView {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


//  Закрытие таблицы
- (void) closeTable {
    
    //  Если есть блок исполнения то передаем массив групп в которые нужно отправить
    if (self.completionBlock) {
        self.completionBlock(self.arraySharedGroups);
    }
    
    //  Закрываем таблицу
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


//  Загрузка всех групп
- (void) loadAllGroups {
    
    //  Запрос всех групп пользователя
    [[VKRequestManager sharedManager] getGroupsWithOffset:0
                                                    count:1000
                                                 onSucces:^(NSArray *groups) {
                                                     
                                                     // Создаем изменяемый массив на основе полученных групп
                                                     NSMutableArray * mGroups = [NSMutableArray arrayWithArray:groups];
                                                     
                                                     // Получаем ID групп полученных
                                                     NSArray * names = [groups valueForKeyPath:@"@unionOfObjects.groupID"];
                                                     
                                                     // Если полученные группы содержат группу из которой пишем
                                                     if ([names containsObject:self.currentGroup.groupID]) {
                                                         
                                                         // То надо удалить ее имя из списка шэра
                                                         NSInteger index = [names indexOfObject:self.currentGroup.groupID];
                                                         [mGroups removeObjectAtIndex:index];
                                                     }
                                                     
                                                     // Переопределяем массив из которого загружается таблица
                                                     // С удаленной из нее текущей группой
                                                     self.arrayAllUserGroups = [NSMutableArray arrayWithArray:mGroups];
                                                     [self.tableView reloadData];
                                                     
                                                 } onFailure:^(NSError *error) {
                                                     NSLog(@"ERROR - %@", error.description);
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
    
    //  Собираем массив ID групп пользователя в которые шарим
    NSArray * array = [self.arraySharedGroups valueForKeyPath:@"@unionOfObjects.groupID"];
    
    //  Если массив в которые шарим содержит текущую группу то ставим галочку рядом
    if ([array containsObject:group.groupID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}




- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  Берем группу по индексу ячейки на которую нажали
    VKGroup * group = [self.arrayAllUserGroups objectAtIndex:indexPath.row];
    
    //  Берем ячейку по индексу
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    //  Создаем тип индикатора
    UITableViewCellAccessoryType type = UITableViewCellAccessoryNone;
    
    //  Если тип индикатора - галочка
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        
        //  Массив имен в которые шарим
        NSArray * array = [self.arraySharedGroups valueForKeyPath:@"@unionOfObjects.name"];
        
        //  Если массив содержит ту группу на которую нажали, то удаляем группу из массива
        if ([array containsObject:group.name]) {
            
            NSInteger index = [array indexOfObject:group.name];
            [self.arraySharedGroups removeObjectAtIndex:index];
        }
        
        //  Меняем тип
        type = UITableViewCellAccessoryNone;
        
        
    //  Если тип индикатора пустой
    } else {
        
        //  Добавляем нажатую группу в массив шаренных
        [self.arraySharedGroups addObject:group];
        //  Меняем индикатор
        type = UITableViewCellAccessoryCheckmark;
    }
    

    //  Устанавливаем индикатор
    cell.accessoryType = type;
}


@end
