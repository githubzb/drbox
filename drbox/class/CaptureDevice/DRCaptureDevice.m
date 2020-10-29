//
//  DRCaptureDevice.m
//  drbox
//
//  Created by dr.box on 2020/9/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRCaptureDevice.h"
#import "DrboxMacro.h"

NSString *const kDRCaptureDeviceErrorDomain = @"com.drbox.captureDevice.error";

@interface DRCaptureDevice ()<AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate>{
    
    AVCaptureDevicePosition _devicePosition;
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_videoPreviewLayer;
    
    AVCaptureDevice *_cameraDevice; // 相机设备
    AVCaptureDevice *_microphoneDevice; // 麦克风设备
    
    AVCaptureDeviceInput *_videoInput; // 视频输入流
    AVCaptureDeviceInput *_audioInput; // 音频输入流
    
    AVCaptureVideoDataOutput *_videoOutput; // 视频输出流
    AVCaptureAudioDataOutput *_audioOutput; // 音频输出流
    
    AVCaptureDepthDataOutput *_depthDataOutput API_AVAILABLE(ios(11.0)); // 深度数据输出流
    
    AVCaptureStillImageOutput *_imageOutput; // 照片输出流
    AVCapturePhotoOutput *_photoOutput API_AVAILABLE(ios(10.0)); // 照片输出流
    
    dispatch_queue_t _audioProcessingQueue, _cameraProcessingQueue;
    
    DRTakePhotoCallback _takePhotoCallback; // 拍照回调
}

@end
@implementation DRCaptureDevice

@synthesize sessionPreset = _sessionPreset;

