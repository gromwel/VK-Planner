//
//  VKNewPostViewController.m
//  VK GPM
//
//  Created by Clyde Barrow on 13.02.2018.
//  Copyright © 2018 Clyde Barrow. All rights reserved.
//



#import "VKNewPostViewController.h"
#import "VKRequestManager.h"
#import "VKToolbarSettingsTableViewController.h"
#import "VKHelpFunction.h"
#import "VKSharedGroupsTableViewController.h"
#import "VKPostponedViewController.h"



@interface VKNewPostViewController () <UITextViewDelegate>


//  Реализация блока
@property (nonatomic, strong) VKSendMessageBlock completionBlock;

//
@property (nonatomic, strong) id response;

//  Тип отправляемого сообщения сразу/отложенное
@property (nonatomic, assign) VKPostType postType;

//  Плейсхолдер
@property (nonatomic, strong) UITextField * placeholder;

//  Массивы кнопок/показываемых/скрытых
@property (nonatomic, strong) NSMutableArray * arrayButtons;
@property (nonatomic, strong) NSMutableArray * showsButtons;
@property (nonatomic, strong) NSMutableArray * hidesButtons;

//  Дефолтные кнопки тулбара
@property (nonatomic, strong) NSMutableArray * toolbarItemsCustom;

//  Массив групп в которые отправляется сообщение (минимум 1)
@property (nonatomic, strong) NSMutableArray * sharedGroups;

//  Флаг рекламы
@property (nonatomic, assign) BOOL flagAds;
//  Флаг подписи под записью
@property (nonatomic, assign) BOOL flagSigned;


@end



@implementation VKNewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //  Установка дефолтных значений переменных
    self.view.backgroundColor = [UIColor whiteColor];
    self.postponedInterval = 0;
    self.postType = -1;
    self.flagAds = NO;
    self.flagSigned = NO;
    
    

    //  Инициализация массивов
    self.sharedGroups = [[NSMutableArray alloc] initWithObjects:self.group, nil];;
    self.showsButtons = [[NSMutableArray alloc] init];
    self.hidesButtons = [[NSMutableArray alloc] init];
    self.toolbarItemsCustom = [[NSMutableArray alloc] init];
    
    
    
    //  Проверяем на настроенные кнопки
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSArray * buttons = [settings objectForKey:@"buttons"];
    
    //  Если кнопок нет, то
    if (!buttons) {
        //  Создаем кнопки
        self.arrayButtons = [[NSMutableArray alloc] init];
        [self createButtonsDictionary];
        
    //  Или создаем те что есть
    } else {
        
        NSMutableArray * array = [[NSMutableArray alloc] init];
        for (int i = 0; i < buttons.count; i++) {
            NSMutableDictionary * mDict = [[NSMutableDictionary alloc] initWithDictionary:[buttons objectAtIndex:i]];
            [array addObject:mDict];
        }
        
        self.arrayButtons = [NSMutableArray arrayWithArray:array];
    }

    
    
    //  Добавление текст вью и подписка делегата
    self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
    self.textView.autoresizingMask = 111111;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:17.f];
    [self.view addSubview:self.textView];
    
    
    
    //  Добавляем плейсхолдер
    CGRect rect = CGRectMake(CGRectGetMinX(self.navigationController.navigationBar.frame) + 5, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.textView.frame.size.width, 40);
    self.placeholder = [[UITextField alloc] initWithFrame:rect];
    self.placeholder.backgroundColor = [UIColor clearColor];
    self.placeholder.placeholder = @"Написать сообщение";
    self.placeholder.userInteractionEnabled = NO;
    self.placeholder.alpha = 0.f;
    [self.view addSubview:self.placeholder];
    
    
    
    //  Добавление кнопок
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Отменить"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(cancelButton)];
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(doneButton)];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    
    //  Устанавливаем тайтл
    self.navigationItem.title = @"Новая запись";
    
    
    
    //  Подписка на нотификации при показе и скрытии клавиатуры
    NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFrameTextView:) name:UIKeyboardWillShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(updateFrameTextView:) name:UIKeyboardWillHideNotification object:nil];
}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //  Обнуление массивов показанных/скрытых кнопок
    [self.showsButtons removeAllObjects];
    [self.hidesButtons removeAllObjects];
    
    
    //  Заполнение массивов показанных/скрытых кнопок в зависимости от свойств
    for (NSMutableDictionary * button in self.arrayButtons) {
        
        BOOL isOn = [[button objectForKey:@"buttonOn"] boolValue];
        
        if (isOn) {
            [self.showsButtons addObject:button];
        } else {
            [self.hidesButtons addObject:button];
        }
    }
    
    
    if (self.hidesButtons.count == 0) {
        NSLog(@"Убрать кнопку");
    }
    
    //  Добавление тулбара
    UIToolbar * toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    
    
    //  Создаем кнопки
    UIBarButtonItem * flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    
    //  Обнуляем массив кастомных
    [self.toolbarItemsCustom removeAllObjects];
    
    
    //  Перебираем коллекции показываемых кнопок
    for (NSMutableDictionary * button in self.showsButtons) {
        [self.toolbarItemsCustom addObject:flexible];
        
        //  Создаем кнопку из коллекции
        UIBarButtonItem * buttonItem = [self createBarButtonItemWithDictionary:button];
        
        [self.toolbarItemsCustom addObject:buttonItem];
        [self.toolbarItemsCustom addObject:flexible];
    }
    
    
    //  Устанавливаем массив кнопок тулбара
    [toolbar setItems:self.toolbarItemsCustom animated:NO];
    
    
    //  "Крепим" тулбар к текст вью
    self.textView.inputAccessoryView = toolbar;
}




- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //  Установка каретки в текстовое поле
    [self.textView becomeFirstResponder];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //  Перед закрытием вью контроллера сохраняем текущие настройки кнопок в память
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:self.arrayButtons forKey:@"buttons"];
}


//  Создание кнопок
- (void) createButtonsDictionary {
    //  Кнопка рекламы
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeAds name:@"Реклама" switchOn:NO selected:NO];
    
    //  Кнопка скрепки
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeClip name:@"Вложения" switchOn:NO selected:NO];
    
    //  Кнопка контакт
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeContact name:@"Контакт" switchOn:NO selected:NO];
    
    //  Кнопка фото
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePhoto name:@"Фото" switchOn:NO selected:NO];
    
    //  Кнопка геолакации
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePlace name:@"Геолокация" switchOn:NO selected:NO];
    
    //  Кнопка опроса poll
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePoll name:@"Опрос" switchOn:NO selected:NO];
    
    //  Кнопка асшарить в друггие свои групып
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeShare name:@"Поделиться" switchOn:NO selected:NO];
    
    //  Кнопка от имени сообщества
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeSigned name:@"Подпись пользователя" switchOn:NO selected:NO];
    
    //  Кнопка таймера
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeTimer name:@"Отложенная запись" switchOn:NO selected:NO];
    
    //  Кнопка остального
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeOther name:@"Остальное" switchOn:YES selected:NO];
    
    //  Кнопка настроек
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeSettings name:@"Настройки" switchOn:YES selected:NO];
}



//  Создание коллекции ключ/значение со свойствами кнопки
- (void) creareDictionaryButtonWithType:(VKToolbarButtonType)type name:(NSString *)name switchOn:(BOOL)flagOn selected:(BOOL)flagSelected {
    NSNumber * numType = [[NSNumber alloc] initWithInteger:type];
    NSNumber * numOn = [[NSNumber alloc] initWithBool:flagOn];
    NSNumber * numSel = [[NSNumber alloc] initWithBool:flagSelected];
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:name, @"buttonName",
                                        numType, @"buttonType",
                                        numOn, @"buttonOn",
                                        numSel, @"buttonSelected", nil];
    
    //  Добавление в массив кнопок
    [self.arrayButtons addObject:dictionary];
}



