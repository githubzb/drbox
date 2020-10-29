//
//  DRBlockDescViewController.m
//  drbox
//
//  Created by dr.box on 2020/9/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRBlockDescViewController.h"
#import "Drbox.h"

typedef NSString *(^testBlock)(NSString *, int);

@interface DRBlockDescViewController ()

@end

@implementation DRBlockDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_block_t block = ^{};
    NSMethodSignature *blockSign = dr_signatureForBlock(block);
    NSLog(@"block.numberOfArguments: %ld", blockSign.numberOfArguments);
    for (int i = 0; i < blockSign.numberOfArguments; i++) {
        const char *type = [blockSign getArgumentTypeAtIndex:(NSUInteger)i];
        NSLog(@"block.arg[%i].type: %s", i, type);
    }
    NSLog(@"block.methodReturnLength: %ld", blockSign.methodReturnLength);
    NSLog(@"block.methodReturnType: %s", blockSign.methodReturnType);
    
    NSLog(@"\n");
    
    NSMethodSignature *testSign = [self methodSignatureForSelector:@selector(testFuncSign:num:myId:type:age:block:asel:cls:point:myPoint:)];
    NSLog(@"testSign.numberOfArguments: %ld", testSign.numberOfArguments);
    for (int i = 0; i < testSign.numberOfArguments; i++) {
        const char *type = [testSign getArgumentTypeAtIndex:(NSUInteger)i];
        NSLog(@"testSign.arg[%i].type: %s", i, type);
    }
    NSLog(@"testSign.methodReturnLength: %ld", testSign.methodReturnLength);
    NSLog(@"testSign.methodReturnType: %s", testSign.methodReturnType);
    
    // 以上可以看出Block的签名与类方法签名的不同
    // Block：
    // 第一个参数是自己：@？（block类型）
    // 后面的参数是Block自身的参数
    // 类方法：
    // 第一个参数是自己：@（指针类型）
    // 第二个参数是类的方法名：:（SEL类型）
    // 后面的参数是类方法自身的参数
    
    /// 下面我们对比一下Block与类方法参数类型的区别
    NSLog(@"下面我们对比一下Block与类方法参数类型的区别");
    
    NSString * (^blockArg)(NSString *,
                           NSNumber *,
                           id ,
                           const char *,
                           int,
                           testBlock,
                           SEL,
                           Class,
                           const void *, CGPoint) = ^ NSString *(NSString *str,
                                                               NSNumber *num,
                                                               id myId,
                                                               const char *type,
                                                               int age,
                                                               testBlock b,
                                                               SEL asel,
                                                               Class cls, const void *p, CGPoint point){
        return [NSString stringWithFormat:@"%@-%@-%@-%s-%i",str, num, [myId description], type, age];
    };
    NSMethodSignature *blockArgSign = dr_signatureForBlock(blockArg);
    for (int i = 0; i < blockArgSign.numberOfArguments; i++) {
        const char *type = [blockArgSign getArgumentTypeAtIndex:(NSUInteger)i];
        NSLog(@"block.arg[%i].type: %s", i, type);
    }
    NSLog(@"block.methodReturnType: %s", blockArgSign.methodReturnType);
    
    NSLog(@"\n");
    
    NSMethodSignature *testArgSign = [self methodSignatureForSelector:@selector(testFuncSign:num:myId:type:age:block:asel:cls:point:myPoint:)];
    for (int i = 0; i < testArgSign.numberOfArguments; i++) {
        const char *type = [testArgSign getArgumentTypeAtIndex:(NSUInteger)i];
        NSLog(@"class.arg[%i].type: %s", i, type);
    }
    NSLog(@"class.methodReturnType: %s", testArgSign.methodReturnType);
    
    // 从打印日志可以看出
    // Block：
    // id类型对应的表示法：@、@"具体的类名"
    // Block类型的表示法：@?<Block的签名>
    // 类方法：
    // id类型对应的表示法：@
    // Block类型的表示法：@?
    
    // 除了id和Block这两个类型不一样，其他的都一样
    
    
    // 通过NSInvocation调用block
    NSString * (^myblock)(NSString *, CGPoint, Class) = ^ NSString *(NSString *desc, CGPoint point, Class cls){
        return [NSString stringWithFormat:@"%@：%@,class:%@", desc, NSStringFromCGPoint(point), NSStringFromClass(cls)];
    };
    NSMethodSignature *myBlockSign = dr_signatureForBlock(myblock);
    NSInvocation *myBlockInv = [NSInvocation invocationWithMethodSignature:myBlockSign];
    myBlockInv.target = myblock;
