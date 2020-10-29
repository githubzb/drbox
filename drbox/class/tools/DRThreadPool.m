//
//  DRThreadPool.m
//  drbox
//
//  Created by dr.box on 2020/7/31.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRThreadPool.h"
#import "DrboxMacro.h"
#import <libkern/OSAtomic.h>

#define MAX_QUEUE_COUNT 32

static inline dispatch_queue_priority_t DRNSQualityOfServiceToDispatchPriority(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUserInitiated: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case NSQualityOfServiceUtility: return DISPATCH_QUEUE_PRIORITY_LOW;
        case NSQualityOfServiceBackground: return DISPATCH_QUEUE_PRIORITY_BACKGROUND;
        case NSQualityOfServiceDefault: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
        default: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
    }
}

static inline qos_class_t DRNSQualityOfServiceToQOSClass(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return QOS_CLASS_USER_INTERACTIVE;
        case NSQualityOfServiceUserInitiated: return QOS_CLASS_USER_INITIATED;
        case NSQualityOfServiceUtility: return QOS_CLASS_UTILITY;
        case NSQualityOfServiceBackground: return QOS_CLASS_BACKGROUND;
        case NSQualityOfServiceDefault: return QOS_CLASS_DEFAULT;
        default: return QOS_CLASS_UNSPECIFIED;
    }
}

typedef struct {
    const char *name; // 线程池名称
    void **queues; // 队列线程集合
    uint32_t queueCount; // 线程池中队列线程总数
    int32_t counter; // 获取队列线程的次数
} DRThreadPoolContext;

static DRThreadPoolContext *DRThreadPoolContextCreate(const char *name,
                                                      uint32_t queueCount,
                                                      NSQualityOfService qos) {
    DRThreadPoolContext *context = calloc(1, sizeof(DRThreadPoolContext));
    if (!context) return NULL;
    context->queues =  calloc(queueCount, sizeof(void *));
    if (!context->queues) {
        free(context);
        return NULL;
    }
    for (NSUInteger i = 0; i < queueCount; i++) {
        dispatch_queue_t queue = DRCreateDispatchQueue(name, qos);
        context->queues[i] = (__bridge_retained void *)(queue);// 将queue转成void*指针，并让void*指针持有queue，防止queue释放
    }
    context->queueCount = queueCount;
    if (name) {
         context->name = strdup(name);
    }
    return context;
}

static void DRThreadPoolContextRelease(DRThreadPoolContext *context) {
    if (!context) return;
    if (context->queues) {
        for (NSUInteger i = 0; i < context->queueCount; i++) {
            void *queuePointer = context->queues[i];
            // __bridge_transfer与__bridge_retained相反，参考:https://juejin.im/post/6844903894447816711
            dispatch_queue_t queue = (__bridge_transfer dispatch_queue_t)(queuePointer);
            const char *name = dispatch_queue_get_label(queue);
            if (name) strlen(name); // avoid compiler warning
            queue = nil;
        }
        free(context->queues);
        context->queues = NULL;
    }
    if (context->name) free((void *)context->name);
}

static dispatch_queue_t DRThreadPoolContextGetQueue(DRThreadPoolContext *context) {
    uint32_t counter = (uint32_t)OSAtomicIncrement32(&context->counter);//原子操作，对counter自增
    void *queue = context->queues[counter % context->queueCount];
    return (__bridge dispatch_queue_t)(queue);
}


static DRThreadPoolContext *DRThreadPoolContextGetForQOS(NSQualityOfService qos) {
    static DRThreadPoolContext *context[5] = {0};
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[0] = DRThreadPoolContextCreate("com.drbox.user-interactive", count, qos);
            });
            return context[0];
        } break;
        case NSQualityOfServiceUserInitiated: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[1] = DRThreadPoolContextCreate("com.drbox.user-initiated", count, qos);
            });
            return context[1];
        } break;
        case NSQualityOfServiceUtility: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[2] = DRThreadPoolContextCreate("com.drbox.utility", count, qos);
            });
            return context[2];
        } break;
        case NSQualityOfServiceBackground: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[3] = DRThreadPoolContextCreate("com.drbox.background", count, qos);
            });
            return context[3];
        } break;
        case NSQualityOfServiceDefault:
        default: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[4] = DRThreadPoolContextCreate("com.drbox.default", count, qos);
            });
            return context[4];
        } break;
    }
}

