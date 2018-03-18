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


@interface VKNewPostViewController () <UITextViewDelegate>

@property (nonatomic, strong) VKSendMessageBlock completionBlock;
@property (nonatomic, strong) id response;

@property (nonatomic, strong) UITextField * placeholder;

@property (nonatomic, strong) NSMutableArray * arrayButtons;
@property (nonatomic, strong) NSMutableArray * showsButtons;
@property (nonatomic, strong) NSMutableArray * hidesButtons;

@property (nonatomic, strong) NSMutableArray * toolbarItemsCustom;


@property (nonatomic, strong) NSMutableArray * sharedGroups;


@property (nonatomic, assign) BOOL flagAds;
@property (nonatomic, assign) BOOL flagSigned;
                       
@end

@implementation VKNewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    

    //инициализация массива
    self.sharedGroups = [[NSMutableArray alloc] initWithObjects:self.group, nil];;
    
    self.showsButtons = [[NSMutableArray alloc] init];
    self.hidesButtons = [[NSMutableArray alloc] init];
    self.toolbarItemsCustom = [[NSMutableArray alloc] init];
    
    
    self.flagAds = NO;
    self.flagSigned = NO;
    
    
    //проверяем на настроенные кнопки
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSArray * buttons = [settings objectForKey:@"buttons"];
    
    //удаляем кнопки
    //[settings removeObjectForKey:@"buttons"];
    
    //если кнопок нет то
    if (!buttons) {
        //создаем кнопки
        self.arrayButtons = [[NSMutableArray alloc] init];
        [self createButtonsDictionary];
        
    //или загружаем те что есть
    } else {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        for (int i = 0; i < buttons.count; i++) {
            NSMutableDictionary * mDict = [[NSMutableDictionary alloc] initWithDictionary:[buttons objectAtIndex:i]];
            [array addObject:mDict];
        }
        
        self.arrayButtons = [NSMutableArray arrayWithArray:array];
    }

    
    //добавление текст вью
    self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
    self.textView.autoresizingMask = 111111;
    self.textView.delegate = self;
    
    //self.textView
    
    self.textView.font = [UIFont systemFontOfSize:17.f];
    
    [self.view addSubview:self.textView];
    
    
    
    //добавляем плейсхолдер
    CGRect rect = CGRectMake(CGRectGetMinX(self.navigationController.navigationBar.frame) + 5, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.textView.frame.size.width, 40);
    self.placeholder = [[UITextField alloc] initWithFrame:rect];
    self.placeholder.backgroundColor = [UIColor clearColor];
    self.placeholder.placeholder = @"Написать сообщение";
    self.placeholder.userInteractionEnabled = NO;
    self.placeholder.alpha = 0.f;
    [self.view addSubview:self.placeholder];
    
    
    
    
    //добавление кнопок
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
    
    
    //добавление тайтла
    self.navigationItem.title = @"Новая запись";
    
    
    
    //подписка на нотификации при показе и скрытии клавиатуры
    NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateFrameTextView:) name:UIKeyboardWillShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(updateFrameTextView:) name:UIKeyboardWillHideNotification object:nil];
        
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.showsButtons removeAllObjects];
    [self.hidesButtons removeAllObjects];
    
    for (NSMutableDictionary * button in self.arrayButtons) {
        
        BOOL isOn = [[button objectForKey:@"buttonOn"] boolValue];
        
        if (isOn) {
            [self.showsButtons addObject:button];
        } else {
            [self.hidesButtons addObject:button];
        }
    }
    
    
    //добавление тулбара
    UIToolbar * toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    //создаем кнопки
    UIBarButtonItem * flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [self.toolbarItemsCustom removeAllObjects];
    
    for (NSMutableDictionary * button in self.showsButtons) {
        [self.toolbarItemsCustom addObject:flexible];
        UIBarButtonItem * buttonItem = [self createBarButtonItemWithDictionary:button];
        
//        BOOL flagSel = [button objectForKey:@"buttonSelected"];
//        if (!flagSel) {
//            buttonItem.tintColor = [UIColor cyanColor];
//        } else {
//            buttonItem.tintColor = [UIColor orangeColor];
//        }
        
        [self.toolbarItemsCustom addObject:buttonItem];
        [self.toolbarItemsCustom addObject:flexible];
    }
    
    [toolbar setItems:self.toolbarItemsCustom animated:NO];
    
    self.textView.inputAccessoryView = toolbar;
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:self.arrayButtons forKey:@"buttons"];
}


