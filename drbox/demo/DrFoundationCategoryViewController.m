//
//  DrFoundationCategoryViewController.m
//  drbox
//
//  Created by dr.box on 2020/7/20.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DrFoundationCategoryViewController.h"
#import "Drbox.h"
#import "DRDictionaryParser.h"
#import <objc/runtime.h>


// 我们将要通过isa hook改变DrIsaHookDemo的一个实例的方法，但不影响DrIsaHookDemo其他实例的行为
@interface DrIsaHookDemo : NSObject

- (BOOL)loginWithUserName:(NSString *)userName password:(NSString *)pwd;

@end
@implementation DrIsaHookDemo

- (BOOL)loginWithUserName:(NSString *)userName password:(NSString *)pwd{
    return [userName isEqualToString:@"drbox"] && [pwd isEqualToString:@"123"];
}

@end


@interface DrFoundationCategoryViewController (){
    
    NSTimer *_timer;
}

@end

@implementation DrFoundationCategoryViewController

+ (void)load{
    // hook 实例方法
    __block NSInvocation *invocation;
    [self dr_hookMethod:@selector(hookMethodTest:) withBlock:^NSString * (id obj, int count){

        NSLog(@"-----hook:%@", @(count));
        [NSInvocation dr_setArgumentsForInvocation:invocation, count];
        [invocation invokeWithTarget:obj];
        // 获取原始方法的返回值
        id res = [invocation dr_getReturnValue];
        NSLog(@"hookMethodTest return value:%@", res);
        return res;
    } orgInvocation:&invocation];
    
    // hook 类方法
    __block NSInvocation *invocation2;
    [self dr_hookClassMethod:@selector(hookClassMethodTest:) withBlock:^NSString * (id obj, NSString *str){
        
        NSLog(@"-----class hook:%@", str);
        [NSInvocation dr_setArgumentsForInvocation:invocation2, [NSString stringWithFormat:@"hookValue-%@", str]];
        [invocation2 invokeWithTarget:obj];
        NSString *res = [invocation2 dr_getReturnValue];
        NSLog(@"------hookClassMethodTest return Value:%@", res);
        return res;
    } orgInvocation:&invocation2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hook demo
    [self hookMethodTest:100];
    [[self class] hookClassMethodTest:@"hello"];
    NSLog(@"\n\n");
    
    
    [self dataTest];
    [self stringTest];
    [self arrayTest];
    [self dictionaryTest];
    [self testIsaHook];
    [self dateTest];
    [self notifyTest];
    [self keyedArchiverOrUnArchiverTest];
    [self timerTest];
}

// NSData分类测试
- (void)dataTest{
    // 数据压缩 demo
    NSString *str = @"压缩前数据压缩前数据压缩前数据压缩前数据压缩前数据压缩前数据压缩前数据压缩前数据压缩前数据压缩前数据压缩前数据";
    NSData *orgData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *gzipData = [orgData dr_gzipDeflate];
    NSLog(@"压缩前的数据长度：%@，GZIP压缩后的数据长度：%@", @(orgData.length), @(gzipData.length));
    NSData *d = [gzipData dr_gzipInflate];
    NSLog(@"GZIP解压后的数据长度：%@", @(d.length));
    NSString *gzipInflate = [d dr_utf8String];
    NSLog(@"GZIP解压后的数据：%@", gzipInflate);
    
    NSData *zlibData = [orgData dr_zlibDeflate];
    NSLog(@"压缩前的数据长度：%@，zlib压缩后的数据长度：%@", @(orgData.length), @(zlibData.length));
    NSData *zd = [zlibData dr_zlibInflate];
    NSLog(@"zlib解压后的数据长度：%@", @(zd.length));
    NSString *zlibInflate = [zd dr_utf8String];
    NSLog(@"zlib解压后的数据：%@", zlibInflate);
    
    // AES加解密
    NSString *key = @"abcdefghighklmjkhfgklmhjcnhdgdsf";
    NSString *iv = @"gdkglurgbdhjhgeu";
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    NSData *aes256EncodedData = [orgData dr_aes256EncryptWithKey:keyData iv:ivData];
    NSString *aes256EncodedStr = [aes256EncodedData dr_hexString];
    NSLog(@"AES256加密后的数据：%@", aes256EncodedStr);
    NSData *aes256DecodedData = [aes256EncodedData dr_aes256DecryptWithkey:keyData iv:ivData];
    NSString *aes256DecodedStr = [aes256DecodedData dr_utf8String];
    NSLog(@"AES256解密后的数据：%@", aes256DecodedStr);
    
}
- (void)stringTest{
    NSString *str = @"base64加密前的数据base64加密前的数据base64加密前的数据base64加密前的数据base64加密前的数据";
    NSString *base64Str = [str dr_base64EncodedString];
    NSLog(@"base64编码：%@", base64Str);
    NSString *base64DecodeStr = [base64Str dr_base64DecodedString];
    NSLog(@"base64解码：%@", base64DecodeStr);
    
    UIFont *font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    CGSize size = [str dr_sizeForFont:font size:CGSizeMake(100, 1000) mode:NSLineBreakByWordWrapping];
    NSLog(@"------size:%@", NSStringFromCGSize(size));
    
    CGFloat strWidth = [str dr_widthForFont:font];
    NSLog(@"------str.width:%@", @(strWidth));
    
    NSString *email = @"1126738420@qq.com";
    NSString *emailRegex = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    BOOL isEmail = [email dr_matchesRegex:emailRegex options:NSRegularExpressionCaseInsensitive];
    NSLog(@"----字符串(%@)是否为email:%@", email, @(isEmail));
    
    NSString *testStr = @"clc_cfzxyq@163.com#wcowfjwogjwoiejfiow##12321@qq.com&298349845fwe&ctftf:iLoveiOS@qq.com";
    [testStr dr_enumerateRegexMatches:emailRegex
                              options:NSRegularExpressionCaseInsensitive
                           usingBlock:^(NSString * _Nonnull match, NSRange matchRange, BOOL * _Nonnull stop) {
        NSLog(@"-----匹配到的email：%@", match);
    }];
    
    // 将匹配到的邮箱，替换成@邮箱
    NSString *resStr = [testStr dr_stringByReplacingRegex:emailRegex
                                                  options:kNilOptions
                                               withString:@"@邮箱"];
    NSLog(@"-----替换后的字符串：%@", resStr);
    
    NSString *uuid = [NSString dr_uuidString];
    NSLog(@"uuid：%@,长度：%@", uuid, @(uuid.length));
}

- (void)arrayTest{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:3];
    [arr addObject:@{@"key1": @"value1"}];
    [arr addObject:@{@"key2": @"value2"}];
    [arr addObject:@{@"key3": @"value3"}];
    NSString *plistXml = [arr dr_plistString];
    NSLog(@"-----pListXml:%@", plistXml);
    
    NSMutableArray *list = @[@1, @2, @3, @4, @5].mutableCopy;
    [list dr_reverse];
    NSLog(@"-----反转后的数组：%@", list);
}

