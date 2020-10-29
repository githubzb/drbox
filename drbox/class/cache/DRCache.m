//
//  DRCache.m
//  drbox
//
//  Created by dr.box on 2020/8/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRCache.h"

@implementation DRCache

- (instancetype) init {
    NSLog(@"Use \"initWithName\" or \"initWithPath\" to create DRCache instance.");
    return [self initWithPath:@""];
}

- (instancetype)initWithName:(NSString *)name{
    if (name.length == 0) return nil;
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheFolder stringByAppendingPathComponent:name];
    return [self initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path{
    if (path.length == 0) return nil;
    DRDiskCache *diskCache = [[DRDiskCache alloc] initWithPath:path];
    if (!diskCache) return nil;
    NSString *name = [path lastPathComponent];
    DRMemoryCache *memoryCache = [[DRMemoryCache alloc] init];
    memoryCache.name = name;
    
    self = [super init];
    if (self) {
        _name = name;
        _diskCache = diskCache;
        _memoryCache = memoryCache;
    }
    return self;
}

+ (instancetype)cacheWithName:(NSString *)name{
    return [[self alloc] initWithName:name];
}

+ (instancetype)cacheWithPath:(NSString *)path{
    return [[self alloc] initWithPath:path];
}

- (BOOL)containsObjectForKey:(NSString *)key{
    return [_memoryCache containsObjectForKey:key] || [_diskCache containsObjectForKey:key];
}

- (void)containsObjectForKey:(NSString *)key withBlock:(void (^)(NSString * _Nonnull, BOOL))block{
    if (!block) return;
    if ([_memoryCache containsObjectForKey:key]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(key, YES);
        });
    } else  {
        [_diskCache containsObjectForKey:key withBlock:block];
    }
}

- (id<NSCoding>)objectForKey:(NSString *)key{
    id<NSCoding> object = [_memoryCache objectForKey:key];
    if (!object) {
        object = [_diskCache objectForKey:key];
        if (object) {
            [_memoryCache setObject:object forKey:key];
        }
    }
    return object;
}

- (void)objectForKey:(NSString *)key withBlock:(void (^)(NSString * _Nonnull, id<NSCoding> _Nonnull))block{
    if (!block) return;
    id<NSCoding> object = [_memoryCache objectForKey:key];
    if (object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(key, object);
        });
    } else {
        [_diskCache objectForKey:key withBlock:^(NSString *key, id<NSCoding> object) {
            if (object && ![self->_memoryCache objectForKey:key]) {
                [self->_memoryCache setObject:object forKey:key];
            }
            block(key, object);
        }];
    }
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key{
    [_memoryCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void (^)(void))block{
    [_memoryCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key finishBlock:block];
}

- (void)removeObjectForKey:(NSString *)key{
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key withBlock:(void (^)(NSString * _Nonnull))block{
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key finishBlock:block];
}

- (void)removeAllObjects{
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjects];
}

- (void)removeAllObjectsWithBlock:(void (^)(void))block{
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjectsWithFinishBlock:block];
}

- (void)removeAllObjectsWithProgressBlock:(void (^)(int, int))progress stopBlock:(void (^)(BOOL))stop{
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjectsWithProgressBlock:progress stopBlock:stop];
}

@end
