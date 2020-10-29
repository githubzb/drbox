//
//  DRColorViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/15.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRColorViewController.h"
#import "Drbox.h"

@interface DRColorViewController ()

@property (nonatomic, readonly) UIView *contentView;

@end

@implementation DRColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    
    UIColor *blueColor = DRColorFromHex(#0000FF);// 蓝色
    UIColor *greenColor = DRColorFromHex(#008000); // 绿色
    UIColor *color1 = [blueColor dr_colorByAddColor:greenColor
                                         blendMode:kCGBlendModeScreen];
    UIView *v1 = [self createCellView:@"蓝色和绿色混合颜色：kCGBlendModeScreen" color:color1];
    [self.contentView addSubview:v1];
    
    UIColor *color2 = [blueColor dr_colorByAddColor:greenColor
                                         blendMode:kCGBlendModeColorBurn];
    UIView *v2 = [self createCellView:@"蓝色和绿色混合颜色：kCGBlendModeColorBurn" color:color2];
    [self.contentView addSubview:v2];
    
    UIColor *color3 = [blueColor dr_colorByAddColor:greenColor
                                         blendMode:kCGBlendModeOverlay];
    UIView *v3 = [self createCellView:@"蓝色和绿色混合颜色：kCGBlendModeOverlay" color:color3];
    [self.contentView addSubview:v3];
    
    UIColor *color4 = [blueColor dr_colorByAddColor:greenColor
                                         blendMode:kCGBlendModeColor];
    UIView *v4 = [self createCellView:@"蓝色和绿色混合颜色：kCGBlendModeColor" color:color4];
    [self.contentView addSubview:v4];
    
    UIColor *color5 = [blueColor dr_colorByAddColor:greenColor
                                         blendMode:kCGBlendModeSourceIn];
    UIView *v5 = [self createCellView:@"蓝色和绿色混合颜色：kCGBlendModeSourceIn" color:color5];
    [self.contentView addSubview:v5];
    
    UIColor *color6 = [blueColor dr_colorByAddColor:greenColor
                                         blendMode:kCGBlendModeColorDodge];
    UIView *v6 = [self createCellView:@"蓝色和绿色混合颜色：kCGBlendModeColorDodge" color:color6];
    [self.contentView addSubview:v6];
}

- (void)loadView{
    self.view = [[UIScrollView alloc] init];
}

- (UIView *)contentView{
    return ((UIScrollView *)self.view).dr_contentView;
}

- (UIView *)createCellView:(NSString *)title color:(UIColor *)color{
    UIView *v = [[UIView alloc] init];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    UIView *topV = [[UIView alloc] init];
    topV.backgroundColor = [UIColor whiteColor];
    [topV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
        layout.padding = DRPointValue(8);
    }];
    [v addSubview:topV];
    UILabel *lb = [[UILabel alloc] init];
    lb.textColor = DRColorFromHex(#CD5C5C);
    lb.font = [UIFont systemFontOfSize:14];
    lb.text = title;
    lb.numberOfLines = 0;
    [lb dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
    }];
    [topV addSubview:lb];
    
    UIView *bottomV = [[UIView alloc] init];
    bottomV.backgroundColor = color;
    [bottomV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.height = DRPointValue(50);
    }];
    [v addSubview:bottomV];
    return v;
}

@end
