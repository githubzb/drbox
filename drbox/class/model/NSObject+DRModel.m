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
#import "NSNumber+drbox.h"

typedef NS_ENUM (NSUInteger, DREncodingNSType) {
    DREncodingTypeNSUnknown = 0,
    DREncodingTypeNSString,
    DREncodingTypeNSMutableString,
    DREncodingTypeNSValue,
    DREncodingTypeNSNumber,
    DREncodingTypeNSDecimalNumber,
    DREncodingTypeNSData,
    DREncodingTypeNSMutableData,
    DREncodingTypeNSDate,
    DREncodingTypeNSURL,
    DREncodingTypeNSArray,
    DREncodingTypeNSMutableArray,
    DREncodingTypeNSDictionary,
    DREncodingTypeNSMutableDictionary,
    DREncodingTypeNSSet,
    DREncodingTypeNSMutableSet
};

static inline DREncodingNSType DRClassGetNSType(Class cls) {
    if (!cls) return DREncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return DREncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return DREncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return DREncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return DREncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return DREncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return DREncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return DREncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return DREncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return DREncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return DREncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return DREncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return DREncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return DREncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return DREncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return DREncodingTypeNSSet;
    return DREncodingTypeNSUnknown;
}

@interface _DRIvarWrap : NSObject

/// 原成员变量名
@property (nonatomic, readonly, strong) NSString *ivarName;
/// 自身的class
@property (nonatomic, readonly, assign, nullable) Class cls;
/// 当前成员变量类型
@property (nonatomic, readonly, assign) DREncodingType type;
/// 对应需要特殊处理的NS类型
@property (nonatomic, readonly, assign) DREncodingNSType nsType;
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
        _nsType = DRClassGetNSType(_cls);
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

static inline BOOL DREncodingTypeIsCNumber(DREncodingType type) {
    switch (type & DREncodingTypeMask) {
        case DREncodingTypeBool:
        case DREncodingTypeInt8:
        case DREncodingTypeUInt8:
        case DREncodingTypeInt16:
        case DREncodingTypeUInt16:
        case DREncodingTypeInt32:
        case DREncodingTypeUInt32:
        case DREncodingTypeInt64:
        case DREncodingTypeUInt64:
        case DREncodingTypeFloat:
        case DREncodingTypeDouble:
        case DREncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

/**
 设置class实例的成员变量值
 
 @param instance class实例
 @param ivar class的成员变量
 @param map class对应的映射字典
 */
static inline void DRSetClassInstanceIvarValue(NSObject *instance, _DRIvarWrap *ivar, NSDictionary *map){
    if (!instance) return;
    id value = nil; // map中对应ivar的值
    for (NSString *keyPath in ivar.keyMappers) {
        value = [map valueForKeyPath:keyPath];
        if (value) break;
    }
    if (DREncodingTypeIsCNumber(ivar.type)) {
        // 当前ivar是数字类型
        if ([value isKindOfClass:[NSString class]]) {
            value = [NSNumber dr_numberWithString:value];
        }
        if (![value isKindOfClass:[NSNumber class]]) {
            value = [NSNumber numberWithInt:0];
        }
    }else if (ivar.nsType){
        
        
        
    }else if ((ivar.type & DREncodingTypeMask) == DREncodingTypeSEL){
//        if (<#condition#>) {
//            <#statements#>
//        }
    }else if ((ivar.type & DREncodingTypeMask) == DREncodingTypeBlock){
        
    }else if ((ivar.type & DREncodingTypeMask) == DREncodingTypeObject){
        
    }else{
        // 类型不支持
        return;
    }
    
    [instance setValue:value forKeyPath:ivar.ivarName];
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
