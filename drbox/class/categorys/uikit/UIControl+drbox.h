//
//  UIControl+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/29.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DRControlEventBlock)(id sender);

@interface UIControl (drbox)

/// 删除所有设置的target，包括block
- (void)dr_removeAllTargets;

/**
 设置事件（设置之前会清空之前添加的所有targetAction）
 
 @param target 事件执行者
 @param action 事件方法名
 @param controlEvents 事件类型
 */
- (void)dr_setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 添加block事件回调
 
 @param block 事件回调
 @param controlEvents 事件类型
 */
- (void)dr_addActionBlock:(DRControlEventBlock)block forControlEvents:(UIControlEvents)controlEvents;

/**
 设置block事件回调（设置之前会清空之前添加的所有block事件回调）
 
 @param block 事件回调
 @param controlEvents 事件类型
 */
- (void)dr_setActionBlock:(DRControlEventBlock)block forControlEvents:(UIControlEvents)controlEvents;

/**
 删除指定事件类型的block
 
 @param controlEvents 事件类型
 */
- (void)dr_removeAllActionBlocksForControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