@interface DRThreadPool (){
    
    DRThreadPoolContext *_context;
}

@end
@implementation DRThreadPool

- (void)dealloc{
    if (_context){
        DRThreadPoolContextRelease(_context);
        _context = NULL;
    }
}

- (instancetype)initWithName:(NSString *)name
                  queueCount:(NSUInteger)queueCount
                         qos:(NSQualityOfService)qos{
    if (queueCount <= 0 || queueCount > MAX_QUEUE_COUNT) return nil;
    DRThreadPoolContext *context = DRThreadPoolContextCreate([name UTF8String], (uint32_t)queueCount, qos);
    if (!_context) return nil;
    self = [super init];
    if (self) {
        _context = context;
        _name = name;
    }
    return self;
}

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos{
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            static DRThreadPool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DRThreadPool alloc] initWithContext:DRThreadPoolContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceUserInitiated: {
            static DRThreadPool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DRThreadPool alloc] initWithContext:DRThreadPoolContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceUtility: {
            static DRThreadPool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DRThreadPool alloc] initWithContext:DRThreadPoolContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceBackground: {
            static DRThreadPool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DRThreadPool alloc] initWithContext:DRThreadPoolContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceDefault:
        default: {
            static DRThreadPool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[DRThreadPool alloc] initWithContext:DRThreadPoolContextGetForQOS(NSQualityOfServiceDefault)];
            });
            return pool;
        } break;
    }
}

- (dispatch_queue_t)queue{
    return DRThreadPoolContextGetQueue(_context);
}

#pragma mark - private
- (instancetype)initWithContext:(DRThreadPoolContext *)context{
    if (!context) return nil;
    self = [super init];
    if (self) {
        _context = context;
        _name = context->name ? [NSString stringWithUTF8String:context->name] : nil;
    }
    return self;
}

@end

dispatch_queue_t DRCreateDispatchQueue(const char *_Nullable label, NSQualityOfService qos){
    if (DRSystemVersionGreaterOrEqualTo(@"8.0")) {
        dispatch_qos_class_t qosClass = DRNSQualityOfServiceToQOSClass(qos);
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);
        return dispatch_queue_create(label, attr);
    } else {
        long identifier = DRNSQualityOfServiceToDispatchPriority(qos);
        dispatch_queue_t queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(identifier, 0));
        return queue;
    }
}

dispatch_queue_t DRThreadPoolGetQueue(NSQualityOfService qos) {
    return [DRThreadPool defaultPoolForQOS:qos].queue;
}

void dispatch_async_on_default_queue(dispatch_block_t block){
    dispatch_queue_t queue = DRThreadPoolGetQueue(NSQualityOfServiceDefault);
    dispatch_async(queue, block);
}

void dispatch_async_on_userInteractive_queue(dispatch_block_t block){
    dispatch_queue_t queue = DRThreadPoolGetQueue(NSQualityOfServiceUserInteractive);
    dispatch_async(queue, block);
}

void dispatch_async_on_userInitiated_queue(dispatch_block_t block) {
    dispatch_queue_t queue = DRThreadPoolGetQueue(NSQualityOfServiceUserInitiated);
    dispatch_async(queue, block);
}

void dispatch_async_on_utility_queue(dispatch_block_t block) {
    dispatch_queue_t queue = DRThreadPoolGetQueue(NSQualityOfServiceUtility);
    dispatch_async(queue, block);
}

void dispatch_async_on_background_queue(dispatch_block_t block) {
    dispatch_queue_t queue = DRThreadPoolGetQueue(NSQualityOfServiceBackground);
    dispatch_async(queue, block);
}

void dispatch_after_on_queue(NSTimeInterval delayTime, NSQualityOfService qos, dispatch_block_t block){
    dispatch_queue_t queue = DRThreadPoolGetQueue(qos);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), queue, block);
}