//  Создание кнопки из коллекции
- (UIBarButtonItem *) createBarButtonItemWithDictionary:(NSDictionary *)dict {
    
    //  По типу кнопки присваиваем картинку
    VKToolbarButtonType type = (VKToolbarButtonType)[[dict objectForKey:@"buttonType"] integerValue];
    UIImage * imButton = [[VKHelpFunction alloc] imageWithButtonType:type];
    
    
    //  Создаем кнопку
    UIBarButtonItem * button = [[UIBarButtonItem alloc] init];
    
    
    //  В зависимости от типа кнопки настраиваем ее
    switch (type) {
        case VKToolbarButtonTypeAds:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBarSelected:)];
            if (self.flagAds) {
                button.tintColor = [UIColor orangeColor];
            }
            
            button.tag = VKToolbarButtonTypeAds;
            //
            break;
            
            
        case VKToolbarButtonTypeClip:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            button.tag = VKToolbarButtonTypeClip;
            //
            break;
            
            
        case VKToolbarButtonTypeContact:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            button.tag = VKToolbarButtonTypeContact;
            //
            break;
            
            
        case VKToolbarButtonTypePhoto:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            button.tag = VKToolbarButtonTypePhoto;
            //
            break;
            
            
        case VKToolbarButtonTypePlace:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            button.tag = VKToolbarButtonTypePlace;
            //
            break;
            
        case VKToolbarButtonTypePoll:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            button.tag = VKToolbarButtonTypePoll;
            //
            break;
            
            
        case VKToolbarButtonTypeShare:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBarSharedToGroups)];
            button.tag = VKToolbarButtonTypeShare;
            
            
            if (self.sharedGroups.count > 1) {
                button.tintColor = [UIColor orangeColor];
            }
            //
            break;
            
            
        case VKToolbarButtonTypeSigned:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBarSelected:)];
            if (self.flagSigned) {
                button.tintColor = [UIColor orangeColor];
            }
            button.tag = VKToolbarButtonTypeSigned;
            //
            break;
            
            
        case VKToolbarButtonTypeTimer:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolbarPostponed)];
            button.tag = VKToolbarButtonTypeTimer;
            if (self.postponedInterval > 0) {
                button.tintColor = [UIColor orangeColor];
            }
            
            //
            break;
            
        case VKToolbarButtonTypeOther:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolbarOthers)];
            button.tag = VKToolbarButtonTypeOther;
            //
            break;
            
            
        case VKToolbarButtonTypeSettings:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolbarSettings)];
            button.tag = VKToolbarButtonTypeSettings;
            //
            break;
            
        default:
            break;
    }
    
    return button;
}



//  Реализация нажатия на кнопки, пока что заглушка
- (void) toolBar2:(id)sender {
    
    UIViewController * vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor purpleColor];
    UILabel * label = [[UILabel alloc] initWithFrame:vc.view.frame];
    
    
    UIBarButtonItem * button = [[UIBarButtonItem alloc] init];
    NSString * text = @"Text";
    
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        button = (UIBarButtonItem *)sender;
        
        if (button.tag == VKToolbarButtonTypeClip) {
            text = @"Прикрепить";
        } else if (button.tag == VKToolbarButtonTypePoll) {
            text = @"Опрос";
        } else if (button.tag == VKToolbarButtonTypePhoto) {
            text = @"Фото";
        } else if (button.tag == VKToolbarButtonTypePlace) {
            text = @"Местоположение";
        } else if (button.tag == VKToolbarButtonTypeContact) {
            text = @"Контакты";
        }
    } else {
        NSLog(@"");
    }
    
    
    
    
    label.text = text;
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:60.f];
    [vc.view addSubview:label];
    
    [self presentViewController:vc animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        });
    }];
}