- (void)dealloc{
    [_videoOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
    [_audioOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
    [_session beginConfiguration];
    for (AVCaptureInput *ipt in _session.inputs) {
        [_session removeInput:ipt];
    }
    for (AVCaptureOutput *opt in _session.outputs) {
        [_session removeOutput:opt];
    }
    [_session commitConfiguration];
    [self stop];
}

- (instancetype)initWithSessionPreset:(AVCaptureSessionPreset)preset
                       devicePosition:(AVCaptureDevicePosition)position{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    if (![session canSetSessionPreset:preset]) return nil;
    self = [super init];
    if (self) {
        _devicePosition = position;
        _session = session;
        _sessionPreset = preset;
        _audioProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        _cameraProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        [_session beginConfiguration];
        [_session setSessionPreset:preset];
        [_session commitConfiguration];
    }
    return self;
}

+ (instancetype)sessionPreset:(AVCaptureSessionPreset)preset
               devicePosition:(AVCaptureDevicePosition)position{
    return [[self alloc] initWithSessionPreset:preset devicePosition:position];
}

- (void)setPreviewInView:(UIView *)view videoGravity:(AVLayerVideoGravity)gravity{
    if (!view) return;
    BOOL hasPreviewLayer = NO;
    if (_videoPreviewLayer) {
        for (CALayer *layer in view.layer.sublayers) {
            if (layer == _videoPreviewLayer) {
                hasPreviewLayer = YES;
                break;
            }
        }
    }
    if (hasPreviewLayer) return;
    if (_videoPreviewLayer) {
        [_videoPreviewLayer removeFromSuperlayer];
    }else{
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    }
    _videoPreviewLayer.videoGravity = gravity;
    _videoPreviewLayer.frame = view.bounds;
    if (_videoPreviewLayer.connection.isVideoOrientationSupported) {
        _videoPreviewLayer.connection.videoOrientation = [self getCaptureVideoOrientation];
    }
    if (_videoPreviewLayer.connection.isVideoMirroringSupported) {
        _videoPreviewLayer.connection.automaticallyAdjustsVideoMirroring = NO;
        _videoPreviewLayer.connection.videoMirrored = [self isVideoMirrored];
    }
    [view.layer addSublayer:_videoPreviewLayer];
}

- (void)start{
    if (_session && !_session.isRunning) {
        [_session startRunning];
    }
}

- (void)stop{
    if (_session && _session.isRunning) {
        [_session stopRunning];
    }
}

- (BOOL)addAudioInputsAndOutputsWithError:(NSError * _Nullable __autoreleasing *)error{
    if (_audioInput) {
        [self setError:error message:@"audio input existing."];
        return NO;
    }
    _microphoneDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (!_microphoneDevice) {
        [self setError:error message:@"microphone device initialization fail."];
        return NO;
    }
    NSError *err;
    _audioInput = [AVCaptureDeviceInput deviceInputWithDevice:_microphoneDevice error:&err];
    if (err) {
        [self setError:error message:err.localizedDescription];
        _microphoneDevice = nil;
        return NO;
    }
    [_session beginConfiguration];
    if ([_session canAddInput:_audioInput]) {
        [_session addInput:_audioInput];
    }else{
        [self setError:error message:@"couldn't add audio input."];
        _microphoneDevice = nil;
        _audioInput = nil;
        return NO;
    }
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    if ([_session canAddOutput:_audioOutput]) {
        [_session addOutput:_audioOutput];
    }else{
        [self setError:error message:@"couldn't add audio output."];
        _microphoneDevice = nil;
        [_session removeInput:_audioInput];
        _audioInput = nil;
        _audioOutput = nil;
        return NO;
    }
    [_audioOutput setSampleBufferDelegate:self queue:_audioProcessingQueue];
    [_session commitConfiguration];
    return YES;
}

- (void)removeAudioInputsAndOutputs{
    if (!_audioInput && !_audioOutput) return;
    [_session beginConfiguration];
    [_session removeInput:_audioInput];
    [_session removeOutput:_audioOutput];
    _audioInput = nil;
    _audioOutput = nil;
    _microphoneDevice = nil;
    [_session commitConfiguration];
}

- (BOOL)addVideoInputsAndOutputsWithError:(NSError * _Nullable __autoreleasing *)error{
    if (_videoInput) {
        [self setError:error message:@"video input existing."];
        return NO;
    }
    _cameraDevice = [self getCameraDeviceWithMediaType:AVMediaTypeVideo];
    if (!_cameraDevice) {
        [self setError:error message:@"the camera device initialization fail."];
        return NO;
    }
    NSError *err;
    _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_cameraDevice error:&err];
    if (err) {
        [self setError:error message:err.localizedDescription];
        _cameraDevice = nil;
        return NO;
    }
    if ([_session canAddInput:_videoInput]) {
        [_session addInput:_videoInput];
    }else{
        [self setError:error message:@"couldn't add video input."];
        _cameraDevice = nil;
        _videoInput = nil;
        return NO;
    }
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoOutput setAlwaysDiscardsLateVideoFrames:NO];
    [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    if ([_session canAddOutput:_videoOutput]) {
        [_session addOutput:_videoOutput];
    }else{
        [self setError:error message:@"couldn't add video output."];
        _cameraDevice = nil;
        [_session removeInput:_videoInput];
        _videoInput = nil;
        _videoOutput = nil;
        return NO;
    }
    [_videoOutput setSampleBufferDelegate:self queue:_cameraProcessingQueue];
    AVCaptureVideoOrientation orientation = [self getCaptureVideoOrientation];
    dispatch_async_on_main_queue(^{
        if (self->_videoPreviewLayer.connection.isVideoOrientationSupported) {
            self->_videoPreviewLayer.connection.videoOrientation = orientation;
        }
        if (self->_videoPreviewLayer.connection.isVideoMirroringSupported) {
            self->_videoPreviewLayer.connection.automaticallyAdjustsVideoMirroring = NO;
            self->_videoPreviewLayer.connection.videoMirrored = [self isVideoMirrored];
        }
    });
    AVCaptureConnection *videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    [videoConnection setVideoOrientation:orientation];
    [videoConnection setVideoMirrored:[self isVideoMirrored]];
    [_session commitConfiguration];
    return YES;
}

- (void)removeVideoInputsAndOutputs{
    if (!_videoInput && !_videoOutput) return;
    [_session beginConfiguration];
    [_session removeInput:_videoInput];
    [_session removeOutput:_videoOutput];
    _videoInput = nil;
    _videoOutput = nil;
    _cameraDevice = nil;
    [_session commitConfiguration];
}

- (BOOL)addPhotoInputsAndOutputsWithError:(NSError * _Nullable __autoreleasing *)error{
    if (_photoOutput || _imageOutput) {
        [self setError:error message:@"the photo output existing."];
        return NO;
    }
    [_session beginConfiguration];
    if (!_videoInput) {
        // 添加视频输入流
        _cameraDevice = [self getCameraDeviceWithMediaType:AVMediaTypeVideo];
        if (!_cameraDevice) {
            [self setError:error message:@"the camera device initialization fail."];
            return NO;
        }
        NSError *err;
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_cameraDevice error:&err];
        if (err) {
            [self setError:error message:err.localizedDescription];
            _cameraDevice = nil;
            return NO;
        }
        if ([_session canAddInput:_videoInput]) {
            [_session addInput:_videoInput];
        }else{
            [self setError:error message:@"couldn't add video input."];
            _cameraDevice = nil;
            _videoInput = nil;
            return NO;
        }
    }
    if (@available(iOS 10.0, *)) {
        _photoOutput = [[AVCapturePhotoOutput alloc] init];
        if ([_session canAddOutput:_photoOutput]) {
            [_session addOutput:_photoOutput];
        }else{
            [self setError:error message:@"couldn't add photo output."];
            return NO;
        }
    }else{
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([_session canAddOutput:_imageOutput]) {
            [_session addOutput:_imageOutput];
        }else{
            [self setError:error message:@"couldn't add stillImage output."];
            return NO;
        }
    }
    [_session commitConfiguration];
    return YES;
}

