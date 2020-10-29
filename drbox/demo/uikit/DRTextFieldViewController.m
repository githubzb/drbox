//
//  DRTextFieldViewController.m
//  drbox
//
//  Created by dr.box on 2020/9/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRTextFieldViewController.h"
#import "Drbox.h"

@interface DRTextFieldViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end


@implementation DRTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.justifyContent = YGJustifyCenter;
        layout.alignItems = YGAlignCenter;
    }];
    UITextField *field = [[UITextField alloc] init];
    field.borderStyle = UITextBorderStyleLine;
    field.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:field];
    self.textField = field;
    
    [field dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.width = DRPointValue(200);
        layout.height = DRPointValue(50);
    }];
    [field dr_addTextChangedBlock:^(UITextField * _Nonnull textField) {
        NSLog(@"---changed: %@", textField.text);
    }];
    
    [field dr_addShouldReturnBlock:^BOOL(UITextField * _Nonnull textField) {
        NSLog(@"-----shouldReturnBlock");
        return YES;
    }];
    
    // 添加该方法，将会阻止delegate的对应方法的执行
    [field dr_addShouldChangeCharactersInRangeBlock:^BOOL(UITextField * _Nonnull textField, NSRange range, NSString * _Nonnull string) {
        if ([string isEqualToString:@"\n"]) {
            return YES;
        }
        NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (str.length>5) {
            return NO;
        }
        return YES;
    }];
    
    [field dr_addDidEndEditingBlock:^(UITextField * _Nonnull textField) {
        NSLog(@"didEndEditingBlock: %@", textField.text);
    }];
    
    [field dr_setDelegate:self];// 如果你不希望上面的block事件失效，请调用该方法设置delegate
//    field.delegate = self; // 这样做会导致上面添加的block回调事件失效
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"全选" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:btn];
    [btn dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.marginTop = DRPointValue(20);
        layout.width = DRPointValue(50);
        layout.height = DRPointValue(35);
    }];
    
    [btn dr_setActionBlock:^(id  _Nonnull sender) {
        [field becomeFirstResponder];
        [field dr_selectAllText];
    } forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.view dr_displayLayout];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"delegate textFieldDidEndEditing:%@", textField.text);
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (str.length>11) {
        return NO;
    }
    return YES;
}

@end