//  Реализация нажатия на кнопку поделиться в группы
- (void) toolBarSharedToGroups {
    
    //  Создаем таблицу групп в которые можно шарить
    VKSharedGroupsTableViewController * vc = [[VKSharedGroupsTableViewController alloc] initWithCompletionBlock:^(NSArray *groups) {
        
        //  Реализация блока
        //  Если пришел массив групп
        if (groups) {
            
            //  Обнуляем массив групп
            [self.sharedGroups removeAllObjects];
            
            //  И каджую добавляем из пришедших
            for (VKGroup * group in groups) {
                [self.sharedGroups addObject:group];
            }
        }
    }];
    
    //  Устанавливаем такущую группу
    vc.currentGroup = self.group;
    
    //  Передаем информацию об уже шаренных группах
    vc.arraySharedGroups = [NSMutableArray arrayWithArray:self.sharedGroups];
    
    //  Создаем навигейшн с рутом
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //  Презентуем контроллер
    [self presentViewController:navc animated:YES completion:^{
    }];
}



//  Изменение цвета кнопки в зависимости от активности
- (void) toolBarSelected:(UIBarButtonItem *)sender {
    
    BOOL selected = NO;
    
    //  Если кнопка рекламы
    if (sender.tag == VKToolbarButtonTypeAds) {
        
        self.flagAds = !self.flagAds;
        selected = self.flagAds;
        
    //  Если кнопка подписи
    } else if (sender.tag == VKToolbarButtonTypeSigned  ) {
        
        self.flagSigned = !self.flagSigned;
        selected = self.flagSigned;
        
    }
    
    
    //  Если включена - оранжевый, если нет  то серый
    if (selected) {
        sender.tintColor = [UIColor orangeColor];
    } else {
        sender.tintColor = [UIColor colorWithRed:26.f/255.f green:135.f/255.f blue:254.f/255.f alpha:1.f];
    }
}


//  Реализация нажатия кнопки настроек
- (void) toolbarSettings {
    //  Берем стриборд
    UIStoryboard *  storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //  Из сториборда грузим таблицу настройки кнопок
    VKToolbarSettingsTableViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"ToolbarSettings"];
    //  Передаем информацию о состоянии кнопок
    vc.arrayButtons = self.arrayButtons;
    
    //  Навигейшн на основе таблицы
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //  Презентация навигейшна
    [self presentViewController:navController animated:YES completion:nil];
}



//  Реализация нажатия кнопки скрытых кнопок
- (void) toolbarOthers {
    
    //  Создаем алерт контроллер
    UIAlertController * controller = [[UIAlertController alloc] init];
    
    //  Для каждой скрытой кнопки  создаем экшн
    for (NSMutableDictionary * button in self.hidesButtons) {
        NSString * title = [button objectForKey:@"buttonName"];
        VKToolbarButtonType type = [[button objectForKey:@"buttonType"] intValue];
        
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        
        
        //  Для тек кнопок что есть включенные флаги другой стайл
        if ([title isEqualToString:@"Реклама"] & self.flagAds) {
            style = UIAlertActionStyleDestructive;
        } else if ([title isEqualToString:@"Подпись пользователя"] & self.flagSigned) {
            style = UIAlertActionStyleDestructive;
        } else if ([title isEqualToString:@"Поделиться"] & (self.sharedGroups.count > 1)) {
            style = UIAlertActionStyleDestructive;
        } else if ([title isEqualToString:@"Отложенная запись"] & (self.postponedInterval > 0)) {
            style = UIAlertActionStyleDestructive;
        }
        
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:title
                                                          style:style
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self actionWithToolbarType:type];
                                                        }];
        [controller addAction:action];
    }
    
    //  Кнопка закрытия
    UIAlertAction * close = [UIAlertAction actionWithTitle:@"Отмена"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                   }];
    [controller addAction:close];
    
    //  Презентация алерта
    [self presentViewController:controller animated:YES completion:^{
    }];
}


//  Реализация нажатия кнопки отложенная запись
- (void) toolbarPostponed {
    
    //  Создаем вью контроллер на основе контроллера из сториборда
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VKPostponedViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"VKPostponedViewController"];
    
    //  Устанавливаем родительским контроллером тот откуда вызван метод
    vc.parentVC = self;
    
    //  Навигейшн на основе вью
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //  Презентация
    [self presentViewController:nav animated:YES completion:^{
    }];
}



