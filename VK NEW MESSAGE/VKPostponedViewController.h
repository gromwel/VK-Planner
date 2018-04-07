//
//  VKPostponedViewController.h
//  VK GPM
//
//  Created by Clyde Barrow on 25.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//
//  Класс который отвечает за вью установки временни отложенной отправки поста

#import <UIKit/UIKit.h>
#import "VKNewPostViewController.h"

@interface VKPostponedViewController : UIViewController

//  Вью контроллер из которого вызван вью настройки таймера
@property (nonatomic, strong) VKNewPostViewController * parentVC;

//  Лейблы отложенной даты и времени
@property (weak, nonatomic) IBOutlet UILabel *labelPostponedDate;
@property (weak, nonatomic) IBOutlet UILabel *labelPostponedTime;

//  Дата пикер
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerOutlet;
//  Кнопка сброса таймера
@property (weak, nonatomic) IBOutlet UIButton *buttonCancelOutlet;

//  Кнопка сброса таймера сообщения
- (IBAction)buttonOutlet:(id)sender;
//  Дата пикер
- (IBAction)datePicker:(id)sender;

@end
//git commit -m "v.1.2 Added minor changes. Added postponed post support."
