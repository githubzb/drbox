//
//  CADisplayLink+drbox.h
//  drbox
//
//  Created by DHY on 2020/12/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CADisplayLink (drbox)

/**
 创建CADisplayLink，并立即执行（该CADisplayLink会随着target销毁自动注销）
 
 @return target==nil，返回nil
 */
+ (nullable instancetype)dr_scheduledDisplayLinkWithTarget:(id)target selector:(SEL)sel;
/**
 创建CADisplayLink，不会立即执行，需手动将该CADisplayLink添加到runloop中（该CADisplayLink会随着target销毁自动注销）
 
 @return target==nil，返回nil
 */
+ (nullable instancetype)dr_displayLinkWithTarget:(id)target selector:(SEL)sel;

@end

NS_ASSUME_NONNULL_END