- (void)dictionaryTest{
    NSDictionary *dic = @{@"key1": @"value1",@"key3": @"value3",@"key2": @"value2",};
    NSArray *keys = [dic dr_allKeysSorted];
    NSLog(@"-----:%@", keys);
    
    NSArray *values = [dic dr_allValuesSortedByKeys];
    NSLog(@"-----:%@", values);
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"fdfd.xml"];
    NSDictionary *xmldic = [DRDictionaryParser dictionaryWithFile:path];
    if ([xmldic isKindOfClass:[NSMutableDictionary class]]) {
        NSLog(@"-----是可变字典");
    }else{
        NSLog(@"-----不是可变字典");
    }
    NSLog(@"xml文件字典：%@", xmldic);
}

- (void)testIsaHook{
    DrIsaHookDemo *isaHook1 = [[DrIsaHookDemo alloc] init];
    NSInvocation *orgInv; // 注意：这里无需添加__block，虽然添加也无所谓
    [isaHook1 dr_hookMethod:@selector(loginWithUserName:password:)
                  withBlock:^BOOL (id caller, NSString *userName, NSString *pwd){
        [NSInvocation dr_setArgumentsForInvocation:orgInv, userName, pwd];
        [orgInv invokeWithTarget:caller];
        BOOL res = [[orgInv dr_getReturnValue] boolValue];
        NSLog(@"hook1-isaHook1原始loginWithUserName:password:方法返回值: %@", @(res));
        return [userName isEqualToString:@"hello"] && [pwd isEqualToString:@"abc"];
    } orgInvocation:&orgInv];
    
    // 注意：多次hook同一个实例的同一个方法，最后一个hook的方法会覆盖上面的hook方法，上面的hook将失效
    NSInvocation *orgInv2; // 注意：这里无需添加__block，虽然添加也无所谓
    [isaHook1 dr_hookMethod:@selector(loginWithUserName:password:)
                  withBlock:^BOOL (id caller, NSString *userName, NSString *pwd){
        [NSInvocation dr_setArgumentsForInvocation:orgInv2, userName, pwd];
        [orgInv2 invokeWithTarget:caller];
        BOOL res = [[orgInv2 dr_getReturnValue] boolValue];
        NSLog(@"hook2-isaHook1原始loginWithUserName:password:方法返回值: %@", @(res));
        return [userName isEqualToString:@"hello"] && [pwd isEqualToString:@"abc"];
    } orgInvocation:&orgInv2];
    
    // 注意：以上的orgInv与orgInv2实际上是同一个方法的调用者，都代表原始方法
    

    if ([isaHook1 loginWithUserName:@"hello" password:@"abc"]){
        NSLog(@"isaHook1 login success");
    }else{
        NSLog(@"isaHook1 login fail");
    }
    
    // 注意：这里的isaHook2不受上面hook的影响
    DrIsaHookDemo *isaHook2 = [[DrIsaHookDemo alloc] init];
    if ([isaHook2 loginWithUserName:@"hello" password:@"abc"]){
        NSLog(@"isaHook2 login success");
    }else{
        NSLog(@"isaHook2 login fail");
    }
    
}

