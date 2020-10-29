//
//  DRCaptureDevice.h
//  drbox
//
//  Created by dr.box on 2020/9/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DRCaptureDeviceDelegate <NSObject>

@optional


@end

extern NSString *const kDRCaptureDeviceErrorDomain;

typedef AVCaptureDeviceType _Nullable (^DRCaptureDeviceTypeBlock)(void) API_AVAILABLE(ios(10.0));
typedef AVCaptureVideoOrientation (^DRCaptureDeviceOrientation)(void);
typedef void(^DRTakePhotoCallback)(UIImage * _Nullable image, NSError * _Nullable error);

@interface DRCaptureDevice : NSObject

@property (nonatomic, weak, nullable) id<DRCaptureDeviceDelegate> delegate;
/// 设置相机类型，不设置，采用默认项
@property (nonatomic, copy, nullable) DRCaptureDeviceTypeBlock getCameraDeviceType API_AVAILABLE(ios(10.0));
/// 设置设备方向，不设置，默认当前设备方向（注意：需要在-startShowInView:videoGravity:方法调用之前设置，否则无效）
@property (nonatomic, copy, nullable) DRCaptureDeviceOrientation getOrientation;

@property (nonatomic, readwrite) AVCaptureSessionPreset sessionPreset;

/// 视频输出流
@property (nonatomic, readonly, nullable) AVCaptureVideoDataOutput *videoOutput;

@property(readonly, nonatomic) BOOL isRunning;

- (instancetype)init NS_UNAVAILABLE;
/**
 初始化相机设备
 
 @param preset 分辨率
 @param position 指定设备为前置还是后置
 
 @return 如果当前设备不支持指定的preset，return nil
 */
- (nullable instancetype)initWithSessionPreset:(AVCaptureSessionPreset)preset
                                devicePosition:(AVCaptureDevicePosition)position NS_DESIGNATED_INITIALIZER;

+ (nullable instancetype)sessionPreset:(AVCaptureSessionPreset)preset
                        devicePosition:(AVCaptureDevicePosition)position;
/**
 在指定视图上显示预览视频
 
 @discussion 注意：view必须要设置好frame，否则当前PreviewLayer的frame无法确认
 
 @param view 指定的视图（AVCaptureVideoPreviewLayer会添加到这个视图上）
 @param gravity 预览视频内容适配方案
 */
- (void)setPreviewInView:(UIView *)view videoGravity:(AVLayerVideoGravity)gravity;
/// 开启session
- (void)start;
/// 停止session
- (void)stop;


/// 添加音频输入输出流（用于获取音频数据）
- (BOOL)addAudioInputsAndOutputsWithError:(NSError * _Nullable * _Nullable)error;
/// 移除音频输入输出流
- (void)removeAudioInputsAndOutputs;

/// 添加视频输入输出流（用于获取视频数据）
- (BOOL)addVideoInputsAndOutputsWithError:(NSError * _Nullable * _Nullable)error;
/// 移除视频输入输出流
- (void)removeVideoInputsAndOutputs;

/// 添加照相机的输入输出流（用于拍照）
- (BOOL)addPhotoInputsAndOutputsWithError:(NSError * _Nullable * _Nullable)error;
/// 移除照相机的输入输出流
- (void)removePhotoInputsAndOutputs;

/// 设置视频的最大最小帧率
- (BOOL)setVideoMinFrameRate:(int32_t)min
                maxFrameRate:(int32_t)max
                   withError:(NSError * _Nullable *_Nullable)error;


/// 切换摄像头（前置或后置）
- (BOOL)switchCameraPositionWithError:(NSError * _Nullable * _Nullable)error;

/// 开启或关闭闪光灯
- (BOOL)deviceTorchOpen:(BOOL)opened withError:(NSError * _Nullable *_Nullable)error;

/// 设置摄像机的曝光度，bias：[-8,8]
- (BOOL)setExposureTargetBias:(CGFloat)bias withError:(NSError * _Nullable * _Nullable)error;

/// 设置摄像头的曝光点，viewPoint：视频预览视图的点坐标
- (BOOL)setExposureAtViewPoint:(CGPoint)viewPoint withError:(NSError * _Nullable * _Nullable)error;

/// 设置摄像机的缩放比
- (BOOL)setVideoZoomFactor:(CGFloat)factor withError:(NSError * _Nullable * _Nullable)error;

/// 设置摄像头自动对焦的焦点，viewPoint：视频预览视图的点坐标
- (BOOL)setFocusAtViewPoint:(CGPoint)viewPoint withError:(NSError * _Nullable * _Nullable)error;

/**
 设置白平衡（ios 8.0之后可以正常使用）
 
 @param temperature [-150, 250]
 @param tint [-150, 150]
 @param error 获取错误信息指针
 */
- (BOOL)setWhiteBlanceByTemperature:(CGFloat)temperature
                           withTint:(CGFloat)tint
                          withError:(NSError * _Nullable * _Nullable)error;


/// 开始拍照，并获取照片
- (void)takePhotoWithBlock:(nullable DRTakePhotoCallback)block;

@end

NS_ASSUME_NONNULL_END