- (void)removePhotoInputsAndOutputs{
    if (!_photoOutput && !_imageOutput) return;
    [_session beginConfiguration];
    [_session removeInput:_videoInput];
    if (_photoOutput) {
        [_session removeOutput:_photoOutput];
    }
    if (_imageOutput) {
        [_session removeOutput:_imageOutput];
    }
    [_session commitConfiguration];
    
    _videoInput = nil;
    _photoOutput = nil;
    _imageOutput = nil;
    _cameraDevice = nil;
}

- (BOOL)setVideoMinFrameRate:(int32_t)min
                maxFrameRate:(int32_t)max
                   withError:(NSError * _Nullable __autoreleasing *)error{
    if (!_cameraDevice) {
        [self setError:error message:@"the current camera device not found,please add the video input first."];
        return NO;
    }
    if ([_cameraDevice respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
        [_cameraDevice respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]) {
        NSError *err;
        AVCaptureDeviceFormat *vFormat;
        for (AVCaptureDeviceFormat *format in _cameraDevice.formats) {
            CMFormatDescriptionRef description = format.formatDescription;
            AVFrameRateRange *range = [format.videoSupportedFrameRateRanges lastObject];
            CMVideoDimensions dims = CMVideoFormatDescriptionGetDimensions(description);
            CMMediaType mediaType = CMFormatDescriptionGetMediaType(description);
            NSString *dimsStr = [NSString stringWithFormat:@"%dx%d", dims.width, dims.height];
            if (mediaType == kCMMediaType_Video &&
                [_sessionPreset hasSuffix:dimsStr] &&
                min >= range.minFrameRate && max <= range.maxFrameRate) {
                vFormat = format;
            }
        }
        if (vFormat) {
            if ([_cameraDevice lockForConfiguration:&err]) {
                _cameraDevice.activeFormat = vFormat;
                _cameraDevice.activeVideoMinFrameDuration = CMTimeMake(1, min);
                _cameraDevice.activeVideoMaxFrameDuration = CMTimeMake(1, max);
                [_cameraDevice unlockForConfiguration];
            }else{
                [self setError:error message:err.localizedDescription];
                return NO;
            }
        }else{
            [self setError:error message:@"the video frame rate out of range,reset to default."];
            return NO;
        }
    }else{
        [self setError:error message:@"activeVideoMinFrameDuration,activeVideoMaxFrameDuration not found."];
        return NO;
    }
    return YES;
}

- (BOOL)switchCameraPositionWithError:(NSError * _Nullable __autoreleasing *)error{
    if (!_cameraDevice) {
        [self setError:error message:@"the current camera device not found,please add the video input first."];
        return NO;
    }
    _devicePosition = [self reversalDevicePosition];
    AVCaptureDevice *newDevice = [self getCameraDeviceWithMediaType:AVMediaTypeVideo];
    if (!newDevice) {
        [self setError:error message:@"the camera device initialization fail."];
        _devicePosition = [self reversalDevicePosition];
        return NO;
    }
    NSError *err;
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:&err];
    if (err) {
        [self setError:error message:err.localizedDescription];
        _devicePosition = [self reversalDevicePosition];
        return NO;
    }
    [_session beginConfiguration];
    [_session removeInput:_videoInput];
    if ([_session canAddInput:newInput]) {
        [_session addInput:newInput];
    }else{
        [self setError:error message:@"couldn't add video input."];
        [_session addInput:_videoInput];
        _devicePosition = [self reversalDevicePosition];
        return NO;
    }
    _cameraDevice = newDevice;
    _videoInput = newInput;
    [_session commitConfiguration];
    
    AVCaptureVideoOrientation orientation = [self getCaptureVideoOrientation];
    dispatch_async_on_main_queue(^{
        self->_videoPreviewLayer.connection.videoOrientation = orientation;
    });
    AVCaptureConnection *videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    [videoConnection setVideoOrientation:orientation];
    [videoConnection setVideoMirrored:[self isVideoMirrored]];
    return YES;
}

