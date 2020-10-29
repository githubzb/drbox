//
//  DRDiskCache.h
//  drbox
//
//  Created by dr.box on 2020/8/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRDiskCache : NSObject

@property (nullable, copy) NSString *name;

/// 缓存文件的所在路径
@property (readonly) NSString *path;

/**
 缓存对象序列化后的size大于这个值，该对象将以文件的形式存储，反之存储在数据库中。
 当这个值==NSUIntegerMax时，对象会被存储在数据库中；
 当这个值==0是，对象将以文件的形式存储
 默认值：20KB
 */
@property (readonly) NSUInteger inlineThreshold;

/**
 自定义缓存对象的序列化方案，默认序列化方案采用NSKeyedArchiver实现
 */
@property (nullable, copy) NSData *(^customArchiveBlock)(id object);

/**
 自定义缓存对象的返序列化方案，默认返序列化方案采用NSKeyedUnarchiver实现
 */
@property (nullable, copy) id (^customUnarchiveBlock)(NSData *data);

/**
 当缓存对象需要以文件的形式存储的时候调用该方法，来提供存储文件时的文件名
 默认采用md5(key)作为存储文件的文件名
 */
@property (nullable, copy) NSString *(^customFileNameBlock)(NSString *key);

/// 缓存对象数量最大限制
@property NSUInteger countLimit;

/// 缓存对象成本最大限制
@property NSUInteger costLimit;

/// 缓存对象最大有效期（单位：秒）
@property NSTimeInterval ageLimit;

/// 磁盘缓存维护的最低的空闲空间大小，如果当前磁盘空闲空间大小<该值，缓存将删除一部分
@property NSUInteger freeDiskSpaceLimit;

/**
 是否输出错误日志，默认YES
 */
@property BOOL errorLogsEnabled;


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 创建磁盘缓存对象
 
 @param path 缓存文件所在路径，数据库、文件等相关文件或目录都会存储在该路径下
 
 @return 当path.length==0或者超出长度限制，返回nil
 */
- (nullable instancetype)initWithPath:(NSString *)path;

/**
 创建磁盘缓存对象
 
 @param path 缓存文件所在路径，数据库、文件等相关文件或目录都会存储在该路径下
 @param threshold 参考inlineThreshold属性注释
 
 @return 当path.length==0或者超出长度限制，返回nil
 */
- (nullable instancetype)initWithPath:(NSString *)path
                      inlineThreshold:(NSUInteger)threshold NS_DESIGNATED_INITIALIZER;


/// 判断缓存中是否存在某个缓存对象
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 异步判断缓存中是否存在某个缓存对象
 
 @param key 缓存对象的唯一key，如果==nil，contains==NO
 @param block 回调函数
 */
- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block;

/// 获取缓存对象
- (nullable id<NSCoding>)objectForKey:(NSString *)key;

/// 异步获取缓存对象
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> _Nullable object))block;

/// 添加或设置缓存对象
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

/**
 异步添加或设置缓存对象
 
 @param object 缓存对象
 @param block 添加或设置完成的回到
 */
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key finishBlock:(nullable void(^)(void))block;

/// 删除缓存对象
- (void)removeObjectForKey:(NSString *)key;

/**
 异步删除缓存对象
 
 @param key 缓存对象唯一key
 @param block 删除完成的回调
 */
- (void)removeObjectForKey:(NSString *)key finishBlock:(nullable void(^)(NSString *key))block;

/// 删除所有缓存对象
- (void)removeAllObjects;

/**
 异步删除所有缓存对象
 
 @param block 删除完成回到
 */
- (void)removeAllObjectsWithFinishBlock:(nullable void(^)(void))block;

/**
 异步删除所有缓存对象
 
 @param progress 删除缓存的进度
 @param stop 删除终止回调
 */
- (void)removeAllObjectsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                                stopBlock:(nullable void(^)(BOOL finished))stop;


/// 获取缓存的总个数
- (NSInteger)totalCount;

/// 异步获取缓存总个数
- (void)totalCountWithBlock:(void(^)(NSInteger totalCount))block;

/// 获取缓存总成本
- (NSInteger)totalCost;

/// 异步获取缓存总成本
- (void)totalCostWithBlock:(void(^)(NSInteger totalCost))block;

/**
 删除缓存对象到指定数量

 @param count 缓存中剩余的对象数量
*/
- (void)removeObjectToCount:(NSUInteger)count;

/**
 异步删除缓存对象到指定数量

 @param count 缓存中剩余的对象数量
 @param block 删除完成的回调
 */
- (void)removeObjectToCount:(NSUInteger)count finishBlock:(nullable void(^)(void))block;

/**
 删除缓存对象到指定成本

 @param cost 缓存中剩余的对象成本
*/
- (void)removeObjectToCost:(NSUInteger)cost;

/**
 异步删除缓存对象到指定成本

 @param cost 缓存中剩余的对象成本
 @param block 删除完成回调
*/
- (void)removeObjectToCost:(NSUInteger)cost finishBlock:(nullable void(^)(void))block;

/**
 删除指定时间内的缓存对象

 @param age 指定的时间（单位：秒），缓存时间小于age的缓存对象，都会被删除
*/
- (void)removeObjectToAge:(NSTimeInterval)age;

/**
 异步删除指定时间内的缓存对象

 @param age 指定的时间（单位：秒），缓存时间小于age的缓存对象，都会被删除
 @param block 删除完成回调
*/
- (void)removeObjectToAge:(NSTimeInterval)age finishBlock:(nullable void(^)(void))block;

/**
 清理超出限制的缓存
 */
- (void)cleanLimit;
/**
 清理超出限制的缓存
 
 @param block 清理完成回调
*/
- (void)cleanLimitWithFinishBlock:(nullable dispatch_block_t)block;



/// 获取object对象的扩展数据
+ (nullable NSData *)getExtendedDataFromObject:(id)object;

/**
 设置object对象的扩展数据
 
 @param extendedData object的扩展数据
 @param object 需要添加扩展数据的对象
 */
+ (void)setExtendedData:(nullable NSData *)extendedData toObject:(id)object;

@end

NS_ASSUME_NONNULL_END
