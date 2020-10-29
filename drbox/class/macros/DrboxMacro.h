//
//  DrboxMacro.h
//  drbox
//
//  Created by dr.box on 2020/7/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrboxCommonMacro.h"
#import <pthread.h>

#ifndef DrboxMacro_h
#define DrboxMacro_h

DR_EXTERN_C_BEGIN

#define DRColorFromRGB(r,g,b)      [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define DRColorFromRGBA(r,g,b,a)   [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define DRMainScreenW              [UIScreen mainScreen].bounds.size.width
#define DRMainScreenH              [UIScreen mainScreen].bounds.size.height
#define DRMainScreenScale          [UIScreen mainScreen].scale
#define DRStatusBarFrame           [UIApplication sharedApplication].statusBarFrame

static CGFloat DRDesignBaseWidth = 375.0; // 设计稿的基准宽度
// 重置设计稿的基准宽度
#define DRResetDesignBaseWidth(w)  DRDesignBaseWidth = (w);
// 传入设计稿中标注的pt单位值，按比例计算出合适的pt值，375.0：设计稿的尺寸
#define DRRpt(pt)                  round((pt)*DRMainScreenW/DRDesignBaseWidth)
// 传入设计稿中标注的px单位值，按比例计算出合适的pt值
#define DRRpx(px)                  DRRpt(px/DRMainScreenScale)

#ifndef onDefer
typedef void (^dr_cleanupBlock_t)(void);

static inline void dr_executeCleanupBlock (__strong dr_cleanupBlock_t *block) {
    (*block)();
}

// 类似于swift的defer函数
#define onDefer \
    dr_keywordify \
__strong dr_cleanupBlock_t drmacro_concat(dr_exitBlock_, __LINE__) __attribute__((cleanup(dr_executeCleanupBlock), unused)) = ^
#endif

// 解决block中的循环引用
#ifndef weakify
    #if __has_feature(objc_arc)
    #define weakify(o) dr_keywordify __weak __typeof__(o) __weak_##o##__ = o
    #else
    #define weakify(o) dr_keywordify __block __typeof__(o) __block_##o##__ = o
    #endif
#endif

#ifndef strongify
    #if __has_feature(objc_arc)
    #define strongify(o) dr_keywordify __strong __typeof__(o) o = __weak_##o##__
    #else
    #define strongify(o) dr_keywordify __typeof__(o) o = __block_##o##__
    #endif
#endif

/// 交换_a_和_b_两个变量的值
#define DR_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)

// 在主队列中异步执行block
static inline void dispatch_async_on_main_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

// 在主队列中同步执行block
static inline void dispatch_sync_on_main_queue(dispatch_block_t block) {
    if (pthread_main_np()!=0) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

/**
 延时执行任务

 @param delayTime 延迟时间（单位：秒）
 @param block 执行代码块，在主线程执行
*/
static inline void dispatch_after_on_main_queue(NSTimeInterval delayTime, dispatch_block_t block){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

/**
 判断系统版本是否>=version
 */
static inline BOOL DRSystemVersionGreaterOrEqualTo(NSString *version) {
    NSString *sysV = [UIDevice currentDevice].systemVersion;
    NSComparisonResult res = [sysV compare:version options:NSNumericSearch];
    return res == NSOrderedDescending || res == NSOrderedSame;
}
/**
判断系统版本是否<version
*/
static inline BOOL DRSystemVersionLessThan(NSString *version) {
    NSString *sysV = [UIDevice currentDevice].systemVersion;
    NSComparisonResult res = [sysV compare:version options:NSNumericSearch];
    return res == NSOrderedAscending;
}

/**
判断系统版本是否==version
*/
static inline BOOL DRSystemVersionEqualTo(NSString *version) {
    NSString *sysV = [UIDevice currentDevice].systemVersion;
    NSComparisonResult res = [sysV compare:version options:NSNumericSearch];
    return res == NSOrderedSame;
}

/**
判断app版本是否>=version
*/
static inline BOOL DRAppVersionGreaterOrEqualTo(NSString *version) {
    NSString *appV = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSComparisonResult res = [appV compare:version options:NSNumericSearch];
    return res == NSOrderedSame || res == NSOrderedDescending;
}

/**
判断app版本是否<version
*/
static inline BOOL DRAppVersionLessThan(NSString *version) {
    NSString *appV = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSComparisonResult res = [appV compare:version options:NSNumericSearch];
    return res == NSOrderedAscending;
}

/**
判断app版本是否==version
*/
static inline BOOL DRAppVersionEqualTo(NSString *version) {
    NSString *appV = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSComparisonResult res = [appV compare:version options:NSNumericSearch];
    return res == NSOrderedSame;
}

/// 创建NSError对象
static inline NSError * DRCreateError(NSErrorDomain domain, NSInteger code, NSString *desc){
    if (!domain) return nil;
    if (desc) {
        return [NSError errorWithDomain:domain code:code userInfo:@{ NSLocalizedDescriptionKey: desc }];
    }
    return [NSError errorWithDomain:domain code:code userInfo:nil];
}

/// 设置error的值为err
static inline void DRSetError(NSError **error, NSError *err){
    if (error) {
        *error = err;
    }
};

DR_EXTERN_C_END

#endif /* DrboxMacro_h */
