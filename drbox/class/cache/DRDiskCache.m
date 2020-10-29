//
//  DRDiskCache.m
//  drbox
//
//  Created by dr.box on 2020/8/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRDiskCache.h"
#import <UIKit/UIKit.h>
#import "DRLock.h"
#import "DRKVStorage.h"
#import "DrboxMacro.h"
#import "NSObject+drbox.h"
#import "NSString+drbox.h"
#import "NSKeyedArchiver+drbox.h"
#import "NSKeyedUnarchiver+drbox.h"

/// 获取空闲磁盘大小
static inline int64_t _DRDiskSpaceFreeSize() {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

/// 用于存储已经实例化的DRDiskCache实例，用于共享相同path的实例
static inline NSMapTable * _DRGlobalInstances(){
    static NSMapTable *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
                                        valueOptions:NSPointerFunctionsWeakMemory
                                            capacity:0];
    });
    return map;
}
/// 全局锁
static inline DRSemaphoreLock * _DRGlobalLock(){
    static DRSemaphoreLock *lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[DRSemaphoreLock alloc] init];
    });
    return lock;
}


@interface DRDiskCache (){
    
    DRKVStorage *_storage;
    dispatch_queue_t _queue;
}

@end
@implementation DRDiskCache

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"DRDiskCache init error"
                                   reason:@"DRDiskCache must be initialized with a path. Use 'initWithPath:' or 'initWithPath:inlineThreshold:' instead."
                                 userInfo:nil];
    return [self initWithPath:@"" inlineThreshold:0];
}

- (instancetype)initWithPath:(NSString *)path {
    return [self initWithPath:path inlineThreshold:1024 * 20]; // 20KB
}

- (instancetype)initWithPath:(NSString *)path inlineThreshold:(NSUInteger)threshold{
    DRDiskCache *cache = [_DRGlobalLock() aroundReturnId:^id _Nullable{
        if (path.length == 0) return nil;
        return [_DRGlobalInstances() objectForKey:path];
    }];
    if (cache) {
        [cache cleanLimitWithFinishBlock:nil];
        return cache;
    }
    DRKVStorageType type;
    if (threshold == 0) {
        type = DRKVStorageTypeFile;
    } else if (threshold == NSUIntegerMax) {
        type = DRKVStorageTypeSQLite;
    } else {
        type = DRKVStorageTypeMixed;
    }
    DRKVStorage *storage = [[DRKVStorage alloc] initWithPath:path type:type];
    if (!storage) return nil;
    self = [super init];
    if (self) {
        _path = path;
        _storage = storage;
        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        _ageLimit = DBL_MAX;
        _freeDiskSpaceLimit = 0;
        _inlineThreshold = threshold;
        _queue = dispatch_queue_create("com.drbox.cache.disk", DISPATCH_QUEUE_CONCURRENT);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_appWillBeTerminated)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_appDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [self _cleanLimitByRecursively];
        [_DRGlobalLock() around:^{
            [_DRGlobalInstances() setObject:self forKey:path];
        }];
    }
    return self;
}

- (BOOL)errorLogsEnabled{
    return [_DRGlobalLock() aroundReturnBool:^BOOL{
        return self->_storage.errorLogsEnabled;
    }];
}

- (void)setErrorLogsEnabled:(BOOL)errorLogsEnabled{
    [_DRGlobalLock() around:^{
        self->_storage.errorLogsEnabled = errorLogsEnabled;
    }];
}

- (BOOL)containsObjectForKey:(NSString *)key{
    if (!key) return NO;
    return [_DRGlobalLock() aroundReturnBool:^BOOL{
        return [self->_storage itemExistsForKey:key];
    }];
}

- (void)containsObjectForKey:(NSString *)key withBlock:(void (^)(NSString * _Nonnull, BOOL))block{
    if (!block) return;
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        BOOL contains = [self containsObjectForKey:key];
        block(key, contains);
    });
}

- (id<NSCoding>)objectForKey:(NSString *)key{
    if (!key) return nil;
    DRKVStorageItem *item = [_DRGlobalLock() aroundReturnId:^id _Nullable{
        return [self->_storage getItemForKey:key];
    }];
    if (!item.value) return nil;
    
    id object = nil;
    if (_customUnarchiveBlock) {
        object = _customUnarchiveBlock(item.value);
    } else {
        Class cls = NSClassFromString(item.valueClassName);
        object = [NSKeyedUnarchiver dr_unarchivedObjectOfClass:cls
                                                      fromData:item.value
                                                         error:NULL];
    }
    if (object && item.extendedData) {
        [DRDiskCache setExtendedData:item.extendedData toObject:object];
    }
    return object;
}

- (void)objectForKey:(NSString *)key
           withBlock:(void (^)(NSString * _Nonnull, id<NSCoding> _Nullable))block{
    if (!block) return;
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        id<NSCoding> object = [self objectForKey:key];
        block(key, object);
    });
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key{
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    
    NSData *extendedData = [DRDiskCache getExtendedDataFromObject:object];
    NSData *value = nil;
    if (_customArchiveBlock) {
        value = _customArchiveBlock(object);
    } else {
        value = [NSKeyedArchiver dr_archivedDataWithRootObject:object error:NULL];
    }
    if (!value) return;
    NSString *filename = nil;
    if (_storage.type != DRKVStorageTypeSQLite) {
        if (value.length > _inlineThreshold) {
            // value大于指定阈值，采用文件存储
            filename = [self _fileNameForKey:key];
        }
    }
    [_DRGlobalLock() around:^{
        [self->_storage saveItemWithKey:key
                                  value:value
                         valueClassName:[NSString stringWithUTF8String:object_getClassName(object)]
                               filename:filename
                           extendedData:extendedData];
    }];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key finishBlock:(void (^)(void))block{
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        [self setObject:object forKey:key];
        if (block) block();
    });
}

