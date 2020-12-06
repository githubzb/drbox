//
//  NSObject+DRModel.m
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSObject+DRModel.h"
#import "DRClassInfo.h"
#import "DRModelProtocol.h"

@interface _DRIvarWrap : NSObject

/// 原成员变量名
@property (nonatomic, readonly, strong) NSString *ivarName;
/// 自身的class
@property (nonatomic, readonly, assign, nullable) Class cls;
/// 当前成员变量类型
@property (nonatomic, readonly, assign) DREncodingType type;
/// 映射的字典key：[name, userName, user.name...]
@property (nonatomic, copy) NSArray<NSString *> *keyMappers;
/// 转json时对应的key
@property (nonatomic, copy) NSString *toJsonKey;
/// 如果cls为数组或字典，innerCls：表示这个数组或字典值对应的元素类型
@property (nonatomic, assign, nullable) Class innerCls;

- (nullable instancetype)initWithIvarInfo:(DRClassIvarInfo *)info;

@end

@implementation _DRIvarWrap

- (instancetype)initWithIvarInfo:(DRClassIvarInfo *)info{
    if (!info || info.name.length==0) return nil;
    self = [super init];
    if (self) {
        _ivarName = [info.name copy];
        _cls = info.cls;
        _type = info.type;
    }
    return self;
}

@end

@interface _DRModelWrap : NSObject

/// 自身的class
@property (nonatomic, readonly, assign, nullable) Class cls;
/// 当前model的成员变量
@property (nonatomic, readonly, strong) NSSet<_DRIvarWrap *> *ivars;

- (nullable instancetype)initWithModelClass:(Class)cls;

+ (nullable instancetype)modelClass:(Class)cls;

@end

@implementation _DRModelWrap

- (instancetype)initWithModelClass:(Class)cls{
    if (!cls) return nil;
    self = [super init];
    if (self) {
        _cls = cls;
        DRClassInfo *info = [DRClassInfo infoWithClass:cls];
        NSMutableSet *set = [NSMutableSet setWithCapacity:info.ivarInfos.count];
        while (info) {
            for (DRClassIvarInfo *ivar in [info.ivarInfos allValues]) {
                _DRIvarWrap *iw = [[_DRIvarWrap alloc] initWithIvarInfo:ivar];
                if (iw.ivarName) [set addObject:iw];
            }
            if (info.superCls &&
                info.superCls != [NSObject class] &&
                info.superCls != [NSProxy class]) {
                info = info.superClsInfo;
            }else{
                info = nil;
            }
        }
        _ivars = [NSSet setWithSet:set];
    }
    return self;
}

+ (instancetype)modelClass:(Class)cls{
    if (!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    _DRModelWrap *modelWrap = CFDictionaryGetValue(cache, (__bridge const void *)cls);
    dispatch_semaphore_signal(lock);
    if (!modelWrap) {
        modelWrap = [[_DRModelWrap alloc] initWithModelClass:cls];
        if (modelWrap) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)cls, (__bridge const void *)modelWrap);
            dispatch_semaphore_signal(lock);
        }
    }
    return modelWrap;
}

@end


@implementation NSObject (DRModel)

+ (instancetype)modelWithDictionary:(NSDictionary *)dic{
    if (!dic || dic == (id)kCFNull) return nil;
    if (![dic isKindOfClass:[NSDictionary class]]) return nil;
    Class cls = [self class];
    _DRModelWrap *mw = [_DRModelWrap modelClass:cls];
    if (!mw) return nil;
    for (_DRIvarWrap *ivar in mw.ivars) {
        NSLog(@"ivar.name: %@", ivar.ivarName);
    }
    NSObject *instance = [cls new];
    return instance;
}

+ (id)transformValue:(id)value{
    if (!value || value == (id)kCFNull) return nil;
    return value;
}

@end