- (void)dateTest{
    NSDate *date = [NSDate date];
    NSLog(@"year：%ld", date.dr_year);
    NSLog(@"month：%ld", date.dr_month);
    NSLog(@"day：%ld", date.dr_day);
    NSLog(@"hour：%ld", date.dr_hour);
    NSLog(@"minute：%ld", date.dr_minute);
    NSLog(@"second：%ld", date.dr_second);
    NSLog(@"nanosecond：%ld", date.dr_nanosecond);
    NSLog(@"weekday：%ld", date.dr_weekday);
    NSLog(@"weekdayOrdinal：%ld", date.dr_weekdayOrdinal);
    NSLog(@"weekOfMonth：%ld", date.dr_weekOfMonth);
    NSLog(@"weekOfYear：%ld", date.dr_weekOfYear);
    NSLog(@"yearForWeekOfYear：%ld", date.dr_yearForWeekOfYear);
    NSLog(@"quarter：%ld", date.dr_quarter);
    NSLog(@"isLeapMonth：%@", @(date.dr_isLeapMonth));
    NSLog(@"isLeapYear：%@", @(date.dr_isLeapYear));
    NSLog(@"isToday：%@", @(date.dr_isToday));
    NSLog(@"ISOFormat:%@", [date dr_stringWithFormat:@"yyyy-MM-dd hh:mm:ss"]);
    
    NSDate *date2 = [date dr_dateByAddingDays:-2];
    NSLog(@"date2.ios:%@", [date2 dr_stringWithFormat:@"yyyy-MM-dd hh:mm:ss a z"]);
}

- (void)notifyTest{
    NSString *name = @"myNotify";
    [NSNotificationCenter dr_addObserver:self
                                selector:@selector(receiveNotify:)
                                    name:name
                                  object:nil];
    dispatch_after_on_main_queue(2, ^{
        [NSNotificationCenter dr_postOnMainThreadWithName:name object:nil];
    });
}


- (void)keyedArchiverOrUnArchiverTest{
    
    NSError *error;
    NSData *object = [@"123" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSKeyedArchiver dr_archivedDataWithRootObject:object
                                            requiringSecureCoding:YES
                                                            error:&error];
    if (error) {
        NSLog(@"error:%@", error);
    }else{
        NSLog(@"data:%@", data);
    }
    
    id unArchiverObj = [NSKeyedUnarchiver dr_unarchivedObjectOfClass:NSData.class
                                                            fromData:data
                                                               error:&error];
    if (error) {
        NSLog(@"error:%@", error);
    }else{
        if ([unArchiverObj isKindOfClass:NSData.class]) {
            NSString *str = [(NSData *)unArchiverObj dr_utf8String];
            NSLog(@"解档后的对象:%@", str);
        }else{
            NSLog(@"解档对象非NSData对象:%@", unArchiverObj);
        }
    }
}

- (void)timerTest{
//    _timer = [NSTimer dr_scheduledTimerWithTimeInterval:1
//                                                 target:self
//                                               selector:@selector(runTimer)
//                                               userInfo:nil
//                                                repeats:YES];
//    // 设置10s后执行，否则立即执行
//    _timer.fireDate = [[NSDate new] dr_dateByAddingSeconds:10];
    
    @weakify(self);
    [NSTimer dr_scheduledTimerWithTimeInterval:1
                                         block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        if (!self) {
            [timer invalidate];
            NSLog(@"----timer invalidate");
        }
        NSLog(@"----timer block调用");
    } repeats:YES];
    
    _timer = [NSTimer dr_timerWithTimeInterval:2
                                        target:self
                                      selector:@selector(runTimer)
                                      userInfo:nil
                                       repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)runTimer{
    NSLog(@"-----timer:%@", _timer);
}

- (void)receiveNotify:(NSNotification *)notify{
    NSLog(@"----收到通知：%@", notify.name);
}

- (NSString *)hookMethodTest:(int)count{
    NSLog(@"hookMethodTest receive param:%@", @(count));
    return [NSString stringWithFormat:@"hook_%@", @(count)];
}
+ (NSString *)hookClassMethodTest:(NSString *)str {
    NSLog(@"hookClassMethodTest receive param:%@", str);
    return [NSString stringWithFormat:@"hook_%@", str];
}

@end
