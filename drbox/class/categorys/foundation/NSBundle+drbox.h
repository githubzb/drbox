//
//  NSBundle+drbox.h
//  drbox
//
//  Created by dr.box on 2020/9/19.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (drbox)

@property (nonatomic, readonly, class) NSString *dr_appVersion;
@property (nonatomic, readonly, class) NSString *dr_bundleIdentifier;
@property (nonatomic, readonly, class) NSString *dr_bundleName;
@property (nonatomic, readonly, class) NSString *dr_displayName;
/**
 当前app支持的设备方向，方向是UIInterfaceOrientation的枚举字符串格式，
 可以通过+dr_convertOrientationWithString:转换成对应的枚举
 */
@property (nonatomic, readonly, class) NSArray<NSString *> *dr_supportedInterfaceOrientations;

/**
 根据UIInterfaceOrientation枚举对应的字符串形式，转换成对应的枚举类型
 */
+ (UIInterfaceOrientation)dr_convertOrientationWithString:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
