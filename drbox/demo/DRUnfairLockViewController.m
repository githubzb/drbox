//
//  DRUnfairLockViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRUnfairLockViewController.h"
#import "DRLock.h"

#define ticketCount 20

@interface DRUnfairLockViewController (){
    
    int _count;// 总票数
}

@property (nonatomic, strong) DRUnfairLock *lock;

@end

@implementation DRUnfairLockViewController

- (void)dealloc{
    NSLog(@"----DRUnfairLockViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = ticketCount;
    _lock = [[DRUnfairLock alloc] init];
    
    for (int i=0; i<21; i++) {
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        thread.name = [NSString stringWithFormat:@"%@号售票员", @(i)];
        [thread start];
    }
}

/// 买票
- (void)sale{
    if (_count > 0){
        NSLog(@"%@正在出售第 %@ 张票", [NSThread currentThread].name, @(ticketCount-_count+1));
        _count --;
    } else {
        NSLog(@"%@没有票卖了", [NSThread currentThread].name);
    }
}

- (void)run{
    // 注意：由于self持有lock对象，而lock并不持有around传入的block，所以block内的self不会出现循环引用
    // around是加锁操作，当block执行完毕，自动解锁
    [self.lock around:^{
        [self sale];
        NSLog(@"当前票数：%@", @(self->_count));
    }];
}


@end
