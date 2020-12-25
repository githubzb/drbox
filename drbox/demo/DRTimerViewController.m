//
//  DRTimerViewController.m
//  drbox
//
//  Created by DHY on 2020/12/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRTimerViewController.h"
#import "Drbox.h"

@interface DRTimerViewController ()

@end

@implementation DRTimerViewController

- (void)dealloc{
    NSLog(@"DRTimerViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testScheduledTimer];
//    [self testScheduledNewTimer];
//    [self testTimerWithTimeInterval];
//    [self testTimerNewWithTimeInterval];
//    [self testScheduledTimerAAA];
    [self testTimerWithTimeIntervalBlock];
}


- (void)testScheduledTimer{
    // timer已经自动关联到了target中（并且在target销毁时，自动注销）
    [NSTimer dr_scheduledTimerWithTimeInterval:1
                                        target:self
                                      selector:@selector(scheduledTimerHandle:)
                                      userInfo:@{@"name": @"timer1"}
                                       repeats:YES];
    // 这里会覆盖上面创建的timer,并与target关联（所以:scheduledTimerHandle只会执行下面的定时器）
    [NSTimer dr_scheduledTimerWithTimeInterval:1
                                        target:self
                                      selector:@selector(scheduledTimerHandle:)
                                      userInfo:@{@"name": @"timer2"}
                                       repeats:YES];
}
- (void)scheduledTimerHandle:(NSTimer *)timer{
    NSLog(@"scheduledTimerHandle: %@", timer.userInfo[@"name"]);
}

- (void)testScheduledNewTimer{
    // timer不会自动关联到target中（target销毁时，自动注销）
    [NSTimer dr_scheduledNewTimerWithTimeInterval:1
                                           target:self
                                         selector:@selector(scheduledNewTimerHandle:)
                                         userInfo:@{@"name": @"timer1"}
                                          repeats:YES];
    // 这里不会覆盖上面的timer
    [NSTimer dr_scheduledNewTimerWithTimeInterval:1
                                           target:self
                                         selector:@selector(scheduledNewTimerHandle:)
                                         userInfo:@{@"name": @"timer2"}
                                          repeats:YES];
}
- (void)scheduledNewTimerHandle:(NSTimer *)timer{
    NSLog(@"scheduledNewTimerHandle: %@", timer.userInfo[@"name"]);
}

- (void)testTimerWithTimeInterval{
    // 创建timer定时器，并与target关联（该timer随target销毁，自动注销）
    NSTimer *timer1 = [NSTimer dr_timerWithTimeInterval:1
                               target:self
                             selector:@selector(timerWithTimeIntervalHandle:)
                             userInfo:@{@"name": @"timer1"}
                              repeats:YES];
    // 注意：这里必须将timer添加到runloop中，否则不会执行定时器
    [[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSRunLoopCommonModes];
    // 这里会覆盖上面创建的timer,并与target关联（所以:timerWithTimeIntervalHandle只会执行下面的定时器）
    NSTimer *timer2 = [NSTimer dr_timerWithTimeInterval:1
                               target:self
                             selector:@selector(timerWithTimeIntervalHandle:)
                             userInfo:@{@"name": @"timer2"}
                              repeats:YES];
    // 注意：这里必须将timer添加到runloop中，否则不会执行定时器
    [[NSRunLoop mainRunLoop] addTimer:timer2 forMode:NSRunLoopCommonModes];
}
- (void)timerWithTimeIntervalHandle:(NSTimer *)timer{
    NSLog(@"timerWithTimeIntervalHandle: %@", timer.userInfo[@"name"]);
}

- (void)testTimerNewWithTimeInterval{
    // 创建timer定时器，该定时器不与target关联（需手动自己关联），（该timer随target销毁，自动注销）
    NSTimer *timer1 = [NSTimer dr_timerNewWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(timerNewWithTimeIntervalHandle:)
                                                  userInfo:@{@"name": @"timer1"}
                                                   repeats:YES];
    // 注意：这里必须将timer添加到runloop中，否则不会执行定时器
    [[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSRunLoopCommonModes];
    
    // 由于创建的timer不会与target自动关联，所以不会覆盖上面的timer，两个timer都会执行
    NSTimer *timer2 = [NSTimer dr_timerNewWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(timerNewWithTimeIntervalHandle:)
                                                  userInfo:@{@"name": @"timer2"}
                                                   repeats:YES];
    // 注意：这里必须将timer添加到runloop中，否则不会执行定时器
    [[NSRunLoop mainRunLoop] addTimer:timer2 forMode:NSRunLoopCommonModes];
}
- (void)timerNewWithTimeIntervalHandle:(NSTimer *)timer{
    NSLog(@"timerNewWithTimeIntervalHandle: %@", timer.userInfo[@"name"]);
}

- (void)testScheduledTimerAAA{
    
    // 这里需要自己维护timer的生命周期
    @weakify(self);
    [NSTimer dr_scheduledTimerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        NSLog(@"scheduledTimerBlock");
        // 不需要时，需手动自己注销timer
        if (!self) {
            [timer invalidate];
        }
    } repeats:YES];
}

- (void)testTimerWithTimeIntervalBlock{
    
    // 这里需要自己维护timer的生命周期
    @weakify(self);
    NSTimer *timer = [NSTimer dr_timerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        
        NSLog(@"testTimerWithTimeIntervalBlock");
        // 不需要时，需手动自己注销timer
        if (!self) {
            [timer invalidate];
        }
    } repeats:YES];
    // 注意：这里需要将timer添加到runloop中，否则该定时器不会执行
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

@end
