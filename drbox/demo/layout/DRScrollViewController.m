//
//  DRScrollViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRScrollViewController.h"
#import "Drbox.h"

@interface DRScrollViewController ()

@property (nonatomic, readonly) UIScrollView *scrollView;

@end

@implementation DRScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.scrollView.dr_layoutAsynchronously = NO;// 设置scrollview是否异步布局，默认：异步布局
    [self.scrollView.dr_contentView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn; // 设置scrollview为垂直布局
    }];
    
    for (int i=0; i<100; i++) {
        UIView *v = [self createViewBackground:DRColorFromRGB(155-i, 180-i, 120-i)];
        [self.scrollView.dr_contentView addSubview:v];
        [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
            layout.margin = DRPointValue(15);
            layout.height = DRPointValue(50);
            layout.flexDirection = YGFlexDirectionRow;
        }];
        
        for (int j=0; j<5; j++) {
            UIView *sv = [self createViewBackground:DRColorFromRGB(90-j*10, 160-j*20, 240-j*5)];
            [v addSubview:sv];
            [sv dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.flex = 1;
                layout.margin = DRPointValue(8);
            }];
            sv.dr_layoutFinishBlock = ^(UIView * _Nonnull view) {
                view.layer.masksToBounds = YES;
                view.layer.cornerRadius = view.frame.size.height/2.0;
            };
        }
    }
    
    self.scrollView.dr_contentView.dr_layoutFinishBlock = ^(__kindof UIView * _Nonnull view) {
        NSLog(@"---布局完成");
    };
    
    dispatch_after_on_main_queue(10, ^{
        NSLog(@"开始重新布局");
        [self.scrollView dr_setNeedsLayout];
    });
}

- (void)loadView{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    self.view = scrollView;
}

- (UIScrollView *)scrollView{
    return (UIScrollView *)self.view;
}

- (UIView *)createViewBackground:(UIColor *)color{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = color;
    return v;
}

@end
