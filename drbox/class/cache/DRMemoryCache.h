//
//  DRMemoryCache.h
//  drbox
//
//  Created by dr.box on 2020/8/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRMemoryCache : NSObject

@property (nullable, copy) NSString *name;

/// 缓存对象总数量
@property (readonly) NSUInteger totalCount;

/// 缓存对象总成本
@property (readonly) NSUInteger totalCost;

/// 缓存对象数量最大限制
@property NSUInteger countLimit;

/// 缓存对象成本最大限制
@property NSUInteger costLimit;

/// 缓存对象最大有效期（单位：秒）
@property NSTimeInterval ageLimit;

/**
 收到内存警告的回调，可以按照自己实际情况处理缓存，如果没有实现回调，默认会删除所有缓存。
 */
@property (nullable, copy) void(^didReceiveMemoryWarningBlock)(DRMemoryCache *cache);

/**
 app进入后台回调，可以按照自己实际情况处理缓存，如果没有实现回调，默认会清理过期的缓存对象。
 */
@property (nullable, copy) void(^didEnterBackgroundBlock)(DRMemoryCache *cache);

/// 是否在主线程中释放缓存对象，默认：NO
@property BOOL releaseOnMainThread;

/// 判断缓存中是否存在某个缓存对象
- (BOOL)containsObjectForKey:(id)key;

/// 从缓存中获取缓存对象
- (nullable id)objectForKey:(id)key;

/**
 向缓存中添加对象
 
 @param object 缓存对象，如果==nil，并且key在缓存中存在，将删除key对应的缓存对象
 @param key 缓存对象对应的唯一key
 */
- (void)setObject:(nullable id)object forKey:(id)key;

/**
 向缓存中添加对象
 
 @param object 缓存对象，如果==nil，并且key在缓存中存在，将删除key对应的缓存对象
 @param key 缓存对象对应的唯一key
 @param cost object对应的成本，例如：object是image对象，cost可以是image的内存大小
 */
- (void)setObject:(nullable id)object forKey:(id)key withCost:(NSUInteger)cost;

/// 删除key对应的缓存对象
- (void)removeObjectForKey:(id)key;

/// 删除缓存中的所有对象
- (void)removeAllObjects;

/**
 删除缓存对象到指定数量
 
 @param count 缓存中剩余的对象数量
 */
- (void)removeObjectToCount:(NSUInteger)count;

/**
 删除缓存对象到指定成本
 
 @param cost 缓存中剩余的对象成本
 */
- (void)removeObjectToCost:(NSUInteger)cost;

/**
 删除指定时间内的缓存对象
 
 @param age 指定的时间（单位：秒），缓存时间小于age的缓存对象，都会被删除
 */
- (void)removeObjectToAge:(NSTimeInterval)age;

@end

NS_ASSUME_NONNULL_END
