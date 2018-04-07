//
//  VKToolbarSettingsTableViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//


#import "VKToolbarSettingsTableViewController.h"
#import "VKToolbarSettingsTableViewCell.h"
#import "UIView+UITableViewCell.h"
#import "VKHelpFunction.h"


@interface VKToolbarSettingsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end


@implementation VKToolbarSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Устанавливаем режим редактирования
    self.tableView.editing = YES;
    
    
    //  Кнопка закрытия таблицы настройки кнопок тулбара
    UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(dismissSettings)];
    self.navigationItem.rightBarButtonItem = closeButton;
}


//  Закрытие таблицы настройки кнопок
- (void) dismissSettings {
    [self dismissViewControllerAnimated:YES completion:^{
        //  При закрытии таблицы сохраняем настройки кнопок в nsuserdefaults
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:self.arrayButtons forKey:@"buttons"];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayButtons.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"Cell";
    
    //  Создаем ячейку
    VKToolbarSettingsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    //  Берем кнопку
    NSMutableDictionary * button = [self.arrayButtons objectAtIndex:indexPath.row];
    
    //  Настраиваем ячейку
    cell.textLabel.text = [button objectForKey:@"buttonName"];
    cell.switchOutlet.on = [[button objectForKey:@"buttonOn"] boolValue];
    
    //  Если кнопка включена то устанавливаем свитч в состояние включени
    VKToolbarButtonType type = (VKToolbarButtonType)[[button objectForKey:@"buttonType"] intValue];
    if (type == VKToolbarButtonTypeSettings) {
        cell.switchOutlet.enabled = NO;
    } else if (type == VKToolbarButtonTypeOther) {
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in self.arrayButtons) {
            if (![[dict objectForKey:@"buttonOn"] boolValue]) {
                [arr addObject:dict];
            }
        }
        if (arr.count == 1) {
            cell.userInteractionEnabled = NO;
        }
    }
    
    return cell;
}


//  Можно ли перемещать ячейки
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary * button = [self.arrayButtons objectAtIndex:indexPath.row];
    VKToolbarButtonType type = [[button objectForKey:@"buttonType"] intValue];
    
    //  Если ячейка настройки или ячейка скрытых кнопок то их перемещать нельзя
    if ((type == VKToolbarButtonTypeSettings) | (type == VKToolbarButtonTypeOther)) {
        return NO;
    }
    return YES;
}


//  Реализация перемещения
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    //  Берем кнопку
    NSMutableDictionary * button = [self.arrayButtons objectAtIndex:sourceIndexPath.row];
    //  Удаляем ее
    [self.arrayButtons removeObjectAtIndex:sourceIndexPath.row];

    //  Вставляем
    [self.arrayButtons insertObject:button atIndex:destinationIndexPath.row];
}



#pragma mark - UITableViewDelegate
//  Добавляить ли расстояние для кнопки едитинг стайл
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

//  Какая кнопка эдитинг стайл
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


//  Индекс куда перемещается ячейка передвигаемая
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    //  Если пытаемся переместить кнопку туда где неперемещаемые кнопки, то кнопка возвращается откуда взята
    if (proposedDestinationIndexPath.row >= self.arrayButtons.count - 2) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}



#pragma mark - Value Change
//  Изменение состояния переключателя
- (IBAction)switchValueChanged:(UISwitch *)sender {
    
    //  Определяем ячейку на которой переключили свитч
    UITableViewCell * cell = [sender superCell];

    //  Определяем кнопку в массиве кнопок и меняем ее свойство
    if (cell) {
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        NSMutableDictionary * button = [self.arrayButtons objectAtIndex:path.row];
        [button setObject:[[NSNumber alloc] initWithBool:sender.on] forKey:@"buttonOn"];
    }
    
    if (!([self.tableView indexPathForCell:cell].row == self.arrayButtons.count - 2)) {
        //  Если все показаны, то надо скрыть
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in self.arrayButtons) {
            
            if (![[dict objectForKey:@"buttonOn"] boolValue]) {
                [arr addObject:dict];
            }
        }
        
        //  Убирать кнопку Остальное в зависимости от включенных кнопок
        //  Установим path кнопки которая отвечает за показ Остальное
        NSIndexPath * pathMore = [NSIndexPath indexPathForRow:self.arrayButtons.count - 2 inSection:0];
        
        //  Берем ячейку этой кнопки
        VKToolbarSettingsTableViewCell * cellMore = [self.tableView cellForRowAtIndexPath:pathMore];
        
        //  Берем коллекцию этой кнопки
        NSMutableDictionary * buttonMore = [self.arrayButtons objectAtIndex:pathMore.row];
        
        
        
        BOOL flagOn;
        
        //  Если все кнопки показаны то отключаем кнопку
        if (arr.count == 0) {
            cellMore.userInteractionEnabled = NO;
            flagOn = NO;
        } else {
            cellMore.userInteractionEnabled = YES;
            flagOn = YES;
        }
        
        //  Переключаем свитч, меняем настройки кнопки
        cellMore.switchOutlet.on = flagOn;
        [buttonMore setObject:[[NSNumber alloc] initWithBool:flagOn] forKey:@"buttonOn"];
    }
}
@end