//  Метод вызывает метод реализации нажатия в зависисмости от типа кнопки
- (void) actionWithToolbarType:(VKToolbarButtonType)type {
    
    switch (type) {
        case VKToolbarButtonTypeAds:
            //code
            self.flagAds = !self.flagAds;
            //
            break;
            
            
        case VKToolbarButtonTypeClip:
            //code
            [self toolBar2:nil];
            //
            break;
            
            
        case VKToolbarButtonTypeContact:
            //code
            [self toolBar2:nil];
            //
            break;
            
            
        case VKToolbarButtonTypePhoto:
            //code
            [self toolBar2:nil];
            //
            break;
            
            
        case VKToolbarButtonTypePlace:
            //code
            [self toolBar2:nil];
            //
            break;
            
        case VKToolbarButtonTypePoll:
            //code
            [self toolBar2:nil];
            //
            break;
            
            
        case VKToolbarButtonTypeShare:
            //code
            [self toolBarSharedToGroups];
            //
            break;
            
            
        case VKToolbarButtonTypeSigned:
            //code
            self.flagSigned = !self.flagSigned;
            //
            break;
            
            
        case VKToolbarButtonTypeTimer:
            //code
            [self toolbarPostponed];
            //
            break;
            
        default:
            break;
    }
}


//  Кнопка отмена
- (void) cancelButton {
    
    //  Если текста есть в текстовом поле - алерт с предупреждением, если нет то закрыть просто
    if (self.textView.text.length > 0) {
        [self allertClosePost];
    } else {
        [self dismissNewPostView];
    }
}




//  Метод скрывающий окно нового сообщения
- (void) dismissNewPostView {
    
    //  Если есть реализация блока то передаем тип передаваемого сообщения
    if (self.completionBlock) {
        self.completionBlock(nil, self.postType);
    }
    
    
    //  Закрываем клавиатуру, скрываем вью
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


//  Установка блока
- (void) sendPost:(VKSendMessageBlock)success {
    self.completionBlock = success;
}


//  Кнопка готово
- (void) doneButton {
    
    //  Сегодняшняя дата в формате интервала
    NSDate * date = [NSDate date];
    NSTimeInterval currentInterwal = [date timeIntervalSince1970];
    
    //  Если интевал отложенного сообщения меньше нынешнего интервала
    if (self.postponedInterval > 0 & self.postponedInterval < currentInterwal) {
        //  НЕКОРРЕКТНАЯ ДАТА
        
        //  Показываем алерт с сообщением о некорректрой дате
        UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"Некорректная дата" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:controller animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    [self toolbarPostponed];
                }];
            });
        }];
        
        
    //  Если интервал отложенного больше интервала нынешнего
    } else if (self.postponedInterval > 0 & self.postponedInterval > currentInterwal) {
        //  ОТЛОЖЕННАЯ ЗАПИСЬ
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.postType = VKPostTypePostponed;
        
        //  Отправляем сообщение для каждой из отмеченных групп
        for (VKGroup * group in self.sharedGroups) {
            [self sendPostWithGroupID:group.groupID postponed:YES];
        }
        
    
    //  Иначе отправка прямо сейчас
    } else {
        //  ОБЫЧНАЯ ДАТА
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.postType = VKPostTypePublished;
        
        //  Отправляем сообщение для каждой из отмеченных групп
        for (VKGroup * group in self.sharedGroups) {
            [self sendPostWithGroupID:group.groupID postponed:NO];
        }
    }
    
    

}



