//
//  DRUIControlViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/29.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRUIControlViewController.h"
#import "Drbox.h"

@interface DRUIControlViewController ()

@end

@implementation DRUIControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
        layout.justifyContent = YGJustifyCenter;
        layout.alignItems = YGAlignCenter;
    }];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:btn];
    [btn dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.width = DRPointValue(200);
        layout.height = DRPointValue(100);
    }];
    
    [btn dr_setTarget:self
               action:@selector(actionOne)
     forControlEvents:UIControlEventTouchUpInside];
    // 下面这个会覆盖前面的actionOne
    [btn dr_setTarget:self
               action:@selector(actionTwo)
     forControlEvents:UIControlEventTouchUpInside];
    
    [btn dr_addActionBlock:^(id  _Nonnull sender) {
        
        NSLog(@"------:upInside");
    } forControlEvents:UIControlEventTouchUpInside];
    
    [btn dr_addActionBlock:^(id  _Nonnull sender) {
        NSLog(@"------: down");
    } forControlEvents:UIControlEventTouchDown];
    
    [btn dr_addActionBlock:^(id  _Nonnull sender) {
        NSLog(@"------: upOutside");
    } forControlEvents:UIControlEventTouchUpOutside];
    
    // 下面这个会覆盖前面设置的UIControlEventTouchUpInside所有事件回调block
//    [btn dr_setActionBlock:^(id  _Nonnull sender) {
//
//        NSLog(@"------set: upInside");
//    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.view dr_displayLayout];
}

- (void)actionOne{
    NSLog(@"click action one");
}

- (void)actionTwo{
    NSLog(@"click action two");
}

@end
