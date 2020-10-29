//
//  DRKVStorage.m
//  drbox
//
//  Created by dr.box on 2020/8/8.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRKVStorage.h"
#import <UIKit/UIKit.h>
#import "DRThreadPool.h"
#import "DrboxMacro.h"
#import <WCDB/WCDB.h>

@interface DRKVStorageItem ()<WCTTableCoding>

WCDB_PROPERTY(key)
WCDB_PROPERTY(data)
WCDB_PROPERTY(fileName)
WCDB_PROPERTY(size)
WCDB_PROPERTY(creatTime)
WCDB_PROPERTY(lastAccessTime)
WCDB_PROPERTY(extendedData)

@end

@implementation DRKVStorageItem

WCDB_IMPLEMENTATION(DRKVStorageItem)
WCDB_SYNTHESIZE(DRKVStorageItem, key) // 添加key字段
WCDB_PRIMARY(DRKVStorageItem, key) // 设置key为主键
WCDB_NOT_NULL(DRKVStorageItem, key) // key为非空
WCDB_UNIQUE(DRKVStorageItem, key) // key唯一

// 添加valueClassName字段
WCDB_SYNTHESIZE_DEFAULT(DRKVStorageItem, valueClassName, nil)

// 添加data字段
WCDB_SYNTHESIZE_DEFAULT(DRKVStorageItem, data, nil)

// 添加fileName字段，设置默认值：nil
WCDB_SYNTHESIZE_DEFAULT(DRKVStorageItem, fileName, nil)

// 添加size字典，设置默认值：0
WCDB_SYNTHESIZE_DEFAULT(DRKVStorageItem, size, 0)

// 添加creatTime字段，设置默认值：0
WCDB_SYNTHESIZE_DEFAULT(DRKVStorageItem, creatTime, 0)

// 添加lastAccessTime字段，设置默认值：0
WCDB_SYNTHESIZE_DEFAULT(DRKVStorageItem, lastAccessTime, 0)

// 添加extendedData字段，设置默认值：nil
WCDB_SYNTHESIZE_DEFAULT(DRKVStorageItem, extendedData, nil)

// 创建lastAccessTime字段的索引：last_access_time_idx，并且让索引升序排序
WCDB_INDEX_ASC(DRKVStorageItem, "last_access_time_idx", lastAccessTime)

- (NSString *)description{
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"{ "];
    [str appendFormat:@"key: %@, ", _key];
    [str appendFormat:@"value: %@, ", _value];
    [str appendFormat:@"data: %@, ", _data];
    [str appendFormat:@"fileName: %@, ", _fileName];
    [str appendFormat:@"size: %d, ", _size];
    [str appendFormat:@"creatTime: %d, ", _creatTime];
    [str appendFormat:@"lastAccessTime: %d, ", _lastAccessTime];
    [str appendFormat:@"extendedData: %@", _extendedData];
    [str appendString:@" }"];
    return [NSString stringWithString:str];
}

@end

@interface DRKVStorage (){
    NSString *_path; // 缓存根目录
    NSString *_dataPath; // 文件存储目录
    NSString *_trashPath; // 删除文件临时存放处，会在后台线程中删除这些文件
    WCTDatabase *_db; // 数据库对象
    NSString *_tableName; // 数据库表名
    
    dispatch_queue_t _trashQueue; // 删除trash中文件的线程队列
}

@end

@implementation DRKVStorage

- (instancetype)init {
    @throw [NSException exceptionWithName:@"DRKVStorage init error"
                                   reason:@"Please use the designated initializer and pass the 'path' and 'type'."
                                 userInfo:nil];
    return [self initWithPath:@"" type:DRKVStorageTypeFile];
}