//  Отправка сообщения для определенной группы отложенное или нет
- (void) sendPostWithGroupID:(NSString *)groupID postponed:(BOOL)postponedFlag {
    
    //  Определяем флаги
    NSInteger flAds = self.flagAds;
    NSInteger flSig = self.flagSigned;
    
    
    //  Отправка сообщения
    [[VKRequestManager sharedManager] postWallMessageWithOwnerID:groupID
                                                         message:self.textView.text
                                                     publishDate:self.postponedInterval
                                                             ads:flAds
                                                          signed:flSig
                                                       onSuccess:^(id successesMessage) {
                                                           
                                                           self.response = successesMessage;
                                                           
                                                           self.textView.frame = self.view.frame;
                                                           
                                                           //   Закрываем клавиатуру
                                                           [self.view endEditing:YES];
                                                           
                                                           //   Алерт что  сообщение отправлено
                                                           if (!postponedFlag) {
                                                               [self alertSheetWithTitle:@"Сообщение опубликовано" message:@""];
                                                           } else {
                                                               NSDate * datePostponed = [NSDate dateWithTimeIntervalSince1970:self.postponedInterval];
                                                               NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                                                               [formatter setDateFormat:@"dd MMMM yyyy HH:mm"];
                                                               NSString * message = [NSString stringWithFormat:@"будет опубликовано: %@", [formatter stringFromDate:datePostponed]];
                                                               [self alertSheetWithTitle:@"Отложенная запись" message:message];
                                                           }
                                                           
                                                       }
                                                       onFailure:^(NSError *error) {
                                                           self.response = error;
                                                           
                                                           //   Показываем алерт с ошибкой
                                                           [self alertSheetWithTitle:@"Ошибка" message:error.description];
                                                       }];
    
}



//  Измененние текста
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //  Просчитываем строку перед изменением
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    //  Если строка содержит хоть один символ то скрываем плейсхолдер и включаем кнопку
    if (newString.length > 0) {
        
        [UIView animateWithDuration:.2 animations:^{
            self.placeholder.alpha = 0.f;
        }];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    
    //  Иначе показываем плейсхолдер и отключаем кнопку
    } else {
        [UIView animateWithDuration:.2 animations:^{
            self.placeholder.alpha = 1.f;
        }];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return YES;
}



//  Метод показывает алерт
- (void) alertSheetWithTitle:(NSString *)title message:(NSString *)message {
    
    //  Создаем алерт контроллер на основе переданных данных
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    //  Показываем контроллер
    [self presentViewController:controller
                       animated:YES
                     completion:^{
                         
        //  Таймер до закрытия алерта
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //  Закрываем алерт
            [self dismissViewControllerAnimated:YES completion:^{
                
                //  Закрываем нью пост вью и передаем ответ от переданного сообщения и тип поста
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.completionBlock) {
                        self.completionBlock(self.response, self.postType);
                    }
                }];
            }];
        });
    }];
}




//  Изменение размера текстового поля в зависимости от нотификаций
- (void) updateFrameTextView:(NSNotification *)notification {
    
    //  Из нотификации вытаскиваем информацию
    NSDictionary * notificationInfo = notification.userInfo;
    
    //  На основе информации из нотификации создаем рект
    CGRect newRect = [[notificationInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];

    //  Новый рект для плейсхолдера
    CGRect rect = CGRectMake(CGRectGetMinX(self.navigationController.navigationBar.frame) + 5, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.textView.frame.size.width, 40);
    self.placeholder.frame = rect;
    
    //  Если текста в текстовом поле нет, тогда показываем плейсхолдер
    if (!(self.textView.text.length > 0)) {
        self.placeholder.alpha = 1.f;
    }
    
    
    //  Если нотификация о том что клавиатура будет показана
    if ([notification.name isEqualToString: UIKeyboardWillHideNotification]) {
        
    //  Если нотификация о том что клавиатура будет скрыта
    } else if ([notification.name isEqualToString: UIKeyboardWillShowNotification]) {
        
        //  Устанавливаем новый рект для текстового поля и скролл индикатора
        self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, newRect.origin.y);
        self.textView.scrollIndicatorInsets = self.textView.contentInset;
    }
}




//  Алерт закрытия поста с подтверждением
- (void) allertClosePost {
    
    //  Создаем алерт контроллер
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //  И экшены
    UIAlertAction * dontSaveButton = [UIAlertAction actionWithTitle:@"Не сохранять" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissNewPostView];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [controller addAction:dontSaveButton];
    [controller addAction:cancel];
    
    //  Показываем алерт
    [self presentViewController:controller animated:YES completion:^{
    }];
}


@end