//    myBlockInv.selector // 这里不需要设置方法名，应为Block不存在方法名
    // 设置参数
    CGPoint p = CGPointMake(12, 24);
    [NSInvocation dr_setArgumentsForInvocation:myBlockInv, @"点坐标为", p, self.class];
    [myBlockInv invoke];
    // 获取返回值
    NSString *ret = [myBlockInv dr_getReturnValue];
    NSLog(@"myblock返回值：%@", ret);
    
    
    NSMethodSignature *testCallSign = [self methodSignatureForSelector:@selector(testCallTestFuncSignWithTarget:)];
    NSInvocation *testCallInv = [NSInvocation invocationWithMethodSignature:testCallSign];
    testCallInv.target = self;
    testCallInv.selector = @selector(testCallTestFuncSignWithTarget:);
    [testCallInv dr_setArgument:self atIndex:2];
    [testCallInv invoke];
    
    
    // 设置无法转换的参数类型
//    NSMethodSignature *sign1 = [self methodSignatureForSelector:@selector(printNum:)];
//    NSInvocation *inv1 = [NSInvocation invocationWithMethodSignature:sign1];
//    inv1.target = self;
//    inv1.selector = @selector(printNum:);
//    [inv1 dr_setArgument:@{} atIndex:2]; // NSDictionary无法转成int
//    [inv1 invoke];
    
    NSMethodSignature *sign2 = [self methodSignatureForSelector:@selector(thisViewController)];
    NSInvocation *inv2 = [NSInvocation invocationWithMethodSignature:sign2];
    inv2.target = self;
    inv2.selector = @selector(thisViewController);
    [inv2 invoke];
    id vc = [inv2 dr_getReturnValue];
    if ([vc isKindOfClass:self.class]) {
        NSLog(@"void *转DRBlockDescViewController成功");
    }
    
    NSLog(@"\n");
    
    // 判断参数是否完全匹配
    NSError *err;
    if (dr_matchAllSignature(blockArg, testArgSign, &err)) {
        NSLog(@"----完全匹配");
    }else{
        NSLog(@"----不匹配：%@", err);
    }
    
    // 判断参数类型是否匹配，数量可以不一样
    NSMethodSignature *sign4 = [self methodSignatureForSelector:@selector(testFuncS:num:)];
    if (dr_matchSignature(blockArg, sign4, &err)) {
        NSLog(@"----类型匹配");
    }else{
        NSLog(@"----类型不匹配：%@", err);
    }
    
    // 参数顺序不一致
    NSMethodSignature *sign5 = [self methodSignatureForSelector:@selector(testFuncS2:num:type:myId:)];
    if (dr_matchSignature(blockArg, sign5, &err)) {
        NSLog(@"----类型匹配");
    }else{
        NSLog(@"----类型不匹配：%@", err);
    }
    
    // 调用block
    NSString *(^myTestBlock)(NSString *, int) = ^ NSString *(NSString *name, int age){
        return [NSString stringWithFormat:@"姓名：%@，年龄：%i", name, age];
    };
    NSString *ret2 = dr_executeBlockArgs(myTestBlock, @[@"drbox", @(30)]);
    NSLog(@"myTestBlock返回值：%@", ret2);
    
    // 另一种调用方法
    NSString *ret3 = dr_executeBlock(myTestBlock, @"zhangsan", 29);
    NSLog(@"另一种调用myTestBlock返回值：%@", ret3);
    
    
}

- (void *)thisViewController{
    return (__bridge void *)self;
}

- (void)printNum:(int)i{
    NSLog(@"-----printNum:%i", i);
}

- (void)testCallTestFuncSignWithTarget:(void *)target{
    typeof(self) vc = (__bridge id)target;
    if ([vc isKindOfClass:self.class]) {
        [vc testFuncSign];
    }else{
        NSLog(@"-----无法调用，target:%@", [vc description]);
    }
}

- (void)testFuncSign{
    NSLog(@"execute testFuncSign method");
}
- (NSString *)testFuncS2:(NSString *)str num:(NSNumber *)num type:(const char*)type myId:(id)myId{
    return nil;
}
- (NSString *)testFuncS:(NSString *)str num:(NSNumber *)num{
    return nil;
}
- (NSString *)testFuncSign:(NSString *)str
                       num:(NSNumber *)num
                      myId:(id)myId
                      type:(const char *)type
                       age:(int)age
                     block:(testBlock)block
                      asel:(SEL)asel cls:(Class)cls point:(const void *)p myPoint:(CGPoint)point{
    return [NSString stringWithFormat:@"%@-%@-%@-%s-%i",str, num, [myId description], type, age];
}

@end
