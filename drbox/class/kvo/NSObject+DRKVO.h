//
//  NSObject+DRKVO.h
//  drbox
//
//  Created by dr.box on 2020/11/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define DRKVOAction(obj, keyPath, aTarget, method) [obj dr_observeKeyPath:keyPath target:aTarget action:@selector(method)]
#define DRKVOBlock(obj, keyPath, block) [obj dr_observeKeyPath:keyPath callback:block]

@interface NSObject (DRKVO)

/**
 观察当前类的keyPath值的变化，并通过target-action回调
 
 @param keyPath 当前类的keyPath
 @param target 回调的target
 @param action 回调的action
 
 @return 观察成功：YES；失败：NO（例如：target-action不匹配）
 */
- (BOOL)dr_observeKeyPath:(NSString *)keyPath target:(id)target action:(SEL)action;

/**
 观察当前类的keyPath值的变化，并通过target-action回调
 
 @param keyPath 当前类的keyPath
 @param callback 回调block（注意：必须是block类型，否则添加失败；第一个参数为newValue，第二个为：oldValue）
 
 @return 观察成功：YES；失败：NO（例如：callback==nil）
 */
- (BOOL)dr_observeKeyPath:(NSString *)keyPath callback:(id)callback;

@end

NS_ASSUME_NONNULL_END
