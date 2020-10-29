//
//  DRThreadPool.h
//  drbox
//
//  Created by dr.box on 2020/7/31.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrboxCommonMacro.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRThreadPool : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 初始化线程池
 
 @param name 线程池名字（也是池子里的线程label）
 @param queueCount 线程池中线程的个数，范围在[1,32]
 @param qos 线程的优先级
 
 @return DRThreadPool，如果queueCount>32或<=0，return nil
 */
- (nullable instancetype)initWithName:(nullable NSString *)name
                           queueCount:(NSUInteger)queueCount
                                  qos:(NSQualityOfService)qos;

/// 线程池的名字（也是池子里的线程label）
@property (nullable, nonatomic, readonly) NSString *name;
/// 从线程池中获取队列线程
@property (nonatomic, readonly) dispatch_queue_t queue;

/// 根据线程级别创建默认的线程池（以单例的形式保存，不同级别的线程，对应不同的池子）
+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;

@end

DR_EXTERN_C_BEGIN
/// 创建指定优先级的dispatch_queue_t线程队列
extern dispatch_queue_t DRCreateDispatchQueue(const char *_Nullable label, NSQualityOfService qos);

/// 从默认线程池中取指定优先级的dispatch_queue_t
extern dispatch_queue_t DRThreadPoolGetQueue(NSQualityOfService qos);

/// 默认级别线程中执行block
extern void dispatch_async_on_default_queue(dispatch_block_t block);
/// NSQualityOfServiceUserInteractive级别线程中执行block
extern void dispatch_async_on_userInteractive_queue(dispatch_block_t block);
/// NSQualityOfServiceUserInitiated级别线程中执行block
extern void dispatch_async_on_userInitiated_queue(dispatch_block_t block);
/// NSQualityOfServiceUtility级别线程中执行block
extern void dispatch_async_on_utility_queue(dispatch_block_t block);
/// NSQualityOfServiceBackground级别线程中执行block
extern void dispatch_async_on_background_queue(dispatch_block_t block);

/**
 延时执行任务

 @param delayTime 延迟时间（单位：秒）
 @param qos block执行线程的优先级
 @param block 执行代码块，在指定qos等级的线程中执行
*/
extern void dispatch_after_on_queue(NSTimeInterval delayTime, NSQualityOfService qos, dispatch_block_t block);

DR_EXTERN_C_END

NS_ASSUME_NONNULL_END
