//
//  NSTimer+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DRTimerBlock)(NSTimer *timer);

@interface NSTimer (drbox)

/**
 给当前aTarget添加timer定时器，并立即执行（此timer会在aTarget释放的时候自动调用invalidate）
 
 @discussion
 注意：为同一个aTarget添加定时器，最后一次添加的timer会覆盖前一个timer（也就是该方法只能为aTarget创建唯一的一个timer）
 
 @return 如果aTarget==nil，返回nil
 */
+ (NSTimer *)dr_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)yesOrNo;

/**
 创建定时器，并立即执行（此timer会在aTarget释放的时候自动调用invalidate）
 
 @discussion
 注意：每次都会创建新的Timer，不会覆盖之前创建的Timer
 
 @return 如果aTarget==nil，返回nil
 */
+ (NSTimer *)dr_scheduledNewTimerWithTimeInterval:(NSTimeInterval)ti
                                           target:(id)aTarget
                                         selector:(SEL)aSelector
                                         userInfo:(nullable id)userInfo
                                          repeats:(BOOL)yesOrNo;

/**
 给当前aTarget添加timer定时器（此timer会在aTarget释放的时候自动调用invalidate）
 注意：为同一个aTarget添加定时器，最后一次添加的timer会覆盖前一个timer
 
 @discussion
 另注：使用时，需要将其添加到runloop中，否则不会执行aSelector。例如：[[NSRunLoop currentRunLoop] addTimer: forMode:]
 */
+ (NSTimer *)dr_timerWithTimeInterval:(NSTimeInterval)ti
                               target:(id)aTarget
                             selector:(SEL)aSelector
                             userInfo:(nullable id)userInfo
                              repeats:(BOOL)yesOrNo;
/**
 创建定时器（此timer会在aTarget释放的时候自动调用invalidate）
 注意：每次都会创建新的Timer，不会覆盖之前创建的Timer
 
 @discussion
 另注：使用时，需要将其添加到runloop中，否则不会执行aSelector。例如：[[NSRunLoop currentRunLoop] addTimer: forMode:]
 */
+ (NSTimer *)dr_timerNewWithTimeInterval:(NSTimeInterval)ti
                                  target:(id)aTarget
                                selector:(SEL)aSelector
                                userInfo:(nullable id)userInfo
                                 repeats:(BOOL)yesOrNo;

/**
 创建定时器，并立即执行（注意：此timer需要自己维护其生命周期，不需要时，需要在block中调用[timer invalidate]）
 */
+ (NSTimer *)dr_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         block:(DRTimerBlock)block
                                       repeats:(BOOL)yesOrNo;

/**
 创建定时器（注意：此timer需要自己维护其生命周期，不需要时，需要在block中调用[timer invalidate]）
 
 @discussion
 另注：使用时，需要将其添加到runloop中，否则不会执行block。例如：[[NSRunLoop currentRunLoop] addTimer: forMode:]
*/
+ (NSTimer *)dr_timerWithTimeInterval:(NSTimeInterval)ti
                                block:(DRTimerBlock)block
                              repeats:(BOOL)yesOrNo;

@end

NS_ASSUME_NONNULL_END
