//
//  DrboxMacroViewController.m
//  drbox
//
//  Created by dr.box on 2020/7/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DrboxMacroViewController.h"
#import "Drbox.h"

@interface DrboxMacroViewController ()

@property (nonatomic, copy) dispatch_block_t block;

@end

@implementation DrboxMacroViewController

- (void)dealloc{
    dispatch_async_on_main_queue(^{
        NSLog(@"DrboxMacroViewController dealloc");
        if (self.block) {
            self.block();
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 模拟swift中的defer函数
    @onDefer{
        NSLog(@"viewDidLoad函数作用域执行完毕的回调函数defer1");
    };
    
    @onDefer{
        NSLog(@"viewDidLoad函数作用域执行完毕的回调函数defer2");
    };
    
    @onDefer{
        NSLog(@"viewDidLoad函数作用域执行完毕的回调函数defer3");
    };
    
    // 以上defer执行函数顺序：从后往前执行，跟swift的defer完全一样
    
    @weakify(self);
    self.block = ^{
        @strongify(self);
        NSLog(@"------this.title:%@", self.title);
    };
    
    [self.view dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    
    CGFloat pt = 100;
    CGFloat px = 200;
    CGFloat rpt1 = DRRpt(pt); // 用于兼容多种屏幕尺寸
    CGFloat rpx1 = DRRpx(px);
    
    UILabel *lb1 = [self makeLabel:[NSString stringWithFormat:@"屏幕宽度：%@pt，设计稿基准宽度：%@pt", @(DRMainScreenW), @(DRDesignBaseWidth)]];
    [lb1 dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.marginTop = DRPointValue(100);
    }];
    [self.view addSubview:lb1];
    
    UILabel *lb2 = [self makeLabel:[NSString stringWithFormat:@"设计稿中的pt值：%@pt，实际的pt值：%@pt", @(pt), @(rpt1)]];
    [self.view addSubview:lb2];
    
    UILabel *lb3 = [self makeLabel:[NSString stringWithFormat:@"设计稿中的px值：%@px，实际的pt值：%@pt", @(px), @(rpx1)]];
    [self.view addSubview:lb3];
    
    // 重置设计稿基准宽度
    DRResetDesignBaseWidth(414.0);
    CGFloat rpt2 = DRRpt(pt);
    CGFloat rpx2 = DRRpx(px);
    
    UILabel *lb4 = [self makeLabel:[NSString stringWithFormat:@"重置后的设计稿基准宽度：%@pt", @(DRDesignBaseWidth)]];
    [self.view addSubview:lb4];
    
    UILabel *lb5 = [self makeLabel:[NSString stringWithFormat:@"设计稿中的pt值：%@pt，实际的pt值：%@pt", @(pt), @(rpt2)]];
    [self.view addSubview:lb5];
    
    UILabel *lb6 = [self makeLabel:[NSString stringWithFormat:@"设计稿中的px值：%@px，实际的pt值：%@pt", @(px), @(rpx2)]];
    [self.view addSubview:lb6];
    
    dispatch_async_on_main_queue(^{
        NSLog(@"viewDidLoad函数作用域执行完毕");
    });
    
}

- (UILabel *)makeLabel:(NSString *)text{
    UILabel *lb = [[UILabel alloc] init];
    lb.text = text;
    [lb dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexWrap = YGWrapWrap;
        layout.marginBottom = DRPointValue(8);
    }];
    return lb;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.block();
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.view dr_displayLayout];
}

@end
