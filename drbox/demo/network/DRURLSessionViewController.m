//
//  DRURLSessionViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRURLSessionViewController.h"
#import "Drbox.h"
#import "DRURLSession.h"

@interface DROperation : NSOperation

@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

- (void)downloadFinish;

@end

@implementation DROperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)start{
    if (self.isFinished || self.isExecuting || self.isCancelled) {
        return;
    }
    NSLog(@"----%@:开始执行任务", self.name);
    self.executing = YES;
    @weakify(self);
    self.completionBlock = ^{
        @strongify(self);
        NSLog(@"----%@:任务完成", self.name);
    };
}

- (void)cancel{
    if (self.isExecuting) {
        [super cancel];
        self.executing = NO;
        self.finished = YES;
        NSLog(@"----%@:取消任务", self.name);
    }
}

- (void)downloadFinish{
    if (self.isFinished) {
        return;
    }
    self.finished = YES;
    self.executing = NO;
    if (self.completionBlock) {
        self.completionBlock();
    }
    NSLog(@"-----主线程：%@", @([NSThread isMainThread]));
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isAsynchronous{
    return YES;
}

@end


@interface DRURLSessionViewController ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *queueDic;

@end

@implementation DRURLSessionViewController

- (void)dealloc{
    NSLog(@"--------DRURLSessionViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    DRURLSession *session = [[DRURLSession alloc] initWithSessionConfiguration:config];
//
//    NSError *err = nil;
//    NSData *data = [NSKeyedArchiver dr_archivedDataWithRootObject:session error:&err];
//    if (err) {
//        NSLog(@"encode fail:%@", err);
//        return;
//    }
//    DRURLSession *s = [NSKeyedUnarchiver dr_unarchivedObjectOfClass:[DRURLSession class]
//                                                                  fromData:data
//                                                                     error:&err];
//    if (err) {
//        NSLog(@"decode fail:%@", err);
//        return;
//    }
    
    self.queueDic = [[NSMutableDictionary alloc] init];
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 6;
    
    for (int i=0; i<10; i++) {
        DROperation *operation = [[DROperation alloc] init];
        operation.name = [NSString stringWithFormat:@"operation_%d", i];
        [self.queueDic setValue:operation forKey:operation.name];
        [self.queue addOperation:operation];
    }
    
    [self test];
}

- (void)test{
    dispatch_after_on_main_queue(3, ^{
        for (DROperation *op in self.queue.operations) {
            if (op.isExecuting) {
                dispatch_queue_t queue = DRThreadPoolGetQueue(op.qualityOfService);
                dispatch_async(queue, ^{
                    [op downloadFinish];
                });
            }
        }
        NSLog(@"-----队列个数：%ld", self.queue.operationCount);
        if (self.queue.operationCount == 0) {
            NSLog(@"----队列完毕");
            return;
        }
        [self test];
    });
}


@end
