//
//  NSTimer+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSTimer+drbox.h"
#import "NSObject+drbox.h"
#import "DRDeallocHook.h"
#import "DRWeakProxy.h"

@implementation NSTimer (drbox)

+ (NSTimer *)dr_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                      userInfo:(id)userInfo
                                       repeats:(BOOL)yesOrNo{
    if (!aTarget) return nil;
    NSTimer *timer = [self _dr_getTimerForTarget:aTarget];
    if (timer) {
        [timer invalidate];
    }
    DRWeakProxy *weakProxy = [DRWeakProxy weakProxyForObject:aTarget];
    timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                             target:weakProxy
                                           selector:aSelector
                                           userInfo:userInfo
                                            repeats:yesOrNo];
    [self _dr_setTimer:timer forTarget:aTarget];
    [DRDeallocHook addDeallocHookToObject:aTarget
                                 observer:timer
                         observerSelector:@selector(invalidate)];
    return timer;
}

+ (NSTimer *)dr_scheduledNewTimerWithTimeInterval:(NSTimeInterval)ti
                                           target:(id)aTarget
                                         selector:(SEL)aSelector
                                         userInfo:(id)userInfo
                                          repeats:(BOOL)yesOrNo{
    if (!aTarget) return nil;
    DRWeakProxy *weakProxy = [DRWeakProxy weakProxyForObject:aTarget];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                                      target:weakProxy
                                                    selector:aSelector
                                                    userInfo:userInfo
                                                     repeats:yesOrNo];
    [DRDeallocHook addDeallocHookToObject:aTarget
                                 observer:timer
                         observerSelector:@selector(invalidate)];
    return timer;
}

+ (NSTimer *)dr_timerWithTimeInterval:(NSTimeInterval)ti
                               target:(id)aTarget
                             selector:(SEL)aSelector
                             userInfo:(id)userInfo
                              repeats:(BOOL)yesOrNo{
    if (!aTarget) return nil;
    NSTimer *timer = [self _dr_getTimerForTarget:aTarget];
    if (timer) {
        [timer invalidate];
    }
    DRWeakProxy *weakProxy = [DRWeakProxy weakProxyForObject:aTarget];
    timer = [NSTimer timerWithTimeInterval:ti
                                    target:weakProxy
                                  selector:aSelector
                                  userInfo:userInfo
                                   repeats:yesOrNo];
    [self _dr_setTimer:timer forTarget:aTarget];
    [DRDeallocHook addDeallocHookToObject:aTarget
                                 observer:timer
                         observerSelector:@selector(invalidate)];
    return timer;
}

+ (NSTimer *)dr_timerNewWithTimeInterval:(NSTimeInterval)ti
                                  target:(id)aTarget
                                selector:(SEL)aSelector
                                userInfo:(id)userInfo
                                 repeats:(BOOL)yesOrNo{
    if (!aTarget) return nil;
    DRWeakProxy *weakProxy = [DRWeakProxy weakProxyForObject:aTarget];
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:weakProxy
                                           selector:aSelector
                                           userInfo:userInfo
                                            repeats:yesOrNo];
    [DRDeallocHook addDeallocHookToObject:aTarget
                                 observer:timer
                         observerSelector:@selector(invalidate)];
    return timer;
}


+ (NSTimer *)dr_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         block:(DRTimerBlock)block
                                       repeats:(BOOL)yesOrNo{
    return [NSTimer scheduledTimerWithTimeInterval:ti
                                            target:self
                                          selector:@selector(_dr_ExecBlock:)
                                          userInfo:[block copy]
                                           repeats:yesOrNo];
}

+ (NSTimer *)dr_timerWithTimeInterval:(NSTimeInterval)ti
                                block:(DRTimerBlock)block
                              repeats:(BOOL)yesOrNo{
    return [NSTimer timerWithTimeInterval:ti
                                   target:self
                                 selector:@selector(_dr_ExecBlock:)
                                 userInfo:[block copy]
                                  repeats:yesOrNo];
}


#pragma mark - private
+ (void)_dr_ExecBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}
+ (NSTimer *)_dr_getTimerForTarget:(id)target{
    if (!target) return nil;
    return [target dr_associateValueForKey:@selector(_dr_getTimerForTarget:)];
}
+ (void)_dr_setTimer:(NSTimer *)timer forTarget:(id)target{
    [target dr_setAssociateStrongValue:timer key:@selector(_dr_getTimerForTarget:)];
}

@end
