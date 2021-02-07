//
//  DRDeallocHook.m
//  drbox
//
//  Created by dr.box on 2020/8/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRDeallocHook.h"
#import "NSObject+drbox.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "DrboxMacro.h"

static const int dr_dealloc_observer_key;

@interface _DRDeallocObserver : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) DRDeallocHookBlock block;

+ (instancetype)observerWithTarget:(id)target selector:(SEL)aSelector;
+ (instancetype)observerWithBlock:(DRDeallocHookBlock)block;

@end
@implementation _DRDeallocObserver

+ (instancetype)observerWithTarget:(id)target
                          selector:(SEL)aSelector{
    _DRDeallocObserver *obs = [[_DRDeallocObserver alloc] init];
    obs.target = target;
    obs.selector = aSelector;
    return obs;
}

+ (instancetype)observerWithBlock:(DRDeallocHookBlock)block{
    _DRDeallocObserver *obs = [[_DRDeallocObserver alloc] init];
    obs.block = block;
    return obs;
}

@end

@interface DRDeallocHook (){
    
    NSMutableArray<_DRDeallocObserver *> *_observers;
}

@end

@implementation DRDeallocHook

+ (void)addDeallocHookToObject:(id)obj observer:(id)obs observerSelector:(SEL)aSelector{
    if (!obj) return;
    DRDeallocHook *hook = [obj dr_associateValueForKey:&dr_dealloc_observer_key];
    if (!hook) {
        hook = [DRDeallocHook alloc];
        [obj dr_setAssociateStrongValue:hook key:&dr_dealloc_observer_key];
        [self swizzleDeallocForObject:obj];
    }
    _DRDeallocObserver *observer = [_DRDeallocObserver observerWithTarget:obs
                                                                 selector:aSelector];
    [[hook observers] addObject:observer];
}

+ (void)addDeallocHookToObject:(id)obj withBlock:(DRDeallocHookBlock)block{
    if (!obj) return;
    DRDeallocHook *hook = [obj dr_associateValueForKey:&dr_dealloc_observer_key];
    if (!hook) {
        hook = [DRDeallocHook alloc];
        [obj dr_setAssociateStrongValue:hook key:&dr_dealloc_observer_key];
        [self swizzleDeallocForObject:obj];
    }
    _DRDeallocObserver *observer = [_DRDeallocObserver observerWithBlock:block];
    [[hook observers] addObject:observer];
}

#pragma mark - private

- (NSMutableArray<_DRDeallocObserver *> *)observers{
    if (!_observers) {
        _observers = [[NSMutableArray alloc] init];
    }
    return _observers;
}

- (void)execObserverWithHookObject:(id)hookObject{
    for (_DRDeallocObserver *obs in _observers) {
        if ([obs.target respondsToSelector:obs.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obs.target performSelector:obs.selector withObject:hookObject];
#pragma clang diagnostic pop
        }
        if (obs.block) obs.block(hookObject);
    }
    [_observers removeAllObjects];
}

+ (void)swizzleDeallocForObject:(id)obj{
    if (!obj) return;
    Class cls = [obj dr_instanceClassForHook];
    SEL deallocSelector = sel_registerName("dealloc");
    // 定义一个原始方法函数指针
    __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
    // 定义一个block，用于替换原始的dealloc方法实现
    id newDealloc = ^(__unsafe_unretained id receiver) {
        DRDeallocHook *hook = [receiver dr_associateValueForKey:&dr_dealloc_observer_key];
        if (hook) [hook execObserverWithHookObject:receiver];
        // 回调原始方法
        if (originalDealloc == NULL) {
            // cls的原始方法没有实现，调用父类的dealloc方法
            struct objc_super superInfo = {
                .receiver = receiver,
                .super_class = class_getSuperclass(cls)
            };
            void (*msgSendSuper)(struct objc_super *, SEL) = (__typeof__(msgSendSuper))objc_msgSendSuper;
            msgSendSuper(&superInfo, deallocSelector);
        }else{
            originalDealloc(receiver, deallocSelector);
        }
    };
    IMP newDeallocImp = imp_implementationWithBlock(newDealloc);
    if (!class_addMethod(cls, deallocSelector, newDeallocImp, "v@:")) {
        // cls的dealloc方法已经存在，被实现，替换dealloc的方法实现
        Method orgM = class_getInstanceMethod(cls, deallocSelector);
        originalDealloc = (__typeof__(originalDealloc))method_getImplementation(orgM);
        originalDealloc = (__typeof__(originalDealloc))method_setImplementation(orgM, newDeallocImp);
    }
}

@end
