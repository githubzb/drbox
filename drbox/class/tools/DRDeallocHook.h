//
//  DRDeallocHook.h
//  drbox
//
//  Created by dr.box on 2020/8/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// dealloc回调block，hookObj：被hook的对象
typedef void(^DRDeallocHookBlock)(id hookObj);

@interface DRDeallocHook : NSProxy

/// 判断obj实例是否已经hook
+ (BOOL)isHookForObject:(id)obj;

/**
 hook obj实例的dealloc方法
 
 @param obj 被hook的实例对象
 @param obs dealloc的观察者
 @param aSelector 观察者的执行方法
 */
+ (void)addDeallocHookToObject:(id)obj observer:(id)obs observerSelector:(SEL)aSelector;

/**
 hook obj实例的dealloc方法
 
 @param obj 被hook的实例对象
 @param block dealloc调用的回调
 */
+ (void)addDeallocHookToObject:(id)obj withBlock:(DRDeallocHookBlock)block;

@end

NS_ASSUME_NONNULL_END