- (void)removeObjectForKey:(NSString *)key{
    if (!key) return;
    [_DRGlobalLock() around:^{
       [self->_storage removeItemForKey:key];
    }];
}

- (void)removeObjectForKey:(NSString *)key finishBlock:(void (^)(NSString * _Nonnull))block{
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        [self removeObjectForKey:key];
        if (block) block(key);
    });
}

- (void)removeAllObjects{
    [_DRGlobalLock() around:^{
        [self->_storage removeAllItems];
    }];
}

- (void)removeAllObjectsWithFinishBlock:(void (^)(void))block{
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        [self removeAllObjects];
        if (block) block();
    });
}

- (void)removeAllObjectsWithProgressBlock:(void (^)(int, int))progress stopBlock:(void (^)(BOOL))stop{
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        if (!self) {
            if (stop) stop(NO);
            return;
        }
        [_DRGlobalLock() around:^{
            [self->_storage removeAllItemsWithProgressBlock:progress stopBlock:stop];
        }];
    });
}

- (NSInteger)totalCount{
    return [_DRGlobalLock() aroundReturnInteger:^NSInteger{
        return [self->_storage getItemsCount];
    }];
}

- (void)totalCountWithBlock:(void (^)(NSInteger))block{
    if (!block) return;
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        NSInteger count = [self totalCount];
        block(count);
    });
}

- (NSInteger)totalCost{
    return [_DRGlobalLock() aroundReturnInteger:^NSInteger{
        return [self->_storage getItemsSize];
    }];
}

- (void)totalCostWithBlock:(void (^)(NSInteger))block{
    if (!block) return;
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        NSInteger size = [self totalCost];
        block(size);
    });
}

- (void)removeObjectToCount:(NSUInteger)count{
    [_DRGlobalLock() around:^{
        if (count >= INT_MAX) return;
        [self->_storage removeItemsToFitCount:(int)count];
    }];
}

- (void)removeObjectToCount:(NSUInteger)count finishBlock:(void (^)(void))block{
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        [self removeObjectToCount:count];
        if (block) block();
    });
}

- (void)removeObjectToCost:(NSUInteger)cost{
    [_DRGlobalLock() around:^{
        if (cost >= INT_MAX) return;
        [self->_storage removeItemsToFitSize:(int)cost];
    }];
}

- (void)removeObjectToCost:(NSUInteger)cost finishBlock:(void (^)(void))block{
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        [self removeObjectToCost:cost];
        if (block) block();
    });
}

- (void)removeObjectToAge:(NSTimeInterval)age{
    [_DRGlobalLock() around:^{
        if (age <= 0) {
            [self->_storage removeAllItems];
            return;
        }
        long timestamp = time(NULL);
        if (timestamp <= age) return;
        long ageLimit = timestamp - age;
        if (ageLimit >= INT_MAX) return;
        [self->_storage removeItemsEarlierThanTime:(int)ageLimit];
    }];
}

- (void)removeObjectToAge:(NSTimeInterval)age finishBlock:(void (^)(void))block{
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        [self removeObjectToAge:age];
        if (block) block();
    });
}

- (void)cleanLimit{
    [self removeObjectToCount:self.countLimit];
    [self removeObjectToCost:self.costLimit];
    [self removeObjectToAge:self.ageLimit];
    [self _removeObjectToFreeDiskSpace:self.freeDiskSpaceLimit];
}

- (void)cleanLimitWithFinishBlock:(dispatch_block_t)block{
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        if (!self) return;
        [self removeObjectToCount:self.countLimit];
        [self removeObjectToCost:self.costLimit];
        [self removeObjectToAge:self.ageLimit];
        [self _removeObjectToFreeDiskSpace:self.freeDiskSpaceLimit];
        if (block) block();
    });
}

+ (NSData *)getExtendedDataFromObject:(id)object {
    if (!object) return nil;
    return [self dr_associateValueForKey:_cmd];
}

+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object {
    if (!object) return;
    [object dr_setAssociateStrongValue:extendedData key:@selector(getExtendedDataFromObject:)];
}

#pragma mark - private

- (void)_appWillBeTerminated {
    [_DRGlobalLock() around:^{
        self->_storage = nil; // 释放资源，关闭数据库
    }];
}
- (void)_appDidEnterBackground {
    [self cleanLimitWithFinishBlock:nil];
}
- (NSString *)_fileNameForKey:(NSString *)key {
    NSString *fileName = nil;
    if (_customFileNameBlock) fileName = _customFileNameBlock(key);
    if (!fileName) fileName = key.dr_md5String;
    return fileName;
}
- (void)_removeObjectToFreeDiskSpace:(NSUInteger)targetFreeDiskSpace {
    [_DRGlobalLock() around:^{
        if (targetFreeDiskSpace == 0) return;
        int64_t totalBytes = [self->_storage getItemsSize];
        if (totalBytes <= 0) return;
        int64_t diskFreeBytes = _DRDiskSpaceFreeSize();
        if (diskFreeBytes < 0) return;
        int64_t needRemoveBytes = targetFreeDiskSpace - diskFreeBytes;
        if (needRemoveBytes <= 0) return;
        int64_t costLimit = totalBytes - needRemoveBytes;
        if (costLimit < 0) costLimit = 0;
        if (costLimit >= INT_MAX) return;
        [self->_storage removeItemsToFitSize:(int)costLimit];
    }];
}
/// 递归循环定时清理缓存
- (void)_cleanLimitByRecursively{
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @strongify(self);
        if (!self) return;
        [self cleanLimit];
        [self _cleanLimitByRecursively];
    });
}

@end