- (void) createButtonsDictionary {
    
    //кнопка рекламы
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeAds name:@"Реклама" switchOn:NO selected:NO];
    
    
    //кнопка скрепки
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeClip name:@"Вложения" switchOn:NO selected:NO];
        
    
    //кнопка контакт
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeContact name:@"Контакт" switchOn:NO selected:NO];
    
    
    //кнопка фото
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePhoto name:@"Фото" switchOn:NO selected:NO];
        
    
    //кнопка геолакации
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePlace name:@"Геолокация" switchOn:NO selected:NO];
    
        
    //кнопка опроса poll
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePoll name:@"Опрос" switchOn:NO selected:NO];
        
        
    //кнопка асшарить в друггие свои групып
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeShare name:@"Поделиться" switchOn:NO selected:NO];
    
        
    //кнопка от имени сообщества
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeSigned name:@"Подпись пользователя" switchOn:NO selected:NO];
        
        
    //кнопка таймера
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeTimer name:@"Отложенная запись" switchOn:NO selected:NO];
    
    
    //кнопка остального
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeOther name:@"Остальное" switchOn:YES selected:NO];
    
    
    //кнопка настроек
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeSettings name:@"Настройки" switchOn:YES selected:NO];

}


- (void) creareDictionaryButtonWithType:(VKToolbarButtonType)type name:(NSString *)name switchOn:(BOOL)flagOn selected:(BOOL)flagSelected {
    NSNumber * numType = [[NSNumber alloc] initWithInteger:type];
    NSNumber * numOn = [[NSNumber alloc] initWithBool:flagOn];
    NSNumber * numSel = [[NSNumber alloc] initWithBool:flagSelected];
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:name, @"buttonName",
                                        numType, @"buttonType",
                                        numOn, @"buttonOn",
                                        numSel, @"buttonSelected", nil];
    [self.arrayButtons addObject:dictionary];
}


- (UIBarButtonItem *) createBarButtonItemWithDictionary:(NSDictionary *)dict {
    
    VKToolbarButtonType type = (VKToolbarButtonType)[[dict objectForKey:@"buttonType"] integerValue];
    UIImage * imButton = [[VKHelpFunction alloc] imageWithButtonType:type];
    
    UIBarButtonItem * button = [[UIBarButtonItem alloc] init];
    
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
                                                     action:@selector(toolBar2:)];
            button.tag = VKToolbarButtonTypeTimer;
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




- (void) toolBar2:(UIBarButtonItem *)sender {
    NSLog(@"SENDER - %@", sender);
    NSLog(@"toolBar2");
    
    UIViewController * vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor purpleColor];
    UILabel * label = [[UILabel alloc] initWithFrame:vc.view.frame];
    label.text = @"Text";
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


- (void) toolBarSharedToGroups {
    
    VKSharedGroupsTableViewController * vc = [[VKSharedGroupsTableViewController alloc] initWithCompletionBlock:^(NSArray *groups) {
        
        if (groups) {
            [self.sharedGroups removeAllObjects];
            
            for (VKGroup * group in groups) {
                [self.sharedGroups addObject:group];
            }
        }
    }];
    
    vc.currentGroup = self.group;
    vc.arraySharedGroups = [NSMutableArray arrayWithArray:self.sharedGroups];
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //vc.view.backgroundColor = [UIColor brownColor];
    [self presentViewController:navc animated:YES completion:^{

    }];
}


- (void) toolBarSelected:(UIBarButtonItem *)sender {
    NSLog(@"Меняем цвет кнопки");
    //определить кнопку реклама или от сообщества
    
    BOOL selected = NO;
    
    if (sender.tag == VKToolbarButtonTypeAds) {
        
        self.flagAds = !self.flagAds;
        selected = self.flagAds;
        NSLog(@"ADS %d", self.flagAds);
        
        
    } else if (sender.tag == VKToolbarButtonTypeSigned  ) {
        
        
        self.flagSigned = !self.flagSigned;
        selected = self.flagSigned;
        NSLog(@"SIGNED %d", self.flagSigned);
        
        
    }
    
    
    if (selected) {
        sender.tintColor = [UIColor orangeColor];
    } else {
        sender.tintColor = [UIColor colorWithRed:26.f/255.f green:135.f/255.f blue:254.f/255.f alpha:1.f];
    }
    
    
    
}


- (void) toolbarSettings {
    NSLog(@"Настройки");
    UIStoryboard *  storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    VKToolbarSettingsTableViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"ToolbarSettings"];
    vc.arrayButtons = self.arrayButtons;
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navController animated:YES completion:nil];
}


- (void) toolbarOthers {
    UIAlertController * controller = [[UIAlertController alloc] init];
    for (NSMutableDictionary * button in self.hidesButtons) {
        NSString * title = [button objectForKey:@"buttonName"];
        VKToolbarButtonType type = [[button objectForKey:@"buttonType"] intValue];
        
        
        
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        
        if ([title isEqualToString:@"Реклама"] & self.flagAds) {
            style = UIAlertActionStyleDestructive;
        } else if ([title isEqualToString:@"Подпись пользователя"] & self.flagSigned) {
            style = UIAlertActionStyleDestructive;
        }
        
        
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:title
                                                          style:style
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self actionWithToolbarType:type];
                                                        }];
        [controller addAction:action];
    }
    
    UIAlertAction * close = [UIAlertAction actionWithTitle:@"Отмена"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                   }];
    [controller addAction:close];
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}


