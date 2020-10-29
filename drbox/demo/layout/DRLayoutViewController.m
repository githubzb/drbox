//
//  DRLayoutViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRLayoutViewController.h"
#import "Drbox.h"
#import "DRAsyncLayoutViewController.h"

@interface DRLayoutViewController ()

@end

@implementation DRLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置view的布局结构
    [self.view dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;// 设置view的内容布局为列布局（从上到下），默认值
        layout.alignItems = YGAlignCenter; // 子视图水平居中
        layout.justifyContent = YGJustifyCenter; // 子视图垂直居中
    }];
    
    for (int i = 1; i < 21; i++) {
        UIView *v = [self createViewBackground:DRColorFromRGB(185.0/i, 220.0/i, 140.0/i)];
        [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
            layout.width = DRPointValue(DRMainScreenW-i*40);
            layout.aspectRatio = 1;
            layout.justifyContent = YGJustifyCenter;
            layout.alignItems = YGAlignCenter;
        }];
        v.tag = i;
        if (i == 1) {
            [self.view addSubview:v];
        } else {
            [[self.view viewWithTag:i-1] addSubview:v];
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"异步布局"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(toAsyncLayoutDemo)];
}

- (void)toAsyncLayoutDemo{
    DRAsyncLayoutViewController *vc = [[DRAsyncLayoutViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)createViewBackground:(UIColor *)color{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = color;
    return v;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.view dr_displayLayoutPreservingOrigin:YES];
}


@end