- (BOOL)deviceTorchOpen:(BOOL)opened withError:(NSError * _Nullable __autoreleasing * _Nullable)error{
    if (!_cameraDevice) {
        [self setError:error message:@"the current camera device not found,please add the video input first."];
        return NO;
    }
    AVCaptureTorchMode mode = opened ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    if (_cameraDevice.torchMode == mode) return YES;
        
    if ([_cameraDevice hasTorch]) {
        NSError *err;
        if ([_cameraDevice lockForConfiguration:&err]) {
            _cameraDevice.torchMode = mode;
            [_cameraDevice unlockForConfiguration];
        }else{
            [self setError:error message:err.localizedDescription];
            return NO;
        }
    }else{
        [self setError:error message:@"the current device cannot open the torch."];
        return NO;
    }
    return YES;
}

- (BOOL)setExposureTargetBias:(CGFloat)bias withError:(NSError * _Nullable __autoreleasing *)error{
    if (!_cameraDevice) {
        [self setError:error message:@"the current camera device not found,please add the video input first."];
        return NO;
    }
    if (bias < -8 || bias > 8) {
        [self setError:error message:@"invalid parameter value, bias:[-8,8]."];
        return NO;
    }
    if (@available(iOS 8.0, *)) {
        NSError *err;
        if ([_cameraDevice lockForConfiguration:&err]) {
            [_cameraDevice setExposureTargetBias:bias completionHandler:nil];
            [_cameraDevice unlockForConfiguration];
        }else{
            [self setError:error message:err.localizedDescription];
            return NO;
        }
    }else{
        [self setError:error message:@"-setExposureTargetBias:completionHandler: only works on iOS 8."];
        return NO;
    }
    
    return YES;
}

