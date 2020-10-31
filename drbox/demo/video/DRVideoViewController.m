//
//  DRVideoViewController.m
//  drbox
//
//  Created by dr.box on 2020/9/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRVideoViewController.h"
#import "Drbox.h"
#import "DRCaptureDevice.h"

@interface DRVideoViewController ()

/// 小图预览
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) DRCaptureDevice *device;

@property (nonatomic, weak) UIView *preview;

@end

@implementation DRVideoViewController

- (void)dealloc{
    NSLog(@"DRVideoViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
        layout.paddingTop = DRPointValue(DRStatusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height);
    }];
    // 初始化预览视图
    UIView *v = [[UIView alloc] init];
    [self.view addSubview:v];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.height = DRPointValue(200);
    }];
    self.preview = v;
    @weakify(self);
    [v dr_addClickOnceWithOneHand:^(UITapGestureRecognizer * _Nonnull tap) {
        @strongify(self);
        [self tapPreview:tap];
    }];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imgView];
    [self.imgView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.height = DRPointValue(100);
        layout.width = DRPointValue(100);
        layout.marginTop = DRPointValue(10);
    }];
    
    [self addSwitchAction:@selector(switchCameraPosition:) title:@"切换镜头"];
    [self addSwitchAction:@selector(switchTorch:) title:@"开启闪光灯"];
    [self addSliderAction:@selector(sliderExposure:) min:-8 max:8 title:@"曝光度"];
    [self addSliderAction:@selector(sliderZoomFactor:) min:1.0 max:2.0 title:@"缩放"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"拍照" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.height = DRPointValue(40);
        layout.marginTop = DRPointValue(10);
    }];
    
    
    self.device = [DRCaptureDevice sessionPreset:AVCaptureSessionPreset1280x720
                                  devicePosition:AVCaptureDevicePositionBack];
    NSError *error;
    if ([self.device addPhotoInputsAndOutputsWithError:&error]) {
        if (![self.device setVideoMinFrameRate:30 maxFrameRate:60 withError:&error]) {
            NSLog(@"----设置帧率失败：%@", error);
        }
        if (![self.device setWhiteBlanceByTemperature:10 withTint:30 withError:&error]) {
            NSLog(@"----设置白平衡失败：%@", error);
        }
        @weakify(self);
        v.dr_layoutFinishBlock = ^(__kindof UIView * _Nonnull view) {
            @strongify(self);
            [self.device setPreviewInView:view videoGravity:AVLayerVideoGravityResizeAspect];
        };
        [self.device start];
    }else{
        NSLog(@"error:%@", error);
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.view dr_displayLayout];
}

- (void)addSwitchAction:(SEL)action title:(NSString *)title{
    UIView *v = [[UIView alloc] init];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
        layout.alignItems = YGAlignCenter;
        layout.height = DRPointValue(50);
        layout.padding = DRPointValue(15);
    }];
    UILabel *lb = [[UILabel alloc] init];
    lb.text = title;
    lb.textColor = [UIColor blackColor];
    lb.font = [UIFont systemFontOfSize:14];
    [v addSubview:lb];
    [lb dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.marginRight = DRPointValue(8);
    }];
    
    UISwitch *s = [[UISwitch alloc] init];
    s.on = NO;
    [s addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [v addSubview:s];
    [s dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
    }];
    [self.view addSubview:v];
}

- (void)addSliderAction:(SEL)action min:(CGFloat)min max:(CGFloat)max title:(NSString *)title{
    UIView *v = [[UIView alloc] init];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
        layout.alignItems = YGAlignCenter;
        layout.height = DRPointValue(50);
        layout.padding = DRPointValue(15);
    }];
    UILabel *lb = [[UILabel alloc] init];
    lb.text = title;
    lb.textColor = [UIColor blackColor];
    lb.font = [UIFont systemFontOfSize:14];
    [v addSubview:lb];
    [lb dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.marginRight = DRPointValue(8);
    }];
    
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = min;
    slider.maximumValue = max;
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [v addSubview:slider];
    [slider dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flex = 1;
        layout.height = DRPointValue(5);
    }];
    [self.view addSubview:v];
}

- (void)sliderExposure:(UISlider *)s{
    NSError *error;
    if (![self.device setExposureTargetBias:s.value withError:&error]) {
        NSLog(@"error: %@", error);
    }
}

- (void)switchTorch:(UISwitch *)s{
    NSError *error;
    if (![self.device deviceTorchOpen:s.on withError:&error]) {
        NSLog(@"error: %@", error);
    }
}

- (void)sliderZoomFactor:(UISlider *)s{
    NSError *error;
    if (![self.device setVideoZoomFactor:s.value withError:&error]) {
        NSLog(@"error: %@", error);
    }
}

- (void)switchCameraPosition:(UISwitch *)s{
    NSError *error;
    if (![self.device switchCameraPositionWithError:&error]) {
        NSLog(@"error: %@", error);
    }
}

- (void)takePhoto{
    [self.device takePhotoWithBlock:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }
        self.imgView.image = image;
    }];
}

// 点击预览图，设置焦点和曝光
- (void)tapPreview:(UIGestureRecognizer *)recognizer{
    CGPoint touchPoint = [recognizer locationInView:self.preview];
    
    NSError *error;
    if (![self.device setExposureAtViewPoint:touchPoint withError:&error]) {
        NSLog(@"设置曝光点错误：%@", error);
    }
    if (![self.device setFocusAtViewPoint:touchPoint withError:&error]) {
        NSLog(@"设置焦点错误：%@", error);
    }
}


@end
