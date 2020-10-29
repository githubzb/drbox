//
//  DRMemoryCache.m
//  drbox
//
//  Created by dr.box on 2020/8/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRMemoryCache.h"
#import "DRThreadPool.h"
#import "DrboxMacro.h"
#import "DRLock.h"

static inline dispatch_queue_t DRMemoryCacheReleaseQueue() {
    return DRThreadPoolGetQueue(NSQualityOfServiceUtility);
}

/// 缓存节点对象
@interface _DRCacheNode : NSObject{
    @package
    __unsafe_unretained _DRCacheNode *_prev;
    __unsafe_unretained _DRCacheNode *_next;
    id _key;
    id _value;
    NSUInteger _cost; // 缓存value的成本
    NSUInteger _time; // 缓存value的开始时间
}

@end
@implementation _DRCacheNode
@end

/// 缓存链表对象
@interface _DRCacheNodeMap : NSObject{
    @package
    CFMutableDictionaryRef _dic;   // 用于存储缓存对象
    NSUInteger _totalCost;          // 缓存对象的总成本
    NSUInteger _totalCount;         // 缓存对象的总数量
    _DRCacheNode *_head;            // 缓存链表的头节点
    _DRCacheNode *_tail;            // 缓存链表的尾节点
    BOOL _releaseOnMainThread;      // 是否在主线程中释放节点对象
}

/// 将节点插入到缓存链表的头部，如果node在链表中存在，会将node移动到链表的头部
- (void)insertNodeAtHead:(_DRCacheNode *)node;

/// 将节点移动到链表的头部
- (void)bringNodeToHead:(_DRCacheNode *)node;

/// 将节点从链表中移除
- (void)removeNode:(_DRCacheNode *)node;

/**
 删除链表尾部的节点
 
 @return 返回被删除的尾部节点，如果链表为空，将返回nil
 */
- (_DRCacheNode *)removeTailNode;

/// 删除链表所有节点
- (void)removeAll;

@end

@implementation _DRCacheNodeMap

- (instancetype)init {
    self = [super init];
    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(),
                                     0,
                                     &kCFTypeDictionaryKeyCallBacks,
                                     &kCFTypeDictionaryValueCallBacks);
    _releaseOnMainThread = NO;
    return self;
}

- (void)dealloc {
    CFRelease(_dic);
}

- (void)insertNodeAtHead:(_DRCacheNode *)node{
    CFDictionarySetValue(_dic, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    _totalCost += node->_cost;
    _totalCount ++;
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)bringNodeToHead:(_DRCacheNode *)node{
    if (_head == node) return;
    
    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

- (void)removeNode:(_DRCacheNode *)node{
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(node->_key));
    _totalCost -= node->_cost;
    _totalCount --;
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (_DRCacheNode *)removeTailNode{
    if (!_tail) return nil;
    _DRCacheNode *tail = _tail;
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(_tail->_key));
    _totalCost -= _tail->_cost;
    _totalCount --;
    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return tail;
}

- (void)removeAll{
    _totalCost = 0;
    _totalCount = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_dic) > 0) {
        CFMutableDictionaryRef holder = _dic;
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(),
                                         0,
                                         &kCFTypeDictionaryKeyCallBacks,
                                         &kCFTypeDictionaryValueCallBacks);
        if (_releaseOnMainThread) {
            dispatch_async_on_main_queue(^{
                CFRelease(holder);
            });
        }else{
            dispatch_async(DRMemoryCacheReleaseQueue(), ^{
                CFRelease(holder);
            });
        }
    }
}

@end

@interface DRMemoryCache (){
    _DRCacheNodeMap *_map;
    DRMutexLock *_lock;
    dispatch_queue_t _queue;
}

@end
@implementation DRMemoryCache

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [_map removeAll];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _lock = [[DRMutexLock alloc] init];
        _map = [_DRCacheNodeMap new];
        _queue = DRCreateDispatchQueue("com.drbox.cache.memory", NSQualityOfServiceUtility);
        
        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        _ageLimit = DBL_MAX;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (NSUInteger)totalCount {
    return [_lock aroundReturnUInteger:^NSUInteger{
        return self->_map->_totalCount;
    }];
}

- (NSUInteger)totalCost {
    return [_lock aroundReturnUInteger:^NSUInteger{
        return self->_map->_totalCost;
    }];
}

- (BOOL)releaseOnMainThread {
    return [_lock aroundReturnBool:^BOOL{
        return self->_map->_releaseOnMainThread;
    }];
}

- (void)setReleaseOnMainThread:(BOOL)releaseOnMainThread {
    [_lock around:^{
        self->_map->_releaseOnMainThread = releaseOnMainThread;
    }];
}

- (BOOL)containsObjectForKey:(id)key{
    if (!key) return NO;
    return [_lock aroundReturnBool:^BOOL{
        return CFDictionaryContainsKey(self->_map->_dic, (__bridge const void *)(key));
    }];
}

- (id)objectForKey:(id)key{
    if (!key) return nil;
    return [_lock aroundReturnId:^id _Nullable{
        _DRCacheNode *node = CFDictionaryGetValue(self->_map->_dic, (__bridge const void *)(key));
        if (node) {
            node->_time = CACurrentMediaTime();
            [self->_map bringNodeToHead:node];
        }
        return node ? node->_value : nil;
    }];
}

