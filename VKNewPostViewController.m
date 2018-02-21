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

@interface VKNewPostViewController () <UITextViewDelegate>

@property (nonatomic, strong) VKSendMessageBlock completionBlock;
@property (nonatomic, strong) id response;

@property (nonatomic, strong) UITextField * placeholder;

@property (nonatomic, strong) NSMutableArray * arrayButtons;
@property (nonatomic, strong) NSMutableArray * showsButtons;
@property (nonatomic, strong) NSMutableArray * hidesButtons;

@property (nonatomic, strong) NSMutableArray * toolbarItemsCustom;
                       
@end

@implementation VKNewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    //инициализация массива
    self.showsButtons = [[NSMutableArray alloc] init];
    self.hidesButtons = [[NSMutableArray alloc] init];
    self.toolbarItemsCustom = [[NSMutableArray alloc] init];
    
    
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


- (void) createButtonsDictionary {
    
    //кнопка рекламы
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeAds name:@"Реклама" switchOn:NO];
    
    
    //кнопка скрепки
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeClip name:@"Вложения" switchOn:NO];
        
    
    //кнопка контакта
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeContact name:@"Контакт" switchOn:NO];
    
    
    //кнопка фото
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePhoto name:@"Фото" switchOn:NO];
        
    
    //кнопка геолакации
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePlace name:@"Геолокация" switchOn:NO];
    
        
    //кнопка опроса poll
    [self creareDictionaryButtonWithType:VKToolbarButtonTypePoll name:@"Опрос" switchOn:NO];
        
        
    //кнопка асшарить в друггие свои групып
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeShare name:@"Поделиться" switchOn:NO];
    
        
    //кнопка от имени сообщества
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeSigned name:@"От имени сообщества" switchOn:NO];
        
        
    //кнопка таймера
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeTimer name:@"Отложенная запись" switchOn:NO];
    
    
    //кнопка остального
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeOther name:@"Остальное" switchOn:YES];
    
    
    //кнопка настроек
    [self creareDictionaryButtonWithType:VKToolbarButtonTypeSettings name:@"Настройки" switchOn:YES];

}


- (void) creareDictionaryButtonWithType:(VKToolbarButtonType)type name:(NSString *)name switchOn:(BOOL)flagOn {
    NSNumber * numType = [[NSNumber alloc] initWithInteger:type];
    NSNumber * numOn = [[NSNumber alloc] initWithBool:flagOn];
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:name, @"buttonName",
                                        numType, @"buttonType",
                                        numOn, @"buttonOn", nil];
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
                                                     action:@selector(toolBar2:)];
            //
            break;
            
            
        case VKToolbarButtonTypeClip:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            //
            break;
            
            
        case VKToolbarButtonTypeContact:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            //
            break;
            
            
        case VKToolbarButtonTypePhoto:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            //
            break;
            
            
        case VKToolbarButtonTypePlace:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            //
            break;
            
        case VKToolbarButtonTypePoll:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            //
            break;
            
            
        case VKToolbarButtonTypeShare:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            //
            break;
            
            
        case VKToolbarButtonTypeSigned:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            //
            break;
            
            
        case VKToolbarButtonTypeTimer:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolBar2:)];
            //
            break;
            
        case VKToolbarButtonTypeOther:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolbarOthers)];
            //
            break;
            
            
        case VKToolbarButtonTypeSettings:
            //code
            button = [[UIBarButtonItem alloc] initWithImage:imButton
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toolbarSettings)];
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
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:title
                                                          style:UIAlertActionStyleDefault
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
            [self toolBar2:nil];
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
            [self toolBar2:nil];
            //
            break;
            
            
        case VKToolbarButtonTypeSigned:
            //code
            [self toolBar2:nil];
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
    [[VKRequestManager sharedManager] postWallMessageWithOwnerID:self.group.groupID
                                                         message:self.textView.text
                                                     publishDate:0
                                                       onSuccess:^(id successesMessage) {
                                                           
                                                           self.response = successesMessage;
                                                           
                                                           
                                                           self.textView.frame = self.view.frame;
                                                           //закрыть клавиатуру
                                                           [self.view endEditing:YES];
                                                           //алерт что  сообщение отправлено
                                                           [self alertSheetWithTitle:@"Сообщение опубликовано" message:@""];
                                                           
                                                       } onFailure:^(NSError *error) {
                                                           
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
