//
//  DRGestureViewController.m
//  drbox
//
//  Created by dr.box on 2020/9/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRGestureViewController.h"
#import "Drbox.h"

@interface DRGestureViewController ()

@end

@implementation DRGestureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
        layout.justifyContent = YGJustifyCenter;
        layout.alignItems = YGAlignCenter;
    }];
    UIView *v1 = [[UIView alloc] init];
    v1.backgroundColor = [UIColor redColor];
    [self.view addSubview:v1];
    [v1 dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.width = DRPointValue(200);
        layout.height = DRPointValue(100);
    }];
    
    UIView *v2 = [[UIView alloc] init];
    v2.backgroundColor = [UIColor greenColor];
    [self.view addSubview:v2];
    [v2 dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.width = DRPointValue(200);
        layout.height = DRPointValue(100);
        layout.marginTop = DRPointValue(20);
    }];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] init];
    [tap1 dr_addActionBlock:^(id  _Nonnull sender) {
        NSLog(@"-----tap1: %@", sender);
    }];
    v1.userInteractionEnabled = YES;
    [v1 addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
    [tap2 dr_addActionBlock:^(id  _Nonnull sender) {
        NSLog(@"-----tap2_1: %@", sender);
    }];
    
    [tap2 dr_addActionBlock:^(id  _Nonnull sender) {
        NSLog(@"-----tap2_2: %@", sender);
    }];
    v2.userInteractionEnabled = YES;
    [v2 addGestureRecognizer:tap2];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"取消所有target block" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.height = DRPointValue(50);
//        layout.width = DRPointValue(300);
        layout.marginTop = DRPointValue(20);
        layout.paddingLeft = DRPointValue(10);
        layout.paddingRight = DRPointValue(10);
    }];
    [btn setDr_layoutFinishBlock:^(__kindof UIView * _Nonnull view) {
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = CGRectGetHeight(view.frame)/2;
    }];
    
    [btn dr_setActionBlock:^(id  _Nonnull sender) {
        [tap1 dr_removeAllActionBlocks];
        [tap2 dr_removeAllActionBlocks];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.view dr_displayLayout];
}

@end
