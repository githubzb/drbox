//
//  UIDevice+drbox.h
//  drbox
//
//  Created by dr.box on 2020/9/8.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, DRNetTrafficType) {
    DRNetTrafficTypeWWANSent     = 1 << 0,
    DRNetTrafficTypeWWANReceived = 1 << 1,
    DRNetTrafficTypeWIFISent     = 1 << 2,
    DRNetTrafficTypeWIFIReceived = 1 << 3,
    DRNetTrafficTypeAWDLSent     = 1 << 4,
    DRNetTrafficTypeAWDLReceived = 1 << 5,
    
    DRNetTrafficTypeWWAN = DRNetTrafficTypeWWANSent | DRNetTrafficTypeWWANReceived,
    DRNetTrafficTypeWIFI = DRNetTrafficTypeWIFISent | DRNetTrafficTypeWIFIReceived,
    DRNetTrafficTypeAWDL = DRNetTrafficTypeAWDLSent | DRNetTrafficTypeAWDLReceived,
    
    DRNetTrafficTypeALL = DRNetTrafficTypeWWAN | DRNetTrafficTypeWIFI | DRNetTrafficTypeAWDL,
};

@interface UIDevice (drbox)

@property (nonatomic, readonly) BOOL dr_isPad;

@property (nonatomic, readonly) BOOL dr_isSimulator;

/// 判断当前设备是否已越狱
@property (nonatomic, readonly) BOOL dr_isJailbroken;

/// 判断当前设备是否可以打电话
@property (nonatomic, readonly) BOOL dr_canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

/// 当前设备的wifi ip address，例如：@"192.168.1.111"
@property (nullable, nonatomic, readonly) NSString *dr_ipAddressWIFI;

/// 当前设备的3G和蜂窝数据 ip addressm，例如：@"10.2.2.222"
@property (nullable, nonatomic, readonly) NSString *dr_ipAddressCell;

/// 当前设备总的磁盘空间大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_diskSpace;

/// 当前设备空闲磁盘大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_diskSpaceFree;

/// 当前设备已用空间大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_diskSpaceUsed;

/// 当前设备总的物理内存大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_memoryTotal;

/// 当前设备剩余物理内存大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_memoryFree;

/// 当前设备已用物理内存大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_memoryUsed;

/// 当前设备正在使用中，或者刚被使用过的内存大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_memoryActive;

/// 当前设备的内存中的数据是有效的，但是最近没有被使用过的内存大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_memoryInactive;

/// 当前设备系统核心占用内存大小（byte），-1：获取失败
@property (nonatomic, readonly) int64_t dr_memoryWired;

/// 当前设备可释放的内存大小（byte），-1：获取失败（主要是大对象或大内存块才可以使用的内存，此内存会在内存紧张的时候自动释放掉）
@property (nonatomic, readonly) int64_t dr_memoryPurgable;

/// 当前设备有效的cpu内核数
@property (nonatomic, readonly) NSUInteger dr_cpuCount;

/// 当前设备总的内核cpu使用量，1：表示100%；-1：获取失败
@property (nonatomic, readonly) float dr_cpuUsage;

/// 当前设备每个内核cpu使用量（array of NSNumbe），1：表示100%；nil：表示获取失败
@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *dr_cpuUsagePerProcessor;

/**
 获取当前网络的传输字节数
 
 @discussion 想要获取每秒钟的字节数，可以按照下面方式获取。
 @discussion
 uint64_t bytes = [[UIDevice currentDevice] dr_getNetworkTrafficBytes:DRNetTrafficTypeALL];
 @discussion
 NSTimeInterval time = CACurrentMediaTime();
 @discussion
 uint64_t bytesPerSecond = (bytes - _lastBytes) / (time - _lastTime); // 每秒字节数
 @discussion
 _lastBytes = bytes;
 @discussion
 _lastTime = time;
 */
- (uint64_t)dr_getNetworkTrafficBytes:(DRNetTrafficType)types;


/// 设备的唯一标示符
@property (nonatomic, readonly) NSString *dr_identifier;

@end

NS_ASSUME_NONNULL_END
