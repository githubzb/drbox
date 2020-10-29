//
//  DRUnfairLock.h
//  drbox
//
//  Created by dr.box on 2020/8/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^DRLockBlock)(void);

#pragma mark - around
#define defineAroundReturnType(typeName, type) \
- (type)aroundReturn##typeName:(type (^)(void))block

#define defineAroundReturnTypeNullable(typeName, type) \
- (nullable type)aroundReturn##typeName:(type __nullable (^)(void))block

#pragma mark - tryAround
#define defineTryAroundReturnType(typeName, type) \
- (type)tryAroundReturn##typeName:(type (^)(void))block fail:(dispatch_block_t)failBlock

#define defineTryAroundReturnTypeNullable(typeName, type) \
- (nullable type)tryAroundReturn##typeName:(type __nullable (^)(void))block  fail:(dispatch_block_t)failBlock

@interface DRLock : NSObject

- (void)lock;
- (void)unlock;

/**
 加锁与解锁（block中的代码会被加锁，当block执行完毕，自动解锁）
 
 @param block 加锁代码块
 */
- (void)around:(dispatch_block_t)block;
defineAroundReturnTypeNullable(Id, id);
defineAroundReturnTypeNullable(Number, NSNumber *);
defineAroundReturnTypeNullable(String, NSString *);
defineAroundReturnTypeNullable(Data, NSData *);
defineAroundReturnTypeNullable(Array, NSArray *);
defineAroundReturnTypeNullable(Dictionary, NSDictionary *);
defineAroundReturnType(UInteger, NSUInteger);
defineAroundReturnType(Integer, NSInteger);
defineAroundReturnType(Int, int);
defineAroundReturnType(Double, double);
defineAroundReturnType(Float, float);
defineAroundReturnType(CGFloat, CGFloat);
defineAroundReturnType(Bool, BOOL);
defineAroundReturnType(Long, long);
defineAroundReturnType(LongLong, long long);

@end

@interface DRUnfairLock : DRLock

@end

@interface DRSemaphoreLock : DRLock

/**
 初始化信号锁
 
 @param value 初始信号量
 
 @return value < 0 return nil
 */
- (nullable instancetype)initWithSemaphoreValue:(long)value;

/// 初始化信号量为1的锁
+ (instancetype)defaultLock;

@end


@interface DRMutexLock : DRLock

- (int)trylock;

/**
 加锁与解锁（block中的代码会被加锁，当block执行完毕，自动解锁）
 
 @param block 加锁代码块
 @param failBlock 加锁失败的代码块
 */
- (void)tryAround:(dispatch_block_t)block fail:(dispatch_block_t)failBlock;
defineTryAroundReturnTypeNullable(Id, id);
defineTryAroundReturnTypeNullable(Number, NSNumber *);
defineTryAroundReturnTypeNullable(String, NSString *);
defineTryAroundReturnTypeNullable(Data, NSData *);
defineTryAroundReturnTypeNullable(Array, NSArray *);
defineTryAroundReturnTypeNullable(Dictionary, NSDictionary *);
defineTryAroundReturnType(UInteger, NSUInteger);
defineTryAroundReturnType(Integer, NSInteger);
defineTryAroundReturnType(Int, int);
defineTryAroundReturnType(Double, double);
defineTryAroundReturnType(Float, float);
defineTryAroundReturnType(CGFloat, CGFloat);
defineTryAroundReturnType(Bool, BOOL);
defineTryAroundReturnType(Long, long);
defineTryAroundReturnType(LongLong, long long);

@end

NS_ASSUME_NONNULL_END