- (BOOL)setExposureAtViewPoint:(CGPoint)viewPoint withError:(NSError * _Nullable __autoreleasing *)error{
    if (!_cameraDevice) {
        [self setError:error message:@"the current camera device not found,please add the video input first."];
        return NO;
    }
    if (!_videoPreviewLayer) {
        [self setError:error message:@"the current video preview layer not found,"
         "please exec setPreviewInView:videoGravity: to add video preview layer."];
        return NO;
    }
    if ([_cameraDevice isExposurePointOfInterestSupported] &&
        [_cameraDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        CGPoint point = [_videoPreviewLayer captureDevicePointOfInterestForPoint:viewPoint];
        NSError *err;
        if ([_cameraDevice lockForConfiguration:&err]) {
            [_cameraDevice setExposurePointOfInterest:point];
            [_cameraDevice setExposureMode:AVCaptureExposureModeAutoExpose];
            [_cameraDevice unlockForConfiguration];
        }else{
            [self setError:error message:err.localizedDescription];
            return NO;
        }
    }
    return YES;
}

- (BOOL)setVideoZoomFactor:(CGFloat)factor withError:(NSError * _Nullable __autoreleasing *)error{
    if (!_cameraDevice) {
        [self setError:error message:@"the current camera device not found,please add the video input first."];
        return NO;
    }
    CGFloat videoMaxZoomFactor = 0;
    for (AVCaptureDeviceFormat *format in _cameraDevice.formats) {
        videoMaxZoomFactor = format.videoMaxZoomFactor;
    }
    if (factor < 1 || factor > videoMaxZoomFactor) {
        NSString *msg = [NSString stringWithFormat:@"beyond the scope of,[1, %.1f]", videoMaxZoomFactor];
        [self setError:error message:msg];
        return NO;
    }
    NSError *err;
    if ([_cameraDevice lockForConfiguration:&err]) {
        [_cameraDevice setVideoZoomFactor:factor];
        [_cameraDevice unlockForConfiguration];
    }else{
        [self setError:error message:err.localizedDescription];
        return NO;
    }
    return YES;
}

- (BOOL)setFocusAtViewPoint:(CGPoint)viewPoint withError:(NSError * _Nullable __autoreleasing *)error{
    if (!_cameraDevice) {
        [self setError:error message:@"the current camera device not found,please add the video input first."];
        return NO;
    }
    if (!_videoPreviewLayer) {
        [self setError:error message:@"the current video preview layer not found,"
         "please exec setPreviewInView:videoGravity: to add video preview layer."];
        return NO;
    }
    if ([_cameraDevice isFocusPointOfInterestSupported] &&
        [_cameraDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        CGPoint point = [_videoPreviewLayer captureDevicePointOfInterestForPoint:viewPoint];
        NSError *err;
        if ([_cameraDevice lockForConfiguration:&err]) {
            [_cameraDevice setFocusPointOfInterest:point];// 这里必须先于setFocusMode
            [_cameraDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            [_cameraDevice unlockForConfiguration];
        }else{
            [self setError:error message:err.localizedDescription];
            return NO;
        }
    }
    return YES;
}

- (BOOL)setWhiteBlanceByTemperature:(CGFloat)temperature
                           withTint:(CGFloat)tint
                          withError:(NSError * _Nullable __autoreleasing *)error{
    if (!_cameraDevice) {
        [self setError:error message:@"the current camera device not found,please add the video input first."];
        return NO;
    }
    if (@available(iOS 8.0, *)) {
        if ([_cameraDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
            if (temperature > 250 || temperature < -150) {
                [self setError:error message:@"the param 'temperature' beyond the scope of [-150, 250]"];
                return NO;
            }
            if (tint > 150 || tint < -150) {
                [self setError:error message:@"the param 'tint' beyond the scope of [-150, 150]"];
                return NO;
            }
            NSError *err;
            if ([_cameraDevice lockForConfiguration:&err]) {
                AVCaptureWhiteBalanceTemperatureAndTintValues tempAndTintValues = {
                    .temperature = temperature,
                    .tint        = tint,
                };
                
                AVCaptureWhiteBalanceGains deviceGains =
                [_cameraDevice deviceWhiteBalanceGainsForTemperatureAndTintValues:tempAndTintValues];
                CGFloat maxVal = _cameraDevice.maxWhiteBalanceGain;
                CGFloat minVal = 1;
                deviceGains.redGain = MAX(MIN(deviceGains.redGain  , maxVal), minVal);
                deviceGains.blueGain = MAX(MIN(deviceGains.blueGain , maxVal), minVal);
                deviceGains.greenGain = MAX(MIN(deviceGains.greenGain, maxVal), minVal);
                [_cameraDevice setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:deviceGains
                                                                  completionHandler:nil];
                [_cameraDevice unlockForConfiguration];
            }else{
                [self setError:error message:err.localizedDescription];
                return NO;
            }
        }else{
            [self setError:error message:@"the camera device not support whiteBalanceMode: AVCaptureWhiteBalanceModeLocked"];
            return NO;
        }
    }else{
        [self setError:error message:@"current system version not support white blance,the version must be >= 8.0"];
        return NO;
    }
    return YES;
}

- (void)takePhotoWithBlock:(DRTakePhotoCallback)block{
    if (!block) return;
    if (@available(iOS 10.0, *)) {
        if (!_photoOutput) {
            NSError *error = DRCreateError(kDRCaptureDeviceErrorDomain, 0, @"the current photo output not found,please add first.");
            block(nil, error);
            return;
        }
        _takePhotoCallback = [block copy];
        [_photoOutput capturePhotoWithSettings:[AVCapturePhotoSettings photoSettings]
                                      delegate:self];
    }else{
        if (!_imageOutput) {
            NSError *error = DRCreateError(kDRCaptureDeviceErrorDomain, 0, @"the current stillImage output not found,please add first.");
            block(nil, error);
            return;
        }
        AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
        [_imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                  completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
            if (error) {
                block(nil, error);
                return;
            }
            NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            block([UIImage imageWithData:data], nil);
        }];
    }
}

- (AVCaptureVideoDataOutput *)videoOutput{
    return _videoOutput;
}

- (BOOL)isRunning{
    return _session.isRunning;
}

- (AVCaptureSessionPreset)sessionPreset{
    return _sessionPreset;
}
- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset{
    if (![_sessionPreset isEqualToString:sessionPreset] && [_session canSetSessionPreset:sessionPreset]) {
        _sessionPreset = sessionPreset;
        [_session beginConfiguration];
        [_session setSessionPreset:_sessionPreset];
        [_session commitConfiguration];
    }
}

#pragma mark - private
/// 获取摄像头设备
- (AVCaptureDevice *)getCameraDeviceWithMediaType:(AVMediaType)type{
    NSArray<AVCaptureDevice *> *devices;
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *dissession =
        [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[[self getCaptureDeviceType]]
                                                               mediaType:type
                                                                position:_devicePosition];
        devices = dissession.devices;
    }else{
        devices = [AVCaptureDevice devices];
    }
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:type]) {
            if ([device position] == _devicePosition) {
                return device;
            }
        }
    }
    return nil;
}

