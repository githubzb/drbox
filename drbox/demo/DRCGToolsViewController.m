//
//  DRCGToolsViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/16.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRCGToolsViewController.h"
#import "Drbox.h"

@interface DRCGToolsViewController ()

@property (nonatomic, readonly) UIView *contentView;

@end

@implementation DRCGToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    
    [self testDRCGAffineTransformGetFromViews];
    [self testDRCGAffineTransformMakeSkew];
    [self testDRCGRectFitWithContentMode];
}


- (void)loadView{
    self.view = [[UIScrollView alloc] init];
}

- (UIView *)contentView{
    return ((UIScrollView *)self.view).dr_contentView;
}

#pragma mark - demo
/// 测试 DRCGAffineTransformGetFromViews(from, to)
- (void)testDRCGAffineTransformGetFromViews{
    UIView *v1 = [[UIView alloc] init];
    v1.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:v1];
    
    [v1 dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.width = DRPointValue(100);
        layout.height = DRPointValue(100);
        layout.marginTop = DRPointValue(20);
        layout.marginLeft = DRPointValue(50);
    }];
    
    
    UIView *v2 = [[UIView alloc] init];
    v2.frame = CGRectMake(10, 10, 50, 50);
    v2.backgroundColor = [UIColor greenColor];
    [v1 addSubview:v2];
    
    UIView *v3 = [[UIView alloc] init];
    v3.frame = CGRectMake(10, 10, 20, 20);
    v3.backgroundColor = [UIColor blueColor];
    [v2 addSubview:v3];
    
    dispatch_after_on_main_queue(3, ^{
        CGAffineTransform trans = DRCGAffineTransformGetFromViews(v3, v1);
        v1.transform = trans;
    });
}

/// 测试 DRCGAffineTransformMakeSkew(x, y)
- (void)testDRCGAffineTransformMakeSkew{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor redColor];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.width = DRPointValue(100);
        layout.height = DRPointValue(50);
        layout.marginLeft = DRPointValue(100);
        layout.marginTop = DRPointValue(50);
    }];
    [self.contentView addSubview:v];
    
    dispatch_after_on_main_queue(3, ^{
        v.transform = DRCGAffineTransformMakeSkew(0.5, 0.5);
    });
}

/// 测试DRCGRectFitWithContentMode(rect, size, mode)
- (void)testDRCGRectFitWithContentMode{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:v];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.width = DRPointValue(100);
        layout.height = DRPointValue(50);
        layout.marginTop = DRPointValue(20);
    }];
    
    UIView *sv = [[UIView alloc] init];
    sv.backgroundColor = [UIColor redColor];
    [v addSubview:sv];
    
    [v setDr_layoutFinishBlock:^(__kindof UIView * _Nonnull view) {
        CGSize size = CGSizeMake(50, 40);
        CGRect frame = DRCGRectFitWithContentMode(view.bounds, size, UIViewContentModeCenter);
        sv.frame = frame;
    }];
}

@end
