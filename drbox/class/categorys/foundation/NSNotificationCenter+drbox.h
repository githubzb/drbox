//
//  NSNotificationCenter+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/13.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (drbox)


/**
 添加通知观察者（无需removeObserver）
 
 @param observer 观察者对象（weak引用，无需考虑循环引用）
 @param aSelector 观察者执行方法
 @param aName 通知名称
 @param anObject 通知对应的对象
 */
+ (void)dr_addObserver:(id)observer
              selector:(SEL)aSelector
                  name:(nullable NSNotificationName)aName
                object:(nullable id)anObject;

+ (void)dr_postOnMainThread:(NSNotification *)notification;

+ (void)dr_postOnMainThread:(NSNotification *)notification waitUntilDone:(BOOL)wait;

+ (void)dr_postOnMainThreadWithName:(NSString *)name object:(nullable id)object;

+ (void)dr_postOnMainThreadWithName:(NSString *)name
                             object:(nullable id)object
                           userInfo:(nullable NSDictionary *)userInfo;

+ (void)dr_postOnMainThreadWithName:(NSString *)name
                             object:(nullable id)object
                           userInfo:(nullable NSDictionary *)userInfo
                      waitUntilDone:(BOOL)wait;

@end

NS_ASSUME_NONNULL_END
