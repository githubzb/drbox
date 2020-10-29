//
//  DRAsyncLayoutViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRAsyncLayoutViewController.h"
#import "Drbox.h"

@interface DRAsyncLayoutViewController ()

@end

@implementation DRAsyncLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    
    UIView *v1 = [self createViewBackground:[UIColor redColor]];
    [self.view addSubview:v1];
    [v1 dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        CGFloat navTop = DRStatusBarFrame.size.height+44+20;
        layout.marginTop = DRPointValue(navTop);
        layout.height = DRPointValue(100);
        layout.flexDirection = YGFlexDirectionRow;
    }];
    
    UIView *v2 = [self createViewBackground:[UIColor greenColor]];
    [self.view addSubview:v2];
    [v2 dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.marginTop = DRPointValue(20);
        layout.height = DRPointValue(100);
    }];
    
    UIView *v3 = [self createViewBackground:[UIColor blueColor]];
    [self.view addSubview:v3];
    [v3 dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.marginTop = DRPointValue(20);
        layout.height = DRPointValue(100);
    }];
    
    for (int i=0; i<5; i++) {
        UIView *v = [self createViewBackground:DRColorFromRGB(200-i*20, 255-i*30, 160-i*10)];
        [v1 addSubview:v];
        [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
            layout.flex = 1; // 宽度平均分配
            layout.margin = DRPointValue(10);
        }];
    }
    
}

- (UIView *)createViewBackground:(UIColor *)color{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = color;
    return v;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.view dr_asyncDisplayLayoutPreservingOrigin:YES];
}


@end
