//
//  DRUnfairLock.m
//  drbox
//
//  Created by dr.box on 2020/8/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRLock.h"
#import <libkern/OSSpinLockDeprecated.h>
#import <os/lock.h>
#import "DrboxMacro.h"

#define impAroundReturnType(typeName, type, defaultReturnValue) \
- (type)aroundReturn##typeName:(type (^)(void))block{ \
    if (!block) return defaultReturnValue; \
    [self lock]; \
    @onDefer{ [self unlock]; }; \
    return block(); \
}

#define impTryAroundReturnType(typeName, type, defaultReturnValue) \
- (type)tryAroundReturn##typeName:(type (^)(void))block fail:(dispatch_block_t)failBlock{ \
    if (!block) return defaultReturnValue; \
    __block int res = -1; \
    @onDefer{ if (res == 0) [self unlock]; NSLog(@"----unlock"); }; \
    if ((res = [self trylock]) == 0){ \
        return block();    \
    }else{ \
        failBlock(); \
        return defaultReturnValue; \
    } \
}

@implementation DRLock

- (void)lock{
    NSAssert(NO, @"DRLock.lock需要子类实现！");
}

- (void)unlock{
    NSAssert(NO, @"DRLock.unlock需要子类实现！");
}

- (void)around:(dispatch_block_t)block{
    if (!block) return;
    [self lock];
    block();
    [self unlock];
}

impAroundReturnType(Id, id, nil)
impAroundReturnType(Number, NSNumber *, nil)
impAroundReturnType(String, NSString *, nil);
impAroundReturnType(Data, NSData *, nil);
impAroundReturnType(Array, NSArray *, nil);
impAroundReturnType(Dictionary, NSDictionary *, nil);
impAroundReturnType(UInteger, NSUInteger, NSNotFound)
impAroundReturnType(Integer, NSInteger, 0)
impAroundReturnType(Int, int, 0)
impAroundReturnType(Double, double, 0.0)
impAroundReturnType(Float, float, 0.0)
impAroundReturnType(CGFloat, CGFloat, 0.0)
impAroundReturnType(Bool, BOOL, NO)
impAroundReturnType(Long, long, 0)
impAroundReturnType(LongLong, long long, 0)

@end

@interface DRUnfairLock () {
    
    os_unfair_lock _unfairLock API_AVAILABLE(ios(10.0));
    OSSpinLock _spinLock;
}

@end

@implementation DRUnfairLock

- (instancetype)init{
    self = [super init];
    if (self) {
        if (@available(iOS 10.0, *)) {
            _unfairLock = OS_UNFAIR_LOCK_INIT;
        } else {
            _spinLock = OS_SPINLOCK_INIT;
        }
    }
    return self;
}

- (void)lock{
    if (@available(iOS 10.0, *)) {
        os_unfair_lock_lock(&_unfairLock);
    } else {
        OSSpinLockLock(&_spinLock);
    }
}

- (void)unlock{
    if (@available(iOS 10.0, *)) {
        os_unfair_lock_unlock(&_unfairLock);
    } else {
        OSSpinLockUnlock(&_spinLock);
    }
}

@end


@interface DRSemaphoreLock (){
    
    dispatch_semaphore_t _lock;
}

@end
@implementation DRSemaphoreLock

- (instancetype)init{
    return [self initWithSemaphoreValue:1];
}

- (instancetype)initWithSemaphoreValue:(long)value{
    if (value < 0) return nil;
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(value);
    }
    return self;
}

+ (instancetype)defaultLock{
    return [[DRSemaphoreLock alloc] init];
}

- (void)lock{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unlock{
    dispatch_semaphore_signal(_lock);
}

@end


@interface DRMutexLock (){
    pthread_mutex_t _lock;
}

@end
@implementation DRMutexLock

- (void)dealloc{
    pthread_mutex_destroy(&_lock);
}

- (instancetype)init{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (int)trylock{
    return pthread_mutex_trylock(&_lock);
}

- (void)lock{
    pthread_mutex_lock(&_lock);
}

- (void)unlock{
    pthread_mutex_unlock(&_lock);
}

- (void)tryAround:(dispatch_block_t)block fail:(dispatch_block_t)failBlock{
    if (!block) return;
    if ([self trylock] == 0) {
        block();
        [self unlock];
    }else{
        failBlock();
    }
}

impTryAroundReturnType(Id, id, nil)
impTryAroundReturnType(Number, NSNumber *, nil)
impTryAroundReturnType(String, NSString *, nil);
impTryAroundReturnType(Data, NSData *, nil);
impTryAroundReturnType(Array, NSArray *, nil);
impTryAroundReturnType(Dictionary, NSDictionary *, nil);
impTryAroundReturnType(UInteger, NSUInteger, NSNotFound)
impTryAroundReturnType(Integer, NSInteger, 0)
impTryAroundReturnType(Int, int, 0)
impTryAroundReturnType(Double, double, 0.0)
impTryAroundReturnType(Float, float, 0.0)
impTryAroundReturnType(CGFloat, CGFloat, 0.0)
impTryAroundReturnType(Bool, BOOL, NO)
impTryAroundReturnType(Long, long, 0)
impTryAroundReturnType(LongLong, long long, 0)

@end