- (instancetype)initWithPath:(NSString *)path type:(DRKVStorageType)type {
    if (path.length == 0 || path.length > PATH_MAX - 64) {
        NSLog(@"DRKVStorage init error: invalid path: [%@].", path);
        return nil;
    }
    if (type > DRKVStorageTypeMixed) {
        NSLog(@"DRKVStorage init error: invalid type: %lu.", (unsigned long)type);
        return nil;
    }
    NSString *dataPath = [path stringByAppendingPathComponent:@"data"];
    NSString *trashPath = [path stringByAppendingPathComponent:@"trash"];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:trashPath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"DRKVStorage init error：%@", error);
        return nil;
    }
    NSString *dbPath = [path stringByAppendingPathComponent:@"drcache.db"];
    WCTDatabase *db = [[WCTDatabase alloc] initWithPath:dbPath];
    NSData *password = [@"com.drbox.cache.disk.storage" dataUsingEncoding:NSASCIIStringEncoding];
    [db setCipherKey:password];
    if (![db canOpen] || ![db isOpened]) {
        NSLog(@"DRKVStorage database open fail!");
        return nil;
    }
    // 创建表和索引
    NSString *tableName = @"cache_data_table";
    if (![db createTableAndIndexesOfName:tableName withClass:DRKVStorageItem.class]) {
        NSLog(@"DRKVStorage create table fail!");
        return nil;
    }
    self = [super init];
    if (self) {
        _path = path.copy;
        _type = type;
        _dataPath = dataPath.copy;
        _trashPath = trashPath.copy;
        _db = db;
        _tableName = tableName;
        _errorLogsEnabled = YES;
        _trashQueue = DRCreateDispatchQueue("com.drbox.kvstorage.trash", NSQualityOfServiceBackground);
        
        @weakify(self);
        // 注册WCDB数据库全局错误监控
        [WCTStatistics SetGlobalErrorReport:^(WCTError *error) {
            @strongify(self);
            if (self.errorLogsEnabled) {
                NSLog(@"[WCDB]：%@", error);
            }
        }];
        // 开启清理trash线程
        [self _fileCleanTrashInBackground];
    }
    return self;
}

