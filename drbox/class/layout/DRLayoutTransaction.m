//
//  DRLayoutTransaction.m
//  drbox
//
//  Created by dr.box on 2020/8/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRLayoutTransaction.h"
#import "DRLock.h"
#import "DRThreadPool.h"

static inline DRUnfairLock * lock(){
    static DRUnfairLock *lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[DRUnfairLock alloc] init];
    });
    return lock;
}

static inline NSMutableArray * messageQueue(){
    static NSMutableArray *messageQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageQueue = [NSMutableArray array];
    });
    return messageQueue;
}

/// 消息队列
static dispatch_queue_t transactionQueue() {
  static dispatch_queue_t transactionQueue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      transactionQueue = DRCreateDispatchQueue("com.drbox.layout.transaction",
                                               NSQualityOfServiceDefault);
  });
  return transactionQueue;
}

/// 入队列
static inline void pushQueue(dispatch_block_t block) {
    [lock() around:^{
        [messageQueue() addObject:block];
        CFRunLoopWakeUp(CFRunLoopGetMain());// 唤醒main runloop
    }];
}
/// 执行队列
static inline void processQueue(){
    [lock() around:^{
        for (dispatch_block_t block in messageQueue()) {
            block();
        }
        [messageQueue() removeAllObjects];
    }];
}

/// runloop状态回调
static void DRRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    processQueue();
}

@implementation DRLayoutTransaction

+ (void)load{
    // 注册runloop状态监听
    CFRunLoopObserverRef observer;
    CFRunLoopRef runLoop = CFRunLoopGetMain();
    CFOptionFlags activities = (kCFRunLoopBeforeWaiting | kCFRunLoopExit);
    observer = CFRunLoopObserverCreate(NULL,
                                       activities,
                                       true,        // repeat
                                       0xFFFFFF,   // after CATransaction(2000000)
                                       DRRunLoopObserverCallBack,
                                       NULL);
    if (observer) {
      CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
      CFRelease(observer);
    }
}

+ (void)addTransaction:(dispatch_block_t)block
              complete:(dispatch_block_t)complete{
    dispatch_async(transactionQueue(), ^{
        block();
        pushQueue(complete);
    });
}

@end
