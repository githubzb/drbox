//
//  DRKVStorage.h
//  drbox
//
//  Created by dr.box on 2020/8/8.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRKVStorageItem : NSObject

/// 缓存对象的key
@property (nonatomic, strong) NSString *key;
/// 缓存对象序列化值（与表没有映射关系）
@property (nonatomic, strong) NSData *value;
/// value对应序列化前的类的名字
@property (nonatomic, copy) NSString *valueClassName;
/// 用于存储的缓存对象序列化值
@property (nullable, nonatomic, strong) NSData *data;
/// 缓存对象存储到磁盘的文件名
@property (nullable, nonatomic, strong) NSString *fileName;
/// 缓存对象序列化值的大小bytes
@property (nonatomic) int size;
/// 缓存对象创建时间
@property (nonatomic) int creatTime;
/// 缓存对象最后一次访问时间
@property (nonatomic) int lastAccessTime;
/// 缓存对象扩展数据
@property (nullable, nonatomic, strong) NSData *extendedData;

@end

typedef NS_ENUM(NSUInteger, DRKVStorageType) {
    
    /// 将value值以文件的形式存储
    DRKVStorageTypeFile = 0,
    
    /// 将value值存储在数据库中
    DRKVStorageTypeSQLite = 1,
    
    /// 根据value.size大小，选择性的存储在数据库或者文件磁盘
    DRKVStorageTypeMixed = 2,
};

@interface DRKVStorage : NSObject

/// 缓存所在路径
@property (nonatomic, readonly) NSString *path;
/// 存储类型
@property (nonatomic, readonly) DRKVStorageType type;
/// 是否打印error日志，默认：YES
@property (nonatomic) BOOL errorLogsEnabled;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 初始化存储对象
 
 @param path 存储路径
 @param type 存储类型
 
 @return path.length==0或者>PATH_MAX - 64返回nil，type超出enum范围，返回nil
 */
- (nullable instancetype)initWithPath:(NSString *)path type:(DRKVStorageType)type NS_DESIGNATED_INITIALIZER;

/**
 保存缓存对象
 
 @param item 保存对象（注意：fileName非空：缓存对象以文件形式保存；为空：缓存对象保存在数据库中）
 
 @return 保存成功：YES
 */
- (BOOL)saveItem:(DRKVStorageItem *)item;

/**
 保存缓存对象
 
 @param key 缓存对象对应的唯一key
 @param value 缓存对象序列化值
 @param className value对应的序列化前的class名称
 
 @return 成功返回：YES
 */
- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
         valueClassName:(NSString *)className;

/**
 保存缓存对象
 
 @param key 缓存对象对应的唯一key
 @param value 缓存对象序列化值
 @param className value对应的序列化前的class名称
 @param filename 缓存对象存储在磁盘的文件名
 @param extendedData 缓存对象的扩展值
 
 @return 成功返回：YES
 */
- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
         valueClassName:(NSString *)className
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData;

/// 删除缓存对象
- (BOOL)removeItemForKey:(NSString *)key;

/// 删除多个缓存对象
- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;

/// 删除size大于size的缓存对象
- (BOOL)removeItemsLargerThanSize:(int)size;

/// 删除lastAccessTime<time的缓存对象
- (BOOL)removeItemsEarlierThanTime:(int)time;

/// 删除缓存对象，直到缓存总size<=maxSize
- (BOOL)removeItemsToFitSize:(int)maxSize;

/// 删除缓存对象，直到缓存总个数<=maxCount
- (BOOL)removeItemsToFitCount:(int)maxCount;

/// 删除所有缓存对象
- (BOOL)removeAllItems;

/**
 删除所有缓存对象
 
 @param progress 删除进度, removedCount：删除的个数；totalCount总个数
 @param stop 删除终止回调，finished：YES：表示全部删除成功；NO：表示删除中途出错，停止删除
 */
- (void)removeAllItemsWithProgressBlock:(nullable void(^)(int removedCount, int totalCount))progress
                              stopBlock:(nullable void(^)(BOOL finished))stop;

/// 获取缓存对象
- (nullable DRKVStorageItem *)getItemForKey:(NSString *)key;

/// 获取缓存对象的序列化数据
- (nullable NSData *)getItemValueForKey:(NSString *)key;

/// 获取多个缓存对象
- (nullable NSArray<DRKVStorageItem *> *)getItemForKeys:(NSArray<NSString *> *)keys;

/// 获取多个缓存对象的序列化数据，返回数据格式为：key：data
- (nullable NSDictionary<NSString *, NSData *> *)getItemValueForKeys:(NSArray<NSString *> *)keys;

/// 判断缓存对象是否存在
- (BOOL)itemExistsForKey:(NSString *)key;

/// 获取缓存的总个数
- (int)getItemsCount;

/// 获取缓存的总size
- (int)getItemsSize;

@end

NS_ASSUME_NONNULL_END