- (BOOL)saveItem:(DRKVStorageItem *)item{
    if (item.key.length == 0 || item.value.length == 0) return NO;
    if (_type == DRKVStorageTypeFile && item.fileName.length == 0) return NO;
    // 初始化数据
    int timestamp = (int)time(NULL);
    item.size = item.size ? item.size : (int)item.value.length;
    item.creatTime = item.creatTime ? item.creatTime : timestamp;
    item.lastAccessTime = item.lastAccessTime ? item.lastAccessTime : timestamp;
    
    if (item.fileName.length) {
        // 以文件形式存储
        if (![self _fileWriteWithName:item.fileName data:item.value]) {
            return NO;
        }
        item.data = nil; // 数据库中不存储缓存对象的序列化数据
        // 将文件名等信息存储数据库
        if (![self _dbInsertOrUpdateItem:item]){
            // 数据库存储失败，删除文件
            [self _fileDeleteWithName:item.fileName];
            return NO;
        }
        return YES;
    }
    if (_type != DRKVStorageTypeSQLite) {
        // 如果存在，将本地缓存文件删除
        NSString *filename = [self _dbGetFilenameWithKey:item.key];
        if (filename) {
            [self _fileDeleteWithName:filename];
        }
    }
    // 存储在数据库中
    item.data = item.value; // 将缓存对象的序列化数据存储在数据库中
    return [self _dbInsertOrUpdateItem:item];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value valueClassName:(nonnull NSString *)className{
    DRKVStorageItem *item = [[DRKVStorageItem alloc] init];
    item.key = key;
    item.value = value;
    item.valueClassName = className;
    return [self saveItem:item];
}

- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
         valueClassName:(nonnull NSString *)className
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData{
    DRKVStorageItem *item = [[DRKVStorageItem alloc] init];
    item.key = key;
    item.value = value;
    item.valueClassName = className;
    item.fileName = filename;
    item.extendedData = extendedData;
    return [self saveItem:item];
}

- (BOOL)removeItemForKey:(NSString *)key{
    if (key.length == 0) return NO;
    if (_type == DRKVStorageTypeSQLite) {
        return [self _dbDeleteItemWithKey:key];
    }
    // 删除文件和数据库信息
    NSString *fileName = [self _dbGetFilenameWithKey:key];
    if (fileName.length) {
        if (![self _fileDeleteWithName:fileName]) return NO;
    }
    return [self _dbDeleteItemWithKey:key];
}

- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys{
    if (_type == DRKVStorageTypeSQLite) {
        return [self _dbDeleteItemWithKeys:keys];
    }
    // 删除文件和数据库信息
    NSArray *fileNames = [self _dbGetFilenameWithKeys:keys];
    for (NSString *fileName in fileNames) {
        [self _fileDeleteWithName:fileName];
    }
    return [self _dbDeleteItemWithKeys:keys];
}

- (BOOL)removeItemsLargerThanSize:(int)size{
    if (size == INT_MAX) return YES;
    if (size <= 0) return [self removeAllItems];
    if (_type == DRKVStorageTypeSQLite) {
        return [self _dbDeleteItemsWithSizeLargerThan:size];
    }
    // 删除文件和数据库信息
    NSArray *fileNames = [self _dbGetFilenamesWithSizeLargerThan:size];
    for (NSString *filename in fileNames) {
        [self _fileDeleteWithName:filename];
    }
    return [self _dbDeleteItemsWithSizeLargerThan:size];
}

- (BOOL)removeItemsEarlierThanTime:(int)time{
    if (time <= 0) return YES;
    if (time == INT_MAX) return [self removeAllItems];
    if (_type == DRKVStorageTypeSQLite) {
        return [self _dbDeleteItemsWithTimeEarlierThan:time];
    }
    // 删除文件和数据库信息
    NSArray *fileNames = [self _dbGetFilenamesWithTimeEarlierThan:time];
    for (NSString *filename in fileNames) {
        [self _fileDeleteWithName:filename];
    }
    return [self _dbDeleteItemsWithTimeEarlierThan:time];
}

- (BOOL)removeItemsToFitSize:(int)maxSize {
    if (maxSize == INT_MAX) return YES;
    if (maxSize <= 0) return [self removeAllItems];
    
    int totalSize = [self getItemsSize];
    if (totalSize < 0) return NO;
    if (totalSize <= maxSize) return YES;
    NSArray *items = nil;
    BOOL suc = NO;
    do {
        items = [self _dbGetItemOrderByTimeAscWithLimit:16];
        for (DRKVStorageItem *item in items) {
            if (totalSize > maxSize) {
                suc = [self _dbDeleteItemWithKey:item.key];
                if (suc && item.fileName) {
                    [self _fileDeleteWithName:item.fileName];
                }
                if (suc) {
                    totalSize -= item.size;
                }
            } else {
                break;
            }
            if (!suc) break;
        }
    } while (totalSize > maxSize && items.count > 0 && suc);
    return YES;
}

- (BOOL)removeItemsToFitCount:(int)maxCount{
    if (maxCount == INT_MAX) return YES;
    if (maxCount <= 0) return [self removeAllItems];
    
    int totalCount = [self getItemsCount];
    if (totalCount < 0) return NO;
    if (totalCount <= maxCount) return YES;
    NSArray *items = nil;
    BOOL suc = NO;
    do {
        items = [self _dbGetItemOrderByTimeAscWithLimit:16];
        for (DRKVStorageItem *item in items) {
            if (totalCount > maxCount) {
                suc = [self _dbDeleteItemWithKey:item.key];
                if (suc && item.fileName) {
                    [self _fileDeleteWithName:item.fileName];
                }
                if (suc) {
                    totalCount --;
                }
            }else{
                break;
            }
            if (!suc) break;
        }
    } while (totalCount > maxCount && items.count > 0 && suc);
    return YES;
}

- (BOOL)removeAllItems{
    BOOL suc = [_db deleteAllObjectsFromTable:_tableName];
    if (suc) {
        // 将_dataPath目录移动到trash目录
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        NSString *tmpPath = [_trashPath stringByAppendingPathComponent:(__bridge NSString *)(uuid)];
        suc = [[NSFileManager defaultManager] moveItemAtPath:_dataPath toPath:tmpPath error:nil];
        if (suc) {
            // 再次创建_dataPath目录
            suc = [[NSFileManager defaultManager] createDirectoryAtPath:_dataPath
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:NULL];
        }
        CFRelease(uuid);
        if (suc) {
            // 开启清理trash线程
            [self _fileCleanTrashInBackground];
        }
        return suc;
    }
    return suc;
}

- (void)removeAllItemsWithProgressBlock:(void (^)(int, int))progress
                              stopBlock:(void (^)(BOOL))stop{
    int totalCount = [self getItemsCount];
    if (totalCount <= 0) {
        if (stop) stop(YES);
    } else {
        int count = totalCount;
        NSArray *items = nil;
        BOOL suc = NO;
        do {
            items = [self _dbGetItemOrderByTimeAscWithLimit:32];
            for (DRKVStorageItem *item in items) {
                if (count > 0) {
                    suc = [self _dbDeleteItemWithKey:item.key];
                    if (suc && item.fileName) {
                        [self _fileDeleteWithName:item.fileName];
                    }
                    if (suc) {
                        count --;
                    }
                } else {
                    break;
                }
                if (!suc) break;
            }
            if (progress) progress(totalCount - count, totalCount);
        } while (count > 0 && items.count > 0 && suc);
        if (stop) stop(suc);
    }
}

- (DRKVStorageItem *)getItemForKey:(NSString *)key{
    if (key.length == 0) return nil;
    DRKVStorageItem *item = [self _dbGetItemWithKey:key];
    if (!item) return nil;
    if (item.data.length) {
        item.value = item.data;
    }else if (item.fileName.length){
        // 当前缓存对象是存储在文件中的，需要重新读取文件数据
        if ([self _fileExistsForName:item.fileName]) {
            item.value = [self _fileReadWithName:item.fileName];
        }
    }
    return item;
}

- (NSData *)getItemValueForKey:(NSString *)key{
    return [self getItemForKey:key].value;
}

- (NSArray<DRKVStorageItem *> *)getItemForKeys:(NSArray<NSString *> *)keys{
    NSArray *items = [self _dbGetItemsForKeys:keys];
    for (DRKVStorageItem *item in items) {
        if (item.data.length) {
            item.value = item.data;
        }else if (item.fileName.length){
            // 当前缓存对象是存储在文件中的，需要重新读取文件数据
            if ([self _fileExistsForName:item.fileName]) {
                item.value = [self _fileReadWithName:item.fileName];
            }
        }
    }
    return items;
}

- (NSDictionary<NSString *,NSData *> *)getItemValueForKeys:(NSArray<NSString *> *)keys{
    NSArray *items = [self getItemForKeys:keys];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (DRKVStorageItem *item in items) {
        if (item.key && item.value) {
            [dic setObject:item.value forKey:item.key];
        }
    }
    return dic.count ? dic : nil;
}

- (BOOL)itemExistsForKey:(NSString *)key{
    WCTRowSelect *select = [_db prepareSelectRowsOnResults:DRKVStorageItem.key.count()
                                                 fromTable:_tableName];
    return [(NSNumber *)[select where:DRKVStorageItem.key == key].nextValue integerValue] > 0;
}

- (int)getItemsCount{
    return [(NSNumber *)[_db getOneValueOnResult:DRKVStorageItem.key.count() fromTable:_tableName] intValue];
}

- (int)getItemsSize{
    return [(NSNumber *)[_db getOneValueOnResult:DRKVStorageItem.size.sum() fromTable:_tableName] intValue];
}

#pragma mark - private
/**
 保存文件
 
 @param filename 文件名
 @param data 文件二进制数据
 
 @return 成功返回 YES
 */
- (BOOL)_fileWriteWithName:(NSString *)filename data:(NSData *)data {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [data writeToFile:path atomically:YES];
}
/// 读取文件数据
- (NSData *)_fileReadWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}
/// 删除文件
- (BOOL)_fileDeleteWithName:(NSString *)filename{
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}
/// 判断缓存文件是否存在
- (BOOL)_fileExistsForName:(NSString *)filename{
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
/// 清理trash文件回收目录
- (void)_fileCleanTrashInBackground {
    NSString *trashPath = _trashPath;
    dispatch_queue_t queue = _trashQueue;
    dispatch_async(queue, ^{
        NSFileManager *manager = [NSFileManager new];
        NSArray *directoryContents = [manager contentsOfDirectoryAtPath:trashPath error:NULL];
        for (NSString *path in directoryContents) {
            NSString *fullPath = [trashPath stringByAppendingPathComponent:path];
            [manager removeItemAtPath:fullPath error:NULL];
        }
    });
}
/// 从数据库中获取key对应的文件名
- (NSString *)_dbGetFilenameWithKey:(NSString *)key{
    WCTRowSelect *select = [_db prepareSelectRowsOnResults:DRKVStorageItem.fileName
                                                 fromTable:_tableName];
    return (NSString *)[select where:DRKVStorageItem.key == key].nextValue;
}
/// 从数据库中获取key对应的文件名
- (NSArray *)_dbGetFilenameWithKeys:(NSArray *)keys{
    if (!keys || keys.count == 0) return nil;
    WCTRowSelect *select = [_db prepareSelectRowsOnResults:DRKVStorageItem.fileName
                                                 fromTable:_tableName];
    return (NSArray *)[select where:DRKVStorageItem.key.in(keys) &&
                       DRKVStorageItem.fileName.isNotNull()];
}
/// 从数据库中获取size>size的文件名
- (NSArray *)_dbGetFilenamesWithSizeLargerThan:(int)size{
    WCTRowSelect *select = [_db prepareSelectRowsOnResults:DRKVStorageItem.fileName
                                                 fromTable:_tableName];
    return (NSArray *)[select where:DRKVStorageItem.size > size &&
                       DRKVStorageItem.fileName.isNotNull()];
}
/// 从数据库中获取lastAccessTime<time的文件名
- (NSArray *)_dbGetFilenamesWithTimeEarlierThan:(int)time{
    WCTRowSelect *select = [_db prepareSelectRowsOnResults:DRKVStorageItem.fileName
                                                 fromTable:_tableName];
    return (NSArray *)[select where:DRKVStorageItem.lastAccessTime < time &&
                       DRKVStorageItem.fileName.isNotNull()];
}
/// 从数据库中获取key对应的item
- (DRKVStorageItem *)_dbGetItemWithKey:(NSString *)key{
    WCTSelect *select = [_db prepareSelectObjectsOfClass:DRKVStorageItem.class
                                               fromTable:_tableName];
    return (DRKVStorageItem *)[[select where:DRKVStorageItem.key == key] nextObject];
}
/// 向数据库插入item，如果item.key已存在，更新item
- (BOOL)_dbInsertOrUpdateItem:(DRKVStorageItem *)item{
    if ([self itemExistsForKey:item.key]) {
        // 更新item
        return [_db updateRowsInTable:_tableName
                         onProperties:{DRKVStorageItem.data, DRKVStorageItem.fileName, DRKVStorageItem.size, DRKVStorageItem.lastAccessTime, DRKVStorageItem.extendedData}
                           withObject:item
                                where:DRKVStorageItem.key == item.key];
    }
    return [_db insertObject:item into:_tableName];
}
/// 从数据库中删除key对应的item
- (BOOL)_dbDeleteItemWithKey:(NSString *)key {
    return [_db deleteObjectsFromTable:_tableName where:DRKVStorageItem.key == key];
}
/// 从数据库中删除key对应的item
- (BOOL)_dbDeleteItemWithKeys:(NSArray *)keys {
    if (!keys || keys.count == 0) return NO;
    return [_db deleteObjectsFromTable:_tableName where:DRKVStorageItem.key.in(keys)];
}
/// 删除数据库中，size>size的缓存对象
- (BOOL)_dbDeleteItemsWithSizeLargerThan:(int)size {
    return [_db deleteObjectsFromTable:_tableName where:DRKVStorageItem.size > size];
}
/// 删除数据库中，lastAccessTime<time的缓存对象
- (BOOL)_dbDeleteItemsWithTimeEarlierThan:(int)time{
    return [_db deleteObjectsFromTable:_tableName where:DRKVStorageItem.lastAccessTime < time];
}
/// 分页查询缓存对象，按lastAccessTime升序排序
- (NSArray<DRKVStorageItem *> *)_dbGetItemOrderByTimeAscWithLimit:(int)count{
    return [_db getObjectsOfClass:DRKVStorageItem.class
                        fromTable:_tableName
                          orderBy:DRKVStorageItem.lastAccessTime.order(WCTOrderedAscending)
                            limit:count];
}
/// 从数据库获取多个key对应的缓存对象
- (NSArray<DRKVStorageItem *> *)_dbGetItemsForKeys:(NSArray *)keys{
    return [_db getObjectsOfClass:DRKVStorageItem.class
                        fromTable:_tableName
                            where:DRKVStorageItem.key.in(keys)];
}

@end
