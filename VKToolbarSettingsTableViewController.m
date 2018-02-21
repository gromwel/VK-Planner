//
//  VKToolbarSettingsTableViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 18.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
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
    //режим редактирования
    self.tableView.editing = YES;
    
    //кнопка закрытия
    UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(dismissSettings)];
    self.navigationItem.rightBarButtonItem = closeButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) dismissSettings {
    [self dismissViewControllerAnimated:YES completion:^{
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
    VKToolbarSettingsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    NSMutableDictionary * button = [self.arrayButtons objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [button objectForKey:@"buttonName"];
    cell.switchOutlet.on = [[button objectForKey:@"buttonOn"] boolValue];
    
    VKToolbarButtonType type = (VKToolbarButtonType)[[button objectForKey:@"buttonType"] intValue];
    if (type == VKToolbarButtonTypeSettings) {
        cell.switchOutlet.enabled = NO;
    }
    
    return cell;
}


//можно ли перемещать ячейки
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary * button = [self.arrayButtons objectAtIndex:indexPath.row];
    VKToolbarButtonType type = [[button objectForKey:@"buttonType"] intValue];
    if ((type == VKToolbarButtonTypeSettings) | (type == VKToolbarButtonTypeOther)) {
        return NO;
    }
    return YES;
}


//реализация перемещения
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    //берем кнопку
    NSMutableDictionary * button = [self.arrayButtons objectAtIndex:sourceIndexPath.row];
    //удаляем ее
    [self.arrayButtons removeObjectAtIndex:sourceIndexPath.row];

    //вставляем
    [self.arrayButtons insertObject:button atIndex:destinationIndexPath.row];

}



#pragma mark - UITableViewDelegate
//добавляить ли расстояние для кнопки едитинг стайл
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

//какая кнопка эдитинг стайл
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}



- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    if (proposedDestinationIndexPath.row >= self.arrayButtons.count - 2) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

#pragma mark - Value Change
- (IBAction)switchValueChanged:(UISwitch *)sender {

    UITableViewCell * cell = [sender superCell];

    if (cell) {
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        NSMutableDictionary * button = [self.arrayButtons objectAtIndex:path.row];
        [button setObject:[[NSNumber alloc] initWithBool:sender.on] forKey:@"buttonOn"];
    }

}
@end
