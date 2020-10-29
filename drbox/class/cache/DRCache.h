//
//  DRCache.h
//  drbox
//
//  Created by dr.box on 2020/8/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRMemoryCache.h"
#import "DRDiskCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRCache : NSObject

/// 缓存的名字，作为缓存目录的名称
@property (copy, readonly) NSString *name;

@property (strong, readonly) DRMemoryCache *memoryCache;

@property (strong, readonly) DRDiskCache *diskCache;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithName:(NSString *)name;

- (nullable instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

+ (nullable instancetype)cacheWithName:(NSString *)name;

+ (nullable instancetype)cacheWithPath:(NSString *)path;

/// 判断key对应的缓存是否存在
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 判断key对应的缓存是否存在（异步调用）
 
 @param key 缓存对象对应的唯一key
 @param block 回调block，异步线程中回调
 */
- (void)containsObjectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key, BOOL contains))block;

/// 获取key对应的缓存对象
- (nullable id<NSCoding>)objectForKey:(NSString *)key;

/**
 获取key对应的缓存对象（异步调用）
 
 @param key 缓存对象对应的唯一key
 @param block 回调block，异步线程中回调
 */
- (void)objectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key, id<NSCoding> object))block;

/**
 添加或设置缓存对象（如果已存在，更新缓存）
 
 @param object 缓存对象，如果为nil，删除对应的缓存
 @param key 缓存对象对应的唯一key
 */
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

/**
 添加或设置缓存对象（如果已存在，更新缓存）（异步调用）

 @param object 缓存对象，如果为nil，删除对应的缓存
 @param key 缓存对象对应的唯一key
 @param block 完成回调，异步线程中回调
*/
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key withBlock:(nullable void(^)(void))block;

/// 删除key对应的缓存
- (void)removeObjectForKey:(NSString *)key;

/**
 删除key对应的缓存（异步调用）
 
 @param key 缓存对象对应的唯一key
 @param block 删除完成回调，异步线程中回调
 */
- (void)removeObjectForKey:(NSString *)key withBlock:(nullable void(^)(NSString *key))block;

/// 删除所有缓存
- (void)removeAllObjects;

/**
 删除所有缓存（异步调用）
 
 @param block 删除完成回调，异步线程中回调
 */
- (void)removeAllObjectsWithBlock:(void(^)(void))block;

/**
 删除所有缓存（异步调用）
 
 @param progress 删除进度，异步线程中回调
 @param stop 删除终止回调，异步线程中回调
 */
- (void)removeAllObjectsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                                 stopBlock:(nullable void(^)(BOOL finished))stop;

@end

NS_ASSUME_NONNULL_END
