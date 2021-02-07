//
//  DRDeallocHookViewController.m
//  drbox
//
//  Created by DHY on 2021/2/7.
//  Copyright © 2021 @zb.drbox. All rights reserved.
//

#import "DRDeallocHookViewController.h"
#import "DRDeallocTest.h"
#import "DRDeallocHook.h"
#import "DRDeallocTest2.h"
#import "DRDeallocTest3.h"
#import "DRDeallocTest4.h"

@interface DRDeallocHookViewController ()

@property (nonatomic, strong) DRDeallocTest *testObj1;
@property (nonatomic, strong) DRDeallocTest *testObj2;

@property (nonatomic, strong) DRDeallocTest2 *test2Obj; // 没重写父类dealloc方法
@property (nonatomic, strong) DRDeallocTest3 *test3Obj; // 重写了父类dealloc方法

@property (nonatomic, strong) DRDeallocTest4 *test4Obj;

@end

@implementation DRDeallocHookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testObj1 = [[DRDeallocTest alloc] init]; // hook
    self.testObj2 = [[DRDeallocTest alloc] init]; // 不hook
    
    self.test2Obj = [[DRDeallocTest2 alloc] init];
    self.test3Obj = [[DRDeallocTest3 alloc] init];
    
    self.test4Obj = [[DRDeallocTest4 alloc] init];
    
    
    NSLog(@"testObj1：%p", self.testObj1);
    NSLog(@"testObj2：%p", self.testObj2);
    NSLog(@"test2Obj：%p", self.test2Obj);
    NSLog(@"test3Obj：%p", self.test3Obj);
    NSLog(@"test4Obj：%p", self.test4Obj);
    
    [DRDeallocHook addDeallocHookToObject:self.testObj1 withBlock:^(id  _Nonnull hookObj) {
        NSLog(@"-------hook---dealloc------testObj1: %p", hookObj);
    }];
    // 重复hook
    [DRDeallocHook addDeallocHookToObject:self.testObj1 withBlock:^(id  _Nonnull hookObj) {
        NSLog(@"----repeat---hook---dealloc----testObj1: %p", hookObj);
    }];
    
    [DRDeallocHook addDeallocHookToObject:self.test2Obj withBlock:^(id  _Nonnull hookObj) {
        NSLog(@"------hook----dealloc---test2Obj：%p", hookObj);
    }];
    
    [DRDeallocHook addDeallocHookToObject:self.test3Obj withBlock:^(id  _Nonnull hookObj) {
        NSLog(@"------hook----dealloc---test3Obj：%p", hookObj);
    }];
    
    [DRDeallocHook addDeallocHookToObject:self.test4Obj withBlock:^(id  _Nonnull hookObj) {
        NSLog(@"------hook----dealloc---test4Obj：%p", hookObj);
    }];
    
}


@end
