//
//  DRNavigationTool.h
//  drbox
//
//  Created by DHY on 2020/12/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRNavigationTool : NSObject

/// 获取当前显示的视图控制器
+ (UIViewController *)currentVisibleViewController;
/**
 跳转页面控制器
 
 @discussion
 如果当前显示的视图控制器不存在导航，采用present model跳转，反之push
 */
+ (void)openViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
