//
//  AGViewController.m
//  Test
//
//  Created by Arkadiy Grigoryanc on 19.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "AGViewController.h"

@interface AGViewController () <UIResponderStandardEditActions>

@property (weak, nonatomic) IBOutlet UIView *resultContainerView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) UITextField *numberField;

@property (assign, nonatomic) NSInteger count;

@property (assign, nonatomic) NSInteger currentValue;

@end

@implementation AGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // set counter value
    NSDictionary *setting = [self unarchiveSetting];
    _count = [[setting objectForKey:@"counter"] integerValue];
    if (_count != 0) {
        _counterLabel.text = [NSString stringWithFormat:@"%ld", _count];
    }
    
    // add numberField
    UITextField *numberField = [self createNumberField];
    _numberField = numberField;
    [self.view addSubview:numberField];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIResponderStandardEditActions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    return [super canPerformAction:action withSender:sender];
}

#pragma mark - Archiving

- (NSDictionary *)unarchiveSetting {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
    NSDictionary *setting = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return setting;
}

- (void)archiveSetting:(NSDictionary *)dict {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
    
    if (![dict writeToFile:path atomically:YES]) {
        NSLog(@"Ошибка записи");
    }
}

#pragma mark - Methods

- (UITextField *)createNumberField {
    
    CGFloat space = 8;
    UITextField *textField = [[UITextField alloc] initWithFrame:
                              CGRectMake(CGRectGetMinX(_resultContainerView.frame),
                                         CGRectGetMaxY(_resultContainerView.frame) + space,
                                         CGRectGetWidth(self.view.frame) / 2 - space * 2 - space / 2,
                                         40)];
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textAlignment = NSTextAlignmentRight;
    textField.placeholder = @"Введите число";
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.inputAccessoryView = [self toolbar];
    
    return textField;
}

- (UIToolbar *)toolbar {
    
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithTitle:@"+"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(actionPlusSymbol:)];
    
    UIToolbar *extraRow = [[UIToolbar alloc] init];
    extraRow.barStyle = UIBarStyleDefault;
    extraRow.tintColor = [UIColor blackColor];
    [extraRow sizeToFit];
    NSArray *buttons = @[plusButton];
    [extraRow setItems:buttons animated:YES];
    
    return extraRow;
}

#pragma mark - Actions

- (void)actionPlusSymbol:(id)sender {
    
    NSString *plusSymbol = @"+";
    
    if (![_numberField.text isEqualToString:@""] && ![_numberField.text hasSuffix:plusSymbol]) {
        
        if ([_numberField.text containsString:plusSymbol]) {
            NSInteger result = [self actionAdd];
            _numberField.text = [NSString stringWithFormat:@"%ld", result];
        }
        
        _numberField.text = [_numberField.text stringByAppendingString:plusSymbol];
    }
}

- (NSInteger)actionAdd {
    
    NSRange range = [_numberField.text rangeOfString:@"+"];
    
    NSInteger firstNumber = [[_numberField.text substringToIndex:range.location] integerValue];
    NSInteger secondNumber = [[_numberField.text substringFromIndex:range.location] integerValue];
    
    return firstNumber + secondNumber;
}

- (IBAction)actionCalculate:(id)sender {
    
    if ([_numberField.text hasSuffix:@"+"]) {
        NSRange range = [_numberField.text rangeOfString:@"+"];
        _numberField.text = [_numberField.text substringToIndex:range.location];
    } else if ([_numberField.text containsString:@"+"]) {
        NSInteger result = [self actionAdd];
        _numberField.text = [NSString stringWithFormat:@"%ld", result];
    }
    
    NSInteger number = [_numberField.text integerValue];
    if (number == _currentValue) {
        return;
    }
    _currentValue = number;
    
    NSInteger result = number * number;
    _resultLabel.text = [NSString stringWithFormat:@"%ld", result];
    
    _count++;
    _counterLabel.text = [NSString stringWithFormat:@"%ld", _count];
    
    NSDictionary *setting = @{@"counter" : @(_count)};
    [self archiveSetting:setting];
}

- (IBAction)actionReset:(id)sender {
    
    _count = 0;
    _currentValue = 0;
    _counterLabel.text = @"#";
    _resultLabel.text = @"результат";
    _numberField.text = @"";
    
    NSDictionary *setting = @{@"counter" : @0};
    [self archiveSetting:setting];
}

@end
