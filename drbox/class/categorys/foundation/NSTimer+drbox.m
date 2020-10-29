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

static const int dr_timer_key;

@interface _DRWeakProxy : NSProxy

@property (nonatomic, weak) id target;

+ (instancetype)weakProxyForObject:(id)targetObject;

@end

@implementation _DRWeakProxy

+ (instancetype)weakProxyForObject:(id)targetObject{
    if (!targetObject) return nil;
    _DRWeakProxy *proxy = [_DRWeakProxy alloc];
    proxy.target = targetObject;
    return proxy;
}


#pragma mark - Forwarding Messages

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // 当target==nil的时候，return 0/NULL/nil.
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end

@implementation NSTimer (drbox)

+ (NSTimer *)dr_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                      userInfo:(id)userInfo
                                       repeats:(BOOL)yesOrNo{
    if (!aTarget) return nil;
    NSTimer *timer = [aTarget dr_associateValueForKey:&dr_timer_key];
    if (timer) {
        [timer invalidate];
    }
    _DRWeakProxy *weakProxy = [_DRWeakProxy weakProxyForObject:aTarget];
    timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                             target:weakProxy
                                           selector:aSelector
                                           userInfo:userInfo
                                            repeats:yesOrNo];
    [aTarget dr_setAssociateStrongValue:timer key:&dr_timer_key];
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
    NSTimer *timer = [aTarget dr_associateValueForKey:&dr_timer_key];
    if (timer) {
        [timer invalidate];
    }
    _DRWeakProxy *weakProxy = [_DRWeakProxy weakProxyForObject:aTarget];
    timer = [NSTimer timerWithTimeInterval:ti
                                    target:weakProxy
                                  selector:aSelector
                                  userInfo:userInfo
                                   repeats:yesOrNo];
    [aTarget dr_setAssociateStrongValue:timer key:&dr_timer_key];
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

@end