- (void) actionWithToolbarType:(VKToolbarButtonType)type {
    
    switch (type) {
        case VKToolbarButtonTypeAds:
            //code
           //[self toolBarSelected:nil];
            self.flagAds = !self.flagAds;
            NSLog(@"ADS %d", self.flagAds);
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
            //[self toolBarSelected:nil];
            self.flagSigned = !self.flagSigned;
            NSLog(@"SIGNED %d", self.flagSigned);
            //
            break;
            
            
        case VKToolbarButtonTypeTimer:
            //code
            [self toolBar2:nil];
            //
            break;
            
        default:
            break;
    }
}


//кнопка отмена
- (void) cancelButton {
    if (self.textView.text.length > 0) {
        [self allertClosePost];
    } else {
        [self dismissNewPostView];
    }
}


- (void) dismissNewPostView {
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//установка блока
- (void) sendPost:(VKSendMessageBlock)success {
    self.completionBlock = success;
}


//кнопка готово
- (void) doneButton {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    
    NSLog(@"SHAR%@", self.sharedGroups);
    if (self.sharedGroups.count > 1) {
        NSLog(@"МНОГО ГРУПП");
    } else {
        NSLog(@"ОДНА ГРУППА");
    }
    
    
    for (VKGroup * group in self.sharedGroups) {
        [self sendPostWithGroupID:group.groupID];
    }

}


- (void) sendPostWithGroupID:(NSString *)groupID {
    
    NSInteger flAds = self.flagAds;
    NSInteger flSig = self.flagSigned;
    
    [[VKRequestManager sharedManager] postWallMessageWithOwnerID:groupID
                                                         message:self.textView.text
                                                     publishDate:0
                                                             ads:flAds//self.flagAds
                                                          signed:flSig//self.flagSigned
                                                       onSuccess:^(id successesMessage) {
                                                           
                                                           
                                                           
                                                           self.response = successesMessage;
                                                           
                                                           
                                                           self.textView.frame = self.view.frame;
                                                           //закрыть клавиатуру
                                                           [self.view endEditing:YES];
                                                           //алерт что  сообщение отправлено
                                                           [self alertSheetWithTitle:@"Сообщение опубликовано" message:@""];
                                                       }
                                                       onFailure:^(NSError *error) {
                                                           self.response = error;
                                                           
                                                           //показываем алерт с ошибкой
                                                           [self alertSheetWithTitle:@"Ошибка" message:error.description];
                                                       }];
    
}


//измененние текста
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (newString.length > 0) {
        
        [UIView animateWithDuration:.2 animations:^{
            self.placeholder.alpha = 0.f;
        }];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        
    } else {
        [UIView animateWithDuration:.2 animations:^{
            self.placeholder.alpha = 1.f;
        }];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return YES;
}


//алерт
- (void) alertSheetWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:controller
                       animated:YES
                     completion:^{
        //таймер по появлению алерта
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //закрываем алерт
            [self dismissViewControllerAnimated:YES completion:^{
                
                //закрываем нью пост вью
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.completionBlock) {
                        self.completionBlock(self.response);
                    }
                    
                    
                }];
            }];
        });
    }];
}


- (void) updateFrameTextView:(NSNotification *)notification {
    NSDictionary * notificationInfo = notification.userInfo;
    CGRect newRect = [[notificationInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    
    //CGRect rect = [self.view convertRect:newRect toView:self.view.window];
    

    CGRect rect = CGRectMake(CGRectGetMinX(self.navigationController.navigationBar.frame) + 5, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.textView.frame.size.width, 40);
    self.placeholder.frame = rect;
    
    
    if (!(self.textView.text.length > 0)) {
        self.placeholder.alpha = 1.f;
    }
    
    
    
    
    
    if ([notification.name isEqualToString: UIKeyboardWillHideNotification]) {
        //self.textView.contentInset = UIEdgeInsetsZero;
        //self.textView.frame = self.view.frame;
        
        
    } else if ([notification.name isEqualToString: UIKeyboardWillShowNotification]) {
        
        self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, newRect.origin.y);
        
        //self.textView.contentInset = UIEdgeInsetsMake(0, 0, rect.size.height, 0);
        self.textView.scrollIndicatorInsets = self.textView.contentInset;
        
    }
    
    

    
    
}


- (void) allertClosePost {
    
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * dontSaveButton = [UIAlertAction actionWithTitle:@"Не сохранять" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissNewPostView];
        
    }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [controller addAction:dontSaveButton];
    [controller addAction:cancel];
    
    [self presentViewController:controller animated:YES completion:^{
    }];
}


@end
