//
//  VKPostponedViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 25.03.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//

#import "VKPostponedViewController.h"
#import "UIColor+VKUIColor.h"

@interface VKPostponedViewController ()

@end



@implementation VKPostponedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //  Установка фона и цвета текста
    self.labelPostponedDate.textColor = [UIColor basicVKColor];
    self.labelPostponedTime.textColor = [UIColor basicVKColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.buttonCancelOutlet.backgroundColor = [UIColor basicVKColor];
    
    //  Создание и настройка левой и правой кнопки
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStyleDone target:self action:@selector(rightButton)];
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    //  Настройка дата пикера
    self.datePickerOutlet.minimumDate = [self minimumDate];
    self.datePickerOutlet.maximumDate = [self maximumDate];
    
    //  Если сообщение из которого создан объект таймера содержит отложенную датц
    if (self.parentVC.postponedInterval > 0) {
        //  Установка даты отложенной
        self.datePickerOutlet.date = [NSDate dateWithTimeIntervalSince1970:self.parentVC.postponedInterval];
    }
    
    
    //  Если сообщение не содержит интервал отложенного времени
    if (self.parentVC.postponedInterval == 0) {
        //  Скрываем кнопку сблоса
        self.buttonCancelOutlet.alpha = 0.f;
    }
    
    
    //  Тайтл
    self.title = @"Дата публикации";
    
    
    //  Установка даты в лейблы
    [self setLabelDate];
}



//  Кнопка подтверждения таймера
- (void) rightButton {
    //  Передаем в родительский класс интервал времени для отложенного сообщения
    self.parentVC.postponedInterval = [self.datePickerOutlet.date timeIntervalSince1970];
    [self leftButton];
}


//  Кнопка отмены таймера
- (void) leftButton {
    //  Закрываем вью таймера
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


//  Минимальная дата
- (NSDate *) minimumDate {
    
    //  Текущая дата
    NSDate * dateNow = [NSDate date];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    //  Раскладываем текущую дату на компоненты
    NSDateComponents * componets = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:dateNow];
    
    //  Создаем форматтер
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy/HH:mm"];
    
    //  Минимальная дата отложенного времени на минуту больше текущей даты
    NSString * minDateString = [NSString stringWithFormat:@"%li.%li.%li/%li:%li", componets.day, componets.month, componets.year, componets.hour, componets.minute + 1];
    
    //  Создаем и возвращаем минимальную дату
    NSDate * minDate = [formatter dateFromString:minDateString];
    return minDate;
}


//  Максимальная дата
- (NSDate *) maximumDate {
    
    //  Текущая дата
    NSDate * dateNow = [NSDate date];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    //  Раскладываем тукущую дату на компоненты
    NSDateComponents * componets = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:dateNow];
    
    //  Создаем форматтер
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy/HH:mm"];
    
    //  Максимальная дата публикации на год вперед
    NSString * maxDateString = [NSString stringWithFormat:@"%li.%li.%li/%li:%li", componets.day, componets.month, componets.year + 1, componets.hour, componets.minute - 1];
    
    //  Создание даты и возврат ее
    NSDate * maxDate = [formatter dateFromString:maxDateString];
    return maxDate;
}


//  Вращение дата пикера
- (IBAction)datePicker:(id)sender {
    [self setLabelDate];
}


//  Установка даты и времени в лейблы
- (void) setLabelDate {
    
    //  Создаем форматтер
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy/HH:mm"];
    
    //  Берем строку с помощью форматтера из даты на пикере
    NSString * currentDate = [formatter stringFromDate:self.datePickerOutlet.date];
    NSArray * array = [currentDate componentsSeparatedByString:@"/"];
    
    //  Устанавливаем в лейблы дату и время
    self.labelPostponedDate.text = [array objectAtIndex:0];
    self.labelPostponedTime.text = [array objectAtIndex:1];
}


//  Сброс настроек интервала отложенного сообщения
- (IBAction)buttonOutlet:(id)sender {
    
    if (self.parentVC.postponedInterval > 0) {
        //  Установка интервала в ноль и закрытие вью таймера
        self.parentVC.postponedInterval = 0;
        [self leftButton];
    }
}
@end