- (AVCaptureDeviceType)getCaptureDeviceType API_AVAILABLE(ios(10.0)){
    if (@available(iOS 10.0, *)) {
        if (_getCameraDeviceType) {
            AVCaptureDeviceType type = _getCameraDeviceType();
            if (type && type != AVCaptureDeviceTypeBuiltInMicrophone) {
                return type;
            }
        }
        return AVCaptureDeviceTypeBuiltInWideAngleCamera;
    }
    return nil;
}

/// 获取视频方向
- (AVCaptureVideoOrientation)getCaptureVideoOrientation{
    if (_getOrientation) {
        return _getOrientation();
    }
    UIDeviceOrientation iDeviceOrientation = [self getDeviceOrientation];
    AVCaptureVideoOrientation captureVideoOrientation = AVCaptureVideoOrientationPortrait;
    switch (iDeviceOrientation) {
        case UIDeviceOrientationPortrait:   // Device oriented vertically, home button on the bottom
            captureVideoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            captureVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            captureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            captureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            break;
    }
    return captureVideoOrientation;
}

/// 获取设备方向
- (UIDeviceOrientation)getDeviceOrientation{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            deviceOrientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
            break;
        default:
            break;
    }
    return deviceOrientation;
}

- (void)setError:(NSError **)error message:(NSString *)msg{
    if (error) {
        NSError *err = DRCreateError(kDRCaptureDeviceErrorDomain, 0, msg);
        DRSetError(error, err);
    }
}

- (AVCaptureDevicePosition)reversalDevicePosition{
    return _devicePosition == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (BOOL)isVideoMirrored{
    return _devicePosition == AVCaptureDevicePositionFront ?: NO;
}

- (AVCaptureWhiteBalanceGains)clampGains:(AVCaptureWhiteBalanceGains)gains
                                toMinVal:(CGFloat)minVal
                               andMaxVal:(CGFloat)maxVal {
    AVCaptureWhiteBalanceGains tmpGains = gains;
    tmpGains.blueGain   = MAX(MIN(tmpGains.blueGain , maxVal), minVal);
    tmpGains.redGain    = MAX(MIN(tmpGains.redGain  , maxVal), minVal);
    tmpGains.greenGain  = MAX(MIN(tmpGains.greenGain, maxVal), minVal);
    return tmpGains;
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error API_AVAILABLE(ios(11.0)){
    if (error) {
        _takePhotoCallback(nil, error);
        _takePhotoCallback = nil;
        return;
    }
    if (@available(iOS 11.0, *)) {
        NSData *data = [photo fileDataRepresentation];
        _takePhotoCallback([UIImage imageWithData:data], nil);
        _takePhotoCallback = nil;
    }
}

/**
 当调用AVCapturePhotoOutput-capturePhotoWithSettings: delegate:捕获图像时，如果AVCapturePhotoSettings中
 rawPhotoPixelFormatType is zero，该代理会被执行
 */
- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer
previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer
     resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
      bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings
                error:(nullable NSError *)error API_AVAILABLE(ios(10.0)){
    if (error) {
        _takePhotoCallback(nil, error);
        _takePhotoCallback = nil;
        return;
    }
    if (@available(iOS 10.0, *)) {
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer
                                                                   previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        _takePhotoCallback([UIImage imageWithData:data], nil);
        _takePhotoCallback = nil;
    }
}

/**
当调用AVCapturePhotoOutput-capturePhotoWithSettings: delegate:捕获图像时，如果AVCapturePhotoSettings中
rawPhotoPixelFormatType is non-zero，该代理会被执行
*/
- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingRawPhotoSampleBuffer:(nullable CMSampleBufferRef)rawSampleBuffer
previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer
     resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
      bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings
                error:(nullable NSError *)error API_AVAILABLE(ios(10.0)){
    if (error) {
        _takePhotoCallback(nil, error);
        _takePhotoCallback = nil;
        return;
    }
    if (@available(iOS 10.0, *)) {
        NSData *data = [AVCapturePhotoOutput DNGPhotoDataRepresentationForRawSampleBuffer:rawSampleBuffer
                                                                 previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        _takePhotoCallback([UIImage imageWithData:data], nil);
        _takePhotoCallback = nil;
    }
}

@end