- (void)setObject:(id)object forKey:(id)key{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    [_lock around:^{
        _DRCacheNode *node = CFDictionaryGetValue(self->_map->_dic, (__bridge const void *)(key));
        NSTimeInterval now = CACurrentMediaTime();
        if (node) {
            self->_map->_totalCost -= node->_cost;
            self->_map->_totalCost += cost;
            node->_cost = cost;
            node->_time = now;
            node->_value = object;
            [self->_map bringNodeToHead:node];
        } else {
            node = [[_DRCacheNode alloc] init];
            node->_cost = cost;
            node->_time = now;
            node->_key = key;
            node->_value = object;
            [self->_map insertNodeAtHead:node];
        }
        if (self->_map->_totalCost > self->_costLimit) {
            dispatch_async(self->_queue, ^{
                [self removeObjectToCost:self->_costLimit];
            });
        }
        if (self->_map->_totalCount > self->_countLimit) {
            _DRCacheNode *node = [self->_map removeTailNode];
            if (self->_map->_releaseOnMainThread) {
                dispatch_async_on_main_queue(^{
                    [node class];
                });
            }else{
                dispatch_async(DRMemoryCacheReleaseQueue(), ^{
                    [node class];
                });
            }
        }
    }];
}

- (void)removeObjectForKey:(id)key{
    if (!key) return;
    [_lock around:^{
        _DRCacheNode *node = CFDictionaryGetValue(self->_map->_dic, (__bridge const void *)(key));
        if (node) {
            [self->_map removeNode:node];
            if (self->_map->_releaseOnMainThread) {
                dispatch_async_on_main_queue(^{
                    [node class];
                });
            }else{
                dispatch_async(DRMemoryCacheReleaseQueue(), ^{
                    [node class];
                });
            }
        }
    }];
}

- (void)removeAllObjects{
    [_lock around:^{
        [self->_map removeAll];
    }];
}

- (void)removeObjectToCount:(NSUInteger)count{
    if (count == 0) {
        [self removeAllObjects];
    }else{
        BOOL finish = [_lock aroundReturnBool:^BOOL{
            return self->_map->_totalCount <= count;
        }];
        if (finish) return;
        
        NSMutableArray *holder = [NSMutableArray new];
        while (!finish) {
            finish = [_lock tryAroundReturnBool:^BOOL{
                if (self->_map->_totalCount > count) {
                    _DRCacheNode *node = [self->_map removeTailNode];
                    if (node) [holder addObject:node];
                    return NO;
                }
                return YES;
            } fail:^{
                usleep(10 * 1000); //10 ms
            }];
        }
        if (holder.count) {
            if (self->_map->_releaseOnMainThread) {
                dispatch_async_on_main_queue(^{
                    [holder count];
                });
            }else{
                dispatch_async(DRMemoryCacheReleaseQueue(), ^{
                    [holder count];
                });
            }
        }
    }
}

- (void)removeObjectToCost:(NSUInteger)cost{
    if (cost == 0) {
        [self removeAllObjects];
    }else{
        BOOL finish = [_lock aroundReturnBool:^BOOL{
            return self->_map->_totalCost <= cost;
        }];
        if (finish) return;
        
        NSMutableArray *holder = [NSMutableArray new];
        while (!finish) {
            finish = [_lock tryAroundReturnBool:^BOOL{
                if (self->_map->_totalCost > cost) {
                    _DRCacheNode *node = [self->_map removeTailNode];
                    if (node) [holder addObject:node];
                    return NO;
                }
                return YES;
            } fail:^{
                usleep(10 * 1000); //10 ms
            }];
        }
        if (holder.count) {
            if (self->_map->_releaseOnMainThread) {
                dispatch_async_on_main_queue(^{
                    [holder count];
                });
            }else{
                dispatch_async(DRMemoryCacheReleaseQueue(), ^{
                    [holder count];
                });
            }
        }
    }
}

- (void)removeObjectToAge:(NSTimeInterval)age{
    NSTimeInterval now = CACurrentMediaTime();
    if (age <= 0) {
        [self removeAllObjects];
    }else{
        BOOL finish = [_lock aroundReturnBool:^BOOL{
            return !self->_map->_tail || now - self->_map->_tail->_time <= age;
        }];
        if (finish) return;
        
        NSMutableArray *holder = [NSMutableArray new];
        while (!finish) {
            finish = [_lock tryAroundReturnBool:^BOOL{
                if (self->_map->_tail && (now - self->_map->_tail->_time > age)) {
                    _DRCacheNode *node = [self->_map removeTailNode];
                    if (node) [holder addObject:node];
                    return NO;
                }
                return YES;
            } fail:^{
                usleep(10 * 1000); //10 ms
            }];
        }
        if (holder.count) {
            if (self->_map->_releaseOnMainThread) {
                dispatch_async_on_main_queue(^{
                    [holder count];
                });
            }else{
                dispatch_async(DRMemoryCacheReleaseQueue(), ^{
                    [holder count];
                });
            }
        }
    }
}


#pragma mark - private
- (void)_appDidReceiveMemoryWarningNotification {
    if (self.didReceiveMemoryWarningBlock) {
        self.didReceiveMemoryWarningBlock(self);
    }else{
        [self removeAllObjects];
    }
}

- (void)_appDidEnterBackgroundNotification {
    if (self.didEnterBackgroundBlock) {
        self.didEnterBackgroundBlock(self);
    }else{
        [self removeObjectToAge:self.ageLimit];
    }
}


@end
