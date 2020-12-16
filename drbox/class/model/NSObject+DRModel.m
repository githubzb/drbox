//
//  NSObject+DRModel.m
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSObject+DRModel.h"
#import "DRClassInfo.h"
#import "NSNumber+drbox.h"
#import <objc/message.h>
#import "NSData+drbox.h"
#import "NSDate+drbox.h"
#import "NSString+drbox.h"
#import <UIKit/UIKit.h>

static NSString * const kTypeUIEdgeInsetsPrefix = @"{UIEdgeInsets=";
static NSString * const kTypeCGPointPrefix = @"{CGPoint=";
static NSString * const kTypeCGRectPrefix = @"{CGRect=";
static NSString * const kTypeCGSizePrefix = @"{CGSize=";
static NSString * const kTypeUIOffsetPrefix = @"{UIOffset=";
static NSString * const kTypeCGAffineTransformPrefix = @"{CGAffineTransform=";


typedef NS_ENUM (NSUInteger, DREncodingNSType) {
    DREncodingNSTypeNSUnknown = 0,
    DREncodingNSTypeNSString,
    DREncodingNSTypeNSMutableString,
    DREncodingNSTypeNSValue,
    DREncodingNSTypeNSNumber,
    DREncodingNSTypeNSDecimalNumber,
    DREncodingNSTypeNSData,
    DREncodingNSTypeNSMutableData,
    DREncodingNSTypeNSDate,
    DREncodingNSTypeNSURL,
    DREncodingNSTypeNSArray,
    DREncodingNSTypeNSMutableArray,
    DREncodingNSTypeNSDictionary,
    DREncodingNSTypeNSMutableDictionary,
    DREncodingNSTypeNSSet,
    DREncodingNSTypeNSMutableSet
};

static inline DREncodingNSType DRClassGetNSType(Class cls) {
    if (!cls) return DREncodingNSTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return DREncodingNSTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return DREncodingNSTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return DREncodingNSTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return DREncodingNSTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return DREncodingNSTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return DREncodingNSTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return DREncodingNSTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return DREncodingNSTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return DREncodingNSTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return DREncodingNSTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return DREncodingNSTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return DREncodingNSTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return DREncodingNSTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return DREncodingNSTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return DREncodingNSTypeNSSet;
    return DREncodingNSTypeNSUnknown;
}

@interface _DRIvarWrap : NSObject

@property (nonatomic, readonly, assign) Ivar ivar;
/// 原成员变量名
@property (nonatomic, readonly, strong) NSString *ivarName;
/// 成员变量对应的属性名
@property (nonatomic, readonly, strong, nullable) NSString *propertyName;
/// 自身的class
@property (nonatomic, readonly, assign, nullable) Class cls;
/// 当前成员变量类型
@property (nonatomic, readonly, assign) DREncodingType type;
/// 属性类型（包括：属性描述，例如：copy,strong,weak），当ivar没有属性时为DREncodingTypeUnknown
@property (nonatomic, readonly, assign) DREncodingType propertyType;
/// 当前成员变量类型（字符串表示法）
@property (nonatomic, readonly, strong) NSString *typeString;
/// 对应需要特殊处理的NS类型
@property (nonatomic, readonly, assign) DREncodingNSType nsType;
@property (nonatomic, readonly, assign) SEL getter;
@property (nonatomic, readonly, assign) SEL setter;
/// 映射的字典key：[name, userName, user.name...]
@property (nonatomic, copy) NSSet<NSString *> *keyMappers;
/// 转json时对应的key
@property (nonatomic, copy) NSString *toJsonKey;
/// 如果cls为数组或字典，innerCls：表示这个数组或字典值对应的元素类型
@property (nonatomic, assign, nullable) Class innerCls;

- (nullable instancetype)initWithIvarInfo:(DRClassIvarInfo *)info propertyInfo:(DRClassPropertyInfo *)propertyInfo;

@end

@implementation _DRIvarWrap

- (instancetype)initWithIvarInfo:(DRClassIvarInfo *)info propertyInfo:(DRClassPropertyInfo *)propertyInfo{
    if (!info || info.name.length==0) return nil;
    self = [super init];
    if (self) {
        _ivar = info.ivar;
        _ivarName = [info.name copy];
        _cls = info.cls;
        _type = info.type;
        _typeString = [info.typeEncoding copy];
        _nsType = DRClassGetNSType(_cls);
        _getter = propertyInfo.getter;
        _setter = propertyInfo.setter;
        _propertyType = propertyInfo ? propertyInfo.type : DREncodingTypeUnknown;
        _propertyName = [propertyInfo.name copy];
    }
    return self;
}

@end

@interface _DRModelWrap : NSObject

/// 自身的class
@property (nonatomic, readonly, assign, nullable) Class cls;
/// 当前model的成员变量（包括父类的）
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
            NSMutableDictionary *propertyMap = [NSMutableDictionary dictionaryWithCapacity:info.propertyInfos.count];
            for (DRClassPropertyInfo *pro in [info.propertyInfos allValues]) {
                if (pro.ivarName) {
                    propertyMap[pro.ivarName] = pro;
                }
            }
            
            for (DRClassIvarInfo *ivar in [info.ivarInfos allValues]) {
                DRClassPropertyInfo *property = propertyMap[ivar.name];
                _DRIvarWrap *iw = [[_DRIvarWrap alloc] initWithIvarInfo:ivar propertyInfo:property];
                if (iw.ivarName) [set addObject:iw];
            }
            [propertyMap removeAllObjects];
            if (info.superCls &&
                info.superCls != [NSObject class] &&
                info.superCls != [NSProxy class]) {
                info = info.superClsInfo;
            }else{
                info = nil;
            }
        }
        _ivars = [NSSet setWithSet:set];
        
        /// 映射信息
        NSDictionary *innerClassMap = nil;
        NSDictionary *toJsonKeyMap = nil;
        NSDictionary *keyMap = nil;
        if ([cls conformsToProtocol:@protocol(DRModel)]) {
            if ([cls respondsToSelector:@selector(toModelContainerInnerClassMapper)]) {
                innerClassMap = [((id<DRModel>)cls) toModelContainerInnerClassMapper];
            }
            if ([cls respondsToSelector:@selector(toDictionaryKeyMapper)]) {
                toJsonKeyMap = [((id<DRModel>)cls) toDictionaryKeyMapper];
            }
            if ([cls respondsToSelector:@selector(toModelKeyMapper)]) {
                keyMap = [((id<DRModel>)cls) toModelKeyMapper];
            }
        }
        
        for (_DRIvarWrap *ivar in _ivars) {
            @autoreleasepool {
                // key maps
                NSMutableSet<NSString *> *keyMappers = [NSMutableSet set];
                if (keyMap) {
                    id keyList = nil;
                    if (ivar.propertyName) {
                        keyList = keyMap[ivar.propertyName] ?: keyMap[ivar.ivarName];
                    }else{
                        keyList = keyMap[ivar.ivarName];
                    }
                    if ([keyList isKindOfClass:[NSString class]]) {
                        [keyMappers addObject:keyList];
                    }else if ([keyList isKindOfClass:[NSArray class]]){
                        for (id key in (NSArray *)keyList) {
                            if ([key isKindOfClass:[NSString class]]) {
                                [keyMappers addObject:key];
                            }
                        }
                    }
                }
                if (ivar.propertyName) {
                    [keyMappers addObject:ivar.propertyName];
                }
                [keyMappers addObject:ivar.ivarName];
                ivar.keyMappers = [NSSet setWithSet:keyMappers];
                
                
                // to dictionary key map
                if (toJsonKeyMap) {
                    if (ivar.propertyName) {
                        ivar.toJsonKey = toJsonKeyMap[ivar.propertyName] ?: (toJsonKeyMap[ivar.ivarName] ?: ivar.propertyName);
                    }else{
                        ivar.toJsonKey = toJsonKeyMap[ivar.ivarName] ?: ivar.ivarName;
                    }
                }else{
                    ivar.toJsonKey = ivar.propertyName ?: ivar.ivarName;
                }
                
                // inner class map
                if (innerClassMap) {
                    id value = nil;
                    if (ivar.propertyName) {
                        value = innerClassMap[ivar.propertyName] ?: innerClassMap[ivar.ivarName];
                    }else{
                        value = innerClassMap[ivar.ivarName];
                    }
                    
                    Class innerClass;
                    if ([value isKindOfClass:[NSString class]]) {
                        innerClass = NSClassFromString(value);
                    }else{
                        Class class = object_getClass(value);
                        if (class_isMetaClass(class)) {
                            innerClass = value;
                        }
                    }
                    ivar.innerCls = innerClass;
                }
            }
        }
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

#define DR_GET_IVAR_VALUE(_obj, _getterSelector, _ivarType) \
((_ivarType (*)(id, SEL))(void *) objc_msgSend)((id)_obj, _getterSelector)

#define DR_SET_IVAR_VALUE(_obj, _setterSelector, _ivarType, _value) \
((void (*)(id, SEL, _ivarType))(void *) objc_msgSend)((id)_obj, _setterSelector, _value)


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
        value = [map dr_valueForKeyPath:keyPath];
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
        if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
            
            switch (ivar.type & DREncodingTypeMask) {
                case DREncodingTypeBool: {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, bool, ((NSNumber *)value).boolValue);
                } break;
                case DREncodingTypeInt8: {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, int8_t, (int8_t)((NSNumber *)value).charValue);
                } break;
                case DREncodingTypeUInt8: {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, uint8_t, (uint8_t)((NSNumber *)value).unsignedCharValue);
                } break;
                case DREncodingTypeInt16: {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, int16_t, (int16_t)((NSNumber *)value).shortValue);
                } break;
                case DREncodingTypeUInt16: {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, uint16_t, (uint16_t)((NSNumber *)value).unsignedShortValue);
                } break;
                case DREncodingTypeInt32: {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, int32_t, (int32_t)((NSNumber *)value).intValue);
                }
                case DREncodingTypeUInt32: {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, uint32_t, (uint32_t)((NSNumber *)value).unsignedIntValue);
                } break;
                case DREncodingTypeInt64: {
                    if ([value isKindOfClass:[NSDecimalNumber class]]) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, int64_t, (int64_t)((NSDecimalNumber *)value).stringValue.longLongValue);
                    } else {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, uint64_t, (uint64_t)((NSNumber *)value).longLongValue);
                    }
                } break;
                case DREncodingTypeUInt64: {
                    if ([value isKindOfClass:[NSDecimalNumber class]]) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, int64_t, (int64_t)((NSDecimalNumber *)value).stringValue.longLongValue);
                    } else {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, uint64_t, (uint64_t)((NSNumber *)value).unsignedLongLongValue);
                    }
                } break;
                case DREncodingTypeFloat: {
                    float f = ((NSNumber *)value).floatValue;
                    if (isnan(f) || isinf(f)) f = 0;
                    DR_SET_IVAR_VALUE(instance, ivar.setter, float, f);
                } break;
                case DREncodingTypeDouble: {
                    double d = ((NSNumber *)value).doubleValue;
                    if (isnan(d) || isinf(d)) d = 0;
                    DR_SET_IVAR_VALUE(instance, ivar.setter, double, d);
                } break;
                case DREncodingTypeLongDouble: {
                    long double d = ((NSNumber *)value).doubleValue;
                    if (isnan(d) || isinf(d)) d = 0;
                    DR_SET_IVAR_VALUE(instance, ivar.setter, long double, (long double)d);
                } break;
                default:{
                    [instance dr_setValue:value forKey:ivar.ivarName];
                }
                    break;
            }
        }else{
            [instance dr_setValue:value forKey:ivar.ivarName];
        }
    }else if (ivar.nsType){
        // 成员赋值，isMutable：YES(val是可变值类型)
        void (^setIvarValue)(id, BOOL) = ^(id val, BOOL isMutable){
            if (isMutable && ivar.propertyType != DREncodingTypeUnknown &&
                (ivar.propertyType & DREncodingTypePropertyMask) == DREncodingTypePropertyCopy) {
                // 由于copy修饰的属性，会将可变值转成不可变，所以这里采用直接对成员赋值
                object_setIvar(instance, ivar.ivar, val);
                return;
            }
            if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                DR_SET_IVAR_VALUE(instance, ivar.setter, id, val);
            }else{
                [instance dr_setValue:val forKey:ivar.ivarName];
            }
        };
        if (value == (id)kCFNull) {
            setIvarValue(nil, NO);
        }else{
            switch (ivar.nsType) {
                case DREncodingNSTypeNSString:
                case DREncodingNSTypeNSMutableString: {
                    if ([value isKindOfClass:[NSString class]]) {
                        if (ivar.nsType == DREncodingNSTypeNSString) {
                            setIvarValue(value, NO);
                        } else {
                            setIvarValue([(NSString *)value mutableCopy], YES);
                        }
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        NSNumber *num = (NSNumber *)value;
                        if (ivar.nsType == DREncodingNSTypeNSString) {
                            setIvarValue(num.stringValue, NO);
                        }else{
                            setIvarValue([num.stringValue mutableCopy], YES);
                        }
                    } else if ([value isKindOfClass:[NSData class]]) {
                        NSString *string = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        if ([(NSData *)value length]>0 && string.length==0) {
                            string = [(NSData *)value dr_hexString];
                        }
                        if (ivar.nsType == DREncodingNSTypeNSString) {
                            setIvarValue(string, NO);
                        }else{
                            setIvarValue([string mutableCopy], YES);
                        }
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        if (ivar.nsType == DREncodingNSTypeNSString) {
                            setIvarValue([(NSURL *)value absoluteString], NO);
                        }else{
                            setIvarValue([[(NSURL *)value absoluteString] mutableCopy], YES);
                        }
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        if (ivar.nsType == DREncodingNSTypeNSString) {
                            setIvarValue([(NSAttributedString *)value string], NO);
                        }else{
                            setIvarValue([[(NSAttributedString *)value string] mutableCopy], YES);
                        }
                    }
                } break;
                    
                case DREncodingNSTypeNSValue:
                case DREncodingNSTypeNSNumber:
                case DREncodingNSTypeNSDecimalNumber: {
                    if (ivar.nsType == DREncodingNSTypeNSNumber) {
                        setIvarValue([NSNumber dr_numberWithObj:value], NO);
                    } else if (ivar.nsType == DREncodingNSTypeNSDecimalNumber) {
                        if ([value isKindOfClass:[NSDecimalNumber class]]) {
                            setIvarValue(value, NO);
                        } else if ([value isKindOfClass:[NSNumber class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                            setIvarValue(decNum, NO);
                        } else if ([value isKindOfClass:[NSString class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = decNum.decimalValue;
                            if (dec._length == 0 && dec._isNegative) {
                                decNum = nil; // NaN
                            }
                            setIvarValue(decNum, NO);
                        }
                    } else { // DREncodingNSTypeNSValue
                        if ([value isKindOfClass:[NSValue class]]) {
                            setIvarValue(value, NO);
                        }
                    }
                }
                    break;
                    
                case DREncodingNSTypeNSData:
                case DREncodingNSTypeNSMutableData: {
                    if ([value isKindOfClass:[NSData class]]) {
                        if (ivar.nsType == DREncodingNSTypeNSData) {
                            setIvarValue(value, NO);
                        } else {
                            NSMutableData *data = ((NSData *)value).mutableCopy;
                            setIvarValue(data, YES);
                        }
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSData *data = nil;
                        if ([instance.class conformsToProtocol:@protocol(DRModel)] &&
                            [instance.class respondsToSelector:@selector(dataConvertFromString:)]) {
                            data = [((id<DRModel>)instance.class) dataConvertFromString:value];
                        }else{
                            data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        }
                        if (ivar.nsType == DREncodingNSTypeNSData) {
                            setIvarValue(data, NO);
                        }else{
                            setIvarValue(data.mutableCopy, YES);
                        }
                    }
                }
                    break;
                    
                case DREncodingNSTypeNSDate: {
                    if ([value isKindOfClass:[NSDate class]]) {
                        setIvarValue(value, NO);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        
                        NSDate *date = nil;
                        if ([instance.class conformsToProtocol:@protocol(DRModel)] &&
                             [instance.class respondsToSelector:@selector(dateConvertFromString:)]) {
                            date = [((id<DRModel>)instance.class) dateConvertFromString:value];
                        }else{
                            date = [NSDate dr_dateWithString:value];
                        }
                        setIvarValue(date, NO);
                    }else if ([value isKindOfClass:[NSNumber class]]){
                        
                        NSTimeInterval time = [(NSNumber *)value doubleValue];
                        NSDate *date = nil;
                        if ([instance.class conformsToProtocol:@protocol(DRModel)] &&
                            [instance.class respondsToSelector:@selector(dateConvertFromTimeInterval:)]) {
                            date = [((id<DRModel>)instance.class) dateConvertFromTimeInterval:time];
                        }else{
                            date = [NSDate dateWithTimeIntervalSince1970:time];
                        }
                        setIvarValue(date, NO);
                    }
                }
                    break;
                    
                case DREncodingNSTypeNSURL: {
                    if ([value isKindOfClass:[NSURL class]]) {
                        setIvarValue(value, NO);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSString *str = [(NSString *)value dr_trim];
                        if (str.length == 0) {
                            setIvarValue(nil, NO);
                        } else {
                            NSURL *url = nil;
                            if ([instance.class conformsToProtocol:@protocol(DRModel)] &&
                                [instance.class respondsToSelector:@selector(urlConvertFromString:)]) {
                                url = [((id<DRModel>)instance.class) urlConvertFromString:str];
                            }else{
                                str = [[str dr_urlDecodedString] dr_urlQueryEncodedString];
                                url = [NSURL URLWithString:str];
                            }
                            setIvarValue(url, NO);
                        }
                    }
                }
                    break;
                    
                case DREncodingNSTypeNSArray:
                case DREncodingNSTypeNSMutableArray: {
                    if (ivar.innerCls) {
                        NSArray *valueArr = nil;
                        if ([value isKindOfClass:[NSArray class]]) valueArr = value;
                        else if ([value isKindOfClass:[NSSet class]]) valueArr = ((NSSet *)value).allObjects;
                        if (valueArr) {
                            NSMutableArray *objectArr = [NSMutableArray new];
                            for (id one in valueArr) {
                                if ([one isKindOfClass:ivar.innerCls]) {
                                    [objectArr addObject:one];
                                } else if ([one isKindOfClass:[NSDictionary class]]) {
                                    Class cls = ivar.innerCls;
                                    NSObject *newOne = [cls dr_modelWithDictionary:one];
                                    if (newOne) [objectArr addObject:newOne];
                                }
                            }
                            if (ivar.nsType == DREncodingNSTypeNSArray) {
                                setIvarValue([NSArray arrayWithArray:objectArr], NO);
                            }else{
                                setIvarValue(objectArr, YES);
                            }
                        }
                    } else {
                        if ([value isKindOfClass:[NSArray class]]) {
                            if (ivar.nsType == DREncodingNSTypeNSArray) {
                                setIvarValue(value, NO);
                            } else {
                                setIvarValue([(NSArray *)value mutableCopy], YES);
                            }
                        } else if ([value isKindOfClass:[NSSet class]]) {
                            if (ivar.nsType == DREncodingNSTypeNSArray) {
                                setIvarValue(((NSSet *)value).allObjects, NO);
                            } else {
                                setIvarValue(((NSSet *)value).allObjects.mutableCopy, YES);
                            }
                        }
                    }
                }
                    break;
                    
                case DREncodingNSTypeNSDictionary:
                case DREncodingNSTypeNSMutableDictionary: {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        if (ivar.innerCls) {
                            NSMutableDictionary *dic = [NSMutableDictionary new];
                            [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL *stop) {
                                if ([oneValue isKindOfClass:[NSDictionary class]]) {
                                    Class cls = ivar.innerCls;
                                    NSObject *newOne = [cls dr_modelWithDictionary:oneValue];
                                    if (newOne) dic[oneKey] = newOne;
                                }
                            }];
                            if (ivar.nsType == DREncodingNSTypeNSDictionary) {
                                setIvarValue([NSDictionary dictionaryWithDictionary:dic], NO);
                            }else{
                                setIvarValue(dic, YES);
                            }
                        } else {
                            if (ivar.nsType == DREncodingNSTypeNSDictionary) {
                                setIvarValue(value, NO);
                            } else {
                                setIvarValue(((NSDictionary *)value).mutableCopy, YES);
                            }
                        }
                    }
                }
                    break;
                    
                case DREncodingNSTypeNSSet:
                case DREncodingNSTypeNSMutableSet: {
                    NSSet *valueSet = nil;
                    if ([value isKindOfClass:[NSArray class]]) valueSet = [NSSet setWithArray:value];
                    else if ([value isKindOfClass:[NSSet class]]) valueSet = ((NSSet *)value);
                    
                    if (ivar.innerCls) {
                        NSMutableSet *set = [NSMutableSet new];
                        for (id one in valueSet) {
                            if ([one isKindOfClass:ivar.innerCls]) {
                                [set addObject:one];
                            } else if ([one isKindOfClass:[NSDictionary class]]) {
                                Class cls = ivar.innerCls;
                                NSObject *newOne = [cls dr_modelWithDictionary:one];
                                if (newOne) [set addObject:newOne];
                            }
                        }
                        if (ivar.nsType == DREncodingNSTypeNSSet) {
                            setIvarValue([NSSet setWithSet:set], NO);
                        }else{
                            setIvarValue(set, YES);
                        }
                    } else {
                        if (ivar.nsType == DREncodingNSTypeNSSet) {
                            setIvarValue(valueSet, NO);
                        } else {
                            setIvarValue(valueSet.mutableCopy, YES);
                        }
                    }
                }
                    break;
                default: break;
            }
        }
    }else{
        BOOL isNull = value == (id)kCFNull;
        switch (ivar.type & DREncodingTypeMask) {
            case DREncodingTypeObject: {
                // ivar为NSObject类型
                Class cls = ivar.cls;
                // 优先采用setter赋值
                id obj = nil;
                if ([value isKindOfClass:cls]) {
                    obj = value;
                }else if ([value isKindOfClass:[NSDictionary class]]){
                    // 判断ivar是否为空，不为空直接设置其属性值；为空初始化在设置属性值
                    NSObject *ivarObj = nil;
                    if (ivar.getter && [instance respondsToSelector:ivar.getter]) {
                        ivarObj = DR_GET_IVAR_VALUE(instance, ivar.getter, id);
                    }else{
                        ivarObj = [instance dr_valueForKey:ivar.ivarName];
                    }
                    if (ivarObj) {
                        [ivarObj dr_modelSetWithDictionary:value];
                        // 此处不需要重置ivar值
                        return;
                    }
                    obj = [cls dr_modelWithDictionary:value];
                }
                if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, id, obj);
                }else{
                    [instance dr_setValue:obj forKey:ivar.ivarName];
                }
            }
                break;
            case DREncodingTypeClass: {
                // 不支持KVC，所以不能用KVC赋值
                if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                    if (isNull) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, Class, nil);
                    } else {
                        Class cls = nil;
                        if ([value isKindOfClass:[NSString class]]) {
                            cls = NSClassFromString(value);
                            if (cls) {
                                DR_SET_IVAR_VALUE(instance, ivar.setter, Class, cls);
                            }
                        } else {
                            cls = object_getClass(value);
                            if (cls) {
                                if (class_isMetaClass(cls)) {
                                    DR_SET_IVAR_VALUE(instance, ivar.setter, Class, (Class)value);
                                }
                            }
                        }
                    }
                }
            }
                break;
                
            case DREncodingTypeSEL:{
                /**
                 由于SEL该类型并不支持自动装箱和拆箱，所以不能使用KVC进行赋值
                 所以我只能通过property的setter方法赋值，gettter方法获取值
                 https://stackoverflow.com/questions/18542664/assigning-to-a-property-of-type-sel-using-kvc
                 */
                if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                    if (isNull) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, SEL, nil);
                    }else if ([value isKindOfClass:[NSString class]]) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, SEL, NSSelectorFromString(value));
                    }
                }
            }
                break;
            case DREncodingTypeStruct:
            case DREncodingTypeUnion:
            case DREncodingTypeCArray: {
                if ([value isKindOfClass:[NSValue class]]) {
                    const char *valueType = ((NSValue *)value).objCType;
                    const char *ivarType = ivar.typeString.UTF8String;
                    if (valueType && ivarType && strcmp(valueType, ivarType) == 0) {
                        [instance dr_setValue:value forKey:ivar.ivarName];
                    }
                }else{
                    if (ivar.type == DREncodingTypeStruct && [value isKindOfClass:[NSString class]]) {
                        if ([ivar.typeString hasPrefix:kTypeCGRectPrefix]) {
                            CGRect rect = CGRectFromString(value);
                            if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                                DR_SET_IVAR_VALUE(instance, ivar.setter, CGRect, rect);
                            }else{
                                [instance dr_setValue:[NSValue valueWithCGRect:rect] forKey:ivar.ivarName];
                            }
                        }else if ([ivar.typeString hasPrefix:kTypeCGPointPrefix]){
                            CGPoint point = CGPointFromString(value);
                            if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                                DR_SET_IVAR_VALUE(instance, ivar.setter, CGPoint, point);
                            }else{
                                [instance dr_setValue:[NSValue valueWithCGPoint:point] forKey:ivar.ivarName];
                            }
                        }else if ([ivar.typeString hasPrefix:kTypeCGSizePrefix]){
                            CGSize size = CGSizeFromString(value);
                            if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                                DR_SET_IVAR_VALUE(instance, ivar.setter, CGSize, size);
                            }else{
                                [instance dr_setValue:[NSValue valueWithCGSize:size] forKey:ivar.ivarName];
                            }
                        }else if ([ivar.typeString hasPrefix:kTypeUIOffsetPrefix]){
                            UIOffset offset = UIOffsetFromString(value);
                            if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                                DR_SET_IVAR_VALUE(instance, ivar.setter, UIOffset, offset);
                            }else{
                                [instance dr_setValue:[NSValue valueWithUIOffset:offset] forKey:ivar.ivarName];
                            }
                        }else if ([ivar.typeString hasPrefix:kTypeUIEdgeInsetsPrefix]){
                            UIEdgeInsets insets = UIEdgeInsetsFromString(value);
                            if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                                DR_SET_IVAR_VALUE(instance, ivar.setter, UIEdgeInsets, insets);
                            }else{
                                [instance dr_setValue:[NSValue valueWithUIEdgeInsets:insets] forKey:ivar.ivarName];
                            }
                        }else if ([ivar.typeString hasPrefix:kTypeCGAffineTransformPrefix]){
                            CGAffineTransform affine = CGAffineTransformFromString(value);
                            if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                                DR_SET_IVAR_VALUE(instance, ivar.setter, CGAffineTransform, affine);
                            }else{
                                [instance dr_setValue:[NSValue valueWithCGAffineTransform:affine] forKey:ivar.ivarName];
                            }
                        }
                    }
                }
            } break;
                
            case DREncodingTypePointer:
            case DREncodingTypeCString: {
                // 这里同SEL类型一样的处理方式
                if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                    if (isNull) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, void *, (void *)NULL);
                    } else if ([value isKindOfClass:[NSValue class]]) {
                        NSValue *nsValue = value;
                        if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                            DR_SET_IVAR_VALUE(instance, ivar.setter, void *, nsValue.pointerValue);
                        }
                    }
                }
            }
            default: break;
        }
    }
}

/**
 获取实例的成员变量值
 
 @param instance Model实例
 @param ivar 实例的成员变量
 */
static inline id DRGetClassInstanceIvarValue(NSObject *instance, _DRIvarWrap *ivar){
    if (!instance || !ivar) return nil;
    if (DREncodingTypeIsCNumber(ivar.type)) {
        if (ivar.getter && [instance respondsToSelector:ivar.getter]) {
            switch (ivar.type & DREncodingTypeMask) {
                case DREncodingTypeBool: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, bool));
                }
                case DREncodingTypeInt8: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, int8_t));
                }
                case DREncodingTypeUInt8: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, uint8_t));
                }
                case DREncodingTypeInt16: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, int16_t));
                }
                case DREncodingTypeUInt16: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, uint16_t));
                }
                case DREncodingTypeInt32: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, int32_t));
                }
                case DREncodingTypeUInt32: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, uint32_t));
                }
                case DREncodingTypeInt64: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, int64_t));
                }
                case DREncodingTypeUInt64: {
                    return @(DR_GET_IVAR_VALUE(instance, ivar.getter, uint64_t));
                }
                case DREncodingTypeFloat: {
                    float num = DR_GET_IVAR_VALUE(instance, ivar.getter, float);
                    if (isnan(num) || isinf(num)) return nil;
                    return @(num);
                }
                case DREncodingTypeDouble: {
                    double num = DR_GET_IVAR_VALUE(instance, ivar.getter, double);
                    if (isnan(num) || isinf(num)) return nil;
                    return @(num);
                }
                case DREncodingTypeLongDouble: {
                    double num = DR_GET_IVAR_VALUE(instance, ivar.getter, long double);
                    if (isnan(num) || isinf(num)) return nil;
                    return @(num);
                }
                default: return [instance dr_valueForKey:ivar.ivarName];
            }
        }else{
            return [instance dr_valueForKey:ivar.ivarName];
        }
    }else if (ivar.nsType) {
        if (ivar.getter && [instance respondsToSelector:ivar.getter]) {
            return DR_GET_IVAR_VALUE(instance, ivar.getter, id);
        }else{
            return [instance dr_valueForKey:ivar.ivarName];
        }
    }else {
        if (ivar.getter && [instance respondsToSelector:ivar.getter]) {
            switch (ivar.type & DREncodingTypeMask) {
                case DREncodingTypeObject: {
                    return DR_GET_IVAR_VALUE(instance, ivar.getter, id);
                }
                case DREncodingTypeClass: {
                    Class cls = DR_GET_IVAR_VALUE(instance, ivar.getter, Class);
                    if (cls) {
                        return NSStringFromClass(cls);
                    }
                    return nil;
                }
                case DREncodingTypeSEL: {
                    SEL sel = DR_GET_IVAR_VALUE(instance, ivar.getter, SEL);
                    if (sel) {
                        return NSStringFromSelector(sel);
                    }
                    return nil;
                }
                case DREncodingTypeStruct:{
                    if ([ivar.typeString hasPrefix:kTypeCGRectPrefix]) {
                        CGRect rect = DR_GET_IVAR_VALUE(instance, ivar.getter, CGRect);
                        return NSStringFromCGRect(rect);
                    }else if ([ivar.typeString hasPrefix:kTypeCGPointPrefix]){
                        CGPoint point = DR_GET_IVAR_VALUE(instance, ivar.getter, CGPoint);
                        return NSStringFromCGPoint(point);
                    }else if ([ivar.typeString hasPrefix:kTypeCGSizePrefix]){
                        CGSize size = DR_GET_IVAR_VALUE(instance, ivar.getter, CGSize);
                        return NSStringFromCGSize(size);
                    }else if ([ivar.typeString hasPrefix:kTypeUIOffsetPrefix]){
                        UIOffset offset = DR_GET_IVAR_VALUE(instance, ivar.getter, UIOffset);
                        return NSStringFromUIOffset(offset);
                    }else if ([ivar.typeString hasPrefix:kTypeUIEdgeInsetsPrefix]){
                        UIEdgeInsets insets = DR_GET_IVAR_VALUE(instance, ivar.getter, UIEdgeInsets);
                        return NSStringFromUIEdgeInsets(insets);
                    }else if ([ivar.typeString hasPrefix:kTypeCGAffineTransformPrefix]){
                        CGAffineTransform affine = DR_GET_IVAR_VALUE(instance, ivar.getter, CGAffineTransform);
                        return NSStringFromCGAffineTransform(affine);
                    }
                }
                default: break;
            }
        }else{
            switch (ivar.type & DREncodingTypeMask) {
                case DREncodingTypeObject: {
                    return [instance dr_valueForKey:ivar.ivarName];
                }
                case DREncodingTypeClass: {
                    Class cls = [instance dr_valueForKey:ivar.ivarName];
                    if (cls) {
                        return NSStringFromClass(cls);
                    }
                    return nil;
                }
                case DREncodingTypeStruct:{
                    if ([ivar.typeString hasPrefix:kTypeCGRectPrefix]) {
                        NSValue *val = [instance dr_valueForKey:ivar.ivarName];
                        if (val) {
                            return NSStringFromCGRect(val.CGRectValue);
                        }
                        return nil;
                    }else if ([ivar.typeString hasPrefix:kTypeCGPointPrefix]){
                        NSValue *val = [instance dr_valueForKey:ivar.ivarName];
                        if (val) {
                            return NSStringFromCGPoint(val.CGPointValue);
                        }
                        return nil;
                    }else if ([ivar.typeString hasPrefix:kTypeCGSizePrefix]){
                        NSValue *val = [instance dr_valueForKey:ivar.ivarName];
                        if (val) {
                            return NSStringFromCGSize(val.CGSizeValue);
                        }
                        return nil;
                    }else if ([ivar.typeString hasPrefix:kTypeUIOffsetPrefix]){
                        NSValue *val = [instance dr_valueForKey:ivar.ivarName];
                        if (val) {
                            return NSStringFromUIOffset(val.UIOffsetValue);
                        }
                        return nil;
                    }else if ([ivar.typeString hasPrefix:kTypeUIEdgeInsetsPrefix]){
                        NSValue *val = [instance dr_valueForKey:ivar.ivarName];
                        if (val) {
                            return NSStringFromUIEdgeInsets(val.UIEdgeInsetsValue);
                        }
                        return nil;
                    }else if ([ivar.typeString hasPrefix:kTypeCGAffineTransformPrefix]){
                        NSValue *val = [instance dr_valueForKey:ivar.ivarName];
                        if (val) {
                            return NSStringFromCGAffineTransform(val.CGAffineTransformValue);
                        }
                        return nil;
                    }
                }
                default: break;
            }
        }
    }
    return nil;
}

/**
 将model转json object（model的成员变量为空，将不被包含在json object中）
 */
static inline id DRModelToJSONObjectRecursive(NSObject *model) {
    if (!model || model == (id)kCFNull) return nil;
    if ([model isKindOfClass:[NSString class]]) return model;
    if ([model isKindOfClass:[NSNumber class]]) return model;
    if ([model isKindOfClass:[NSDictionary class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            NSString *stringKey = [key isKindOfClass:[NSString class]] ? key : key.description;
            if (!stringKey) return;
            id jsonObj = DRModelToJSONObjectRecursive(obj);
            if (!jsonObj) return;
            newDic[stringKey] = jsonObj;
        }];
        return [NSDictionary dictionaryWithDictionary:newDic];
    }
    if ([model isKindOfClass:[NSSet class]]) {
        NSArray *array = ((NSSet *)model).allObjects;
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in array) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = DRModelToJSONObjectRecursive(obj);
                if (jsonObj) [newArray addObject:jsonObj];
            }
        }
        return [NSArray arrayWithArray:newArray];
    }
    if ([model isKindOfClass:[NSArray class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableArray *newArray = [NSMutableArray new];
        for (id obj in (NSArray *)model) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = DRModelToJSONObjectRecursive(obj);
                if (jsonObj) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    if ([model isKindOfClass:[NSURL class]]) return ((NSURL *)model).absoluteString;
    if ([model isKindOfClass:[NSAttributedString class]]) return ((NSAttributedString *)model).string;
    if ([model isKindOfClass:[NSDate class]]) return [(NSDate *)model dr_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    if ([model isKindOfClass:[NSData class]]) return [(NSData *)model dr_hexString];
    
    _DRModelWrap *mw = [_DRModelWrap modelClass:model.class];
    if (!mw || mw.ivars.count == 0) return nil;
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:mw.ivars.count];
    __unsafe_unretained NSMutableDictionary *dic = result;
    [mw.ivars enumerateObjectsUsingBlock:^(_DRIvarWrap * _Nonnull ivar, BOOL * _Nonnull stop) {
        id value = DRGetClassInstanceIvarValue(model, ivar);
        if (ivar.nsType) {
            value = DRModelToJSONObjectRecursive(value);
        } else if ((ivar.type & DREncodingTypeMask) == DREncodingTypeObject){
            value = DRModelToJSONObjectRecursive(value);
        }
        if (!value) return;
        if (ivar.toJsonKey) {
            dic[ivar.toJsonKey] = value;
        }else{
            dic[ivar.ivarName] = value;
        }
    }];
    return [result copy];
}


@implementation NSObject (DRModel)

+ (instancetype)dr_modelWithJSON:(id)json{
    NSDictionary *dic = nil;
    if ([json isKindOfClass:[NSString class]]) {
        dic = [(NSString *)json dr_jsonObj];
    }else if ([json isKindOfClass:[NSData class]]){
        dic = [(NSData *)json dr_jsonObj];
    }else if ([json isKindOfClass:[NSDictionary class]]){
        dic = json;
    }
    return [self dr_modelWithDictionary:dic];
}

+ (instancetype)dr_modelWithDictionary:(NSDictionary *)dic{
    if (!dic || dic == (id)kCFNull) return nil;
    if (![dic isKindOfClass:[NSDictionary class]]) return nil;
    Class cls = [self class];
    _DRModelWrap *mw = [_DRModelWrap modelClass:cls];
    if (!mw) return nil;
    
    NSObject *instance = nil;
    if ([cls conformsToProtocol:@protocol(DRModel)] &&
        [cls respondsToSelector:@selector(newModel)]) {
        instance = [(id<DRModel>)cls newModel];
    }else{
        instance = [cls new];
    }
    [instance dr_modelSetWithDictionary:dic];
    return instance;
}

- (BOOL)dr_modelSetWithJSON:(id)json{
    NSDictionary *dic = nil;
    if ([json isKindOfClass:[NSString class]]) {
        dic = [(NSString *)json dr_jsonObj];
    }else if ([json isKindOfClass:[NSData class]]){
        dic = [(NSData *)json dr_jsonObj];
    }else if ([json isKindOfClass:[NSDictionary class]]){
        dic = json;
    }
    return [self dr_modelSetWithDictionary:dic];
}

- (BOOL)dr_modelSetWithDictionary:(NSDictionary *)dic{
    if (!dic || dic == (id)kCFNull) return NO;
    if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    Class cls = object_getClass(self);
    _DRModelWrap *mw = [_DRModelWrap modelClass:cls];
    if (!mw) return NO;
    
    for (_DRIvarWrap *ivar in mw.ivars) {
        DRSetClassInstanceIvarValue(self, ivar, dic);
    }
    return YES;
}

- (id)dr_modelToJSONObject{
    id jsonObject = DRModelToJSONObjectRecursive(self);
    if ([jsonObject isKindOfClass:[NSArray class]]) return jsonObject;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) return jsonObject;
    return nil;
}

- (NSData *)dr_modelToJSONData{
    id jsonObject = [self dr_modelToJSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (NSString *)dr_modelToJSONString{
    return [[self dr_modelToJSONData] dr_utf8String];
}

- (instancetype)dr_copy{
    if (self == (id)kCFNull) return self;
    if ([self conformsToProtocol:@protocol(NSCopying)]) {
        return [self copy];
    }
    Class cls = self.class;
    _DRModelWrap *wm = [_DRModelWrap modelClass:cls];
    if (!wm) return nil;
    NSObject *instance = nil;
    if ([cls conformsToProtocol:@protocol(DRModel)] &&
        [cls respondsToSelector:@selector(newModel)]) {
        instance = [(id<DRModel>)cls newModel];
    }else{
        instance = [cls new];
    }
    [wm.ivars enumerateObjectsUsingBlock:^(_DRIvarWrap * _Nonnull ivar, BOOL * _Nonnull stop) {
        
        id value = DRGetClassInstanceIvarValue(self, ivar);
        if (DREncodingTypeIsCNumber(ivar.type)) {
            if (![value isKindOfClass:[NSNumber class]]) return;
            NSNumber *num = value;
            
            if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                switch (ivar.type & DREncodingTypeMask) {
                    case DREncodingTypeBool: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, bool, num.boolValue);
                    } break;
                    case DREncodingTypeInt8: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, int8_t, (int8_t)num.charValue);
                    } break;
                    case DREncodingTypeUInt8: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, uint8_t, (uint8_t)num.unsignedCharValue);
                    } break;
                    case DREncodingTypeInt16: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, int16_t, (int16_t)num.shortValue);
                    } break;
                    case DREncodingTypeUInt16: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, uint16_t, (uint16_t)num.unsignedShortValue);
                    } break;
                    case DREncodingTypeInt32: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, int32_t, (int32_t)num.intValue);
                    }
                    case DREncodingTypeUInt32: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, uint32_t, (uint32_t)num.unsignedIntValue);
                    } break;
                    case DREncodingTypeInt64: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, uint64_t, (uint64_t)num.longLongValue);
                    } break;
                    case DREncodingTypeUInt64: {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, uint64_t, (uint64_t)num.unsignedLongLongValue);
                    } break;
                    case DREncodingTypeFloat: {
                        float f = num.floatValue;
                        if (isnan(f) || isinf(f)) f = 0;
                        DR_SET_IVAR_VALUE(instance, ivar.setter, float, f);
                    } break;
                    case DREncodingTypeDouble: {
                        double d = num.doubleValue;
                        if (isnan(d) || isinf(d)) d = 0;
                        DR_SET_IVAR_VALUE(instance, ivar.setter, double, d);
                    } break;
                    case DREncodingTypeLongDouble: {
                        long double d = num.doubleValue;
                        if (isnan(d) || isinf(d)) d = 0;
                        DR_SET_IVAR_VALUE(instance, ivar.setter, long double, (long double)d);
                    } break;
                    default:{
                        [instance dr_setValue:num forKey:ivar.ivarName];
                    }
                        break;
                }
            }else{
                [instance dr_setValue:num forKey:ivar.ivarName];
            }
        }else if (ivar.nsType){
            // 成员赋值，isMutable：YES(val是可变值类型)
            void (^setIvarValue)(id, BOOL) = ^(id val, BOOL isMutable){
                if (isMutable && ivar.propertyType != DREncodingTypeUnknown &&
                    (ivar.propertyType & DREncodingTypePropertyMask) == DREncodingTypePropertyCopy) {
                    // 由于copy修饰的属性，会将可变值转成不可变，所以这里采用直接对成员赋值
                    object_setIvar(instance, ivar.ivar, val);
                    return;
                }
                if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                    DR_SET_IVAR_VALUE(instance, ivar.setter, id, val);
                }else{
                    [instance dr_setValue:val forKey:ivar.ivarName];
                }
            };
            
            if (value == (id)kCFNull) {
                setIvarValue(nil, NO);
            }else{
                switch (ivar.nsType) {
                    case DREncodingNSTypeNSMutableData:
                    case DREncodingNSTypeNSMutableArray:
                    case DREncodingNSTypeNSMutableDictionary:
                    case DREncodingNSTypeNSMutableSet:
                    case DREncodingNSTypeNSMutableString: {
                        setIvarValue(value, YES);
                    }
                        break;
                    default: {
                        setIvarValue(value, NO);
                    }
                        break;
                }
            }
        }else{
            switch ((ivar.type & DREncodingTypeMask)) {
                case DREncodingTypeObject:{
                    if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, id, value);
                    }else{
                        [instance dr_setValue:value forKey:ivar.ivarName];
                    }
                }
                    break;
                case DREncodingTypeSEL:{
                    if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, SEL, NSSelectorFromString(value));
                    }
                }
                    break;
                case DREncodingTypeClass:{
                    if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, Class, NSClassFromString(value));
                    }else{
                        [instance dr_setValue:NSClassFromString(value) forKey:ivar.ivarName];
                    }
                }
                    break;
                case DREncodingTypeStruct:{
                    if ([ivar.typeString hasPrefix:kTypeCGRectPrefix]) {
                        CGRect rect = CGRectFromString(value);
                        if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                            DR_SET_IVAR_VALUE(instance, ivar.setter, CGRect, rect);
                        }else{
                            NSValue *val = [NSValue valueWithCGRect:rect];
                            [instance dr_setValue:val forKey:ivar.ivarName];
                        }
                    }else if ([ivar.typeString hasPrefix:kTypeCGPointPrefix]){
                        CGPoint point = CGPointFromString(value);
                        if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                            DR_SET_IVAR_VALUE(instance, ivar.setter, CGPoint, point);
                        }else{
                            NSValue *val = [NSValue valueWithCGPoint:point];
                            [instance dr_setValue:val forKey:ivar.ivarName];
                        }
                    }else if ([ivar.typeString hasPrefix:kTypeCGSizePrefix]){
                        CGSize size = CGSizeFromString(value);
                        if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                            DR_SET_IVAR_VALUE(instance, ivar.setter, CGSize, size);
                        }else{
                            NSValue *val = [NSValue valueWithCGSize:size];
                            [instance dr_setValue:val forKey:ivar.ivarName];
                        }
                    }else if ([ivar.typeString hasPrefix:kTypeUIOffsetPrefix]){
                        UIOffset offset = UIOffsetFromString(value);
                        if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                            DR_SET_IVAR_VALUE(instance, ivar.setter, UIOffset, offset);
                        }else{
                            NSValue *val = [NSValue valueWithUIOffset:offset];
                            [instance dr_setValue:val forKey:ivar.ivarName];
                        }
                    }else if ([ivar.typeString hasPrefix:kTypeUIEdgeInsetsPrefix]){
                        UIEdgeInsets insets = UIEdgeInsetsFromString(value);
                        if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                            DR_SET_IVAR_VALUE(instance, ivar.setter, UIEdgeInsets, insets);
                        }else{
                            NSValue *val = [NSValue valueWithUIEdgeInsets:insets];
                            [instance dr_setValue:val forKey:ivar.ivarName];
                        }
                    }else if ([ivar.typeString hasPrefix:kTypeCGAffineTransformPrefix]){
                        CGAffineTransform affine = CGAffineTransformFromString(value);
                        if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                            DR_SET_IVAR_VALUE(instance, ivar.setter, CGAffineTransform, affine);
                        }else{
                            NSValue *val = [NSValue valueWithCGAffineTransform:affine];
                            [instance dr_setValue:val forKey:ivar.ivarName];
                        }
                    }
                }
                    break;
                case DREncodingTypeBlock:{
                    // 此处不能用value的值
                    id block = nil;
                    if (ivar.getter && [self respondsToSelector:ivar.getter]) {
                        block = DR_GET_IVAR_VALUE(self, ivar.getter, id);
                    }else{
                        block = [self dr_valueForKey:ivar.ivarName];
                    }
                    if (ivar.setter && [instance respondsToSelector:ivar.setter]) {
                        DR_SET_IVAR_VALUE(instance, ivar.setter, id, block);
                    }else{
                        [instance dr_setValue:block forKey:ivar.ivarName];
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }];
    return instance;
}

- (void)dr_modelEncodeWithCoder:(NSCoder *)aCoder{
    if (!aCoder) return;
    if (self == (id)kCFNull) {
        [((id<NSCoding>)self)encodeWithCoder:aCoder];
        return;
    }
}

- (instancetype)dr_modelInitWithCoder:(NSCoder *)aDecoder{
    return self;
}

- (void)dr_setValue:(id)value forKey:(NSString *)key{
    if (![key isKindOfClass:[NSString class]]) return;
    if (key.dr_trim.length==0) return;
    @try {
        [self setValue:value forKey:key];
    } @catch (NSException *exception) {}
}

- (void)dr_setValue:(id)value forKeyPath:(NSString *)keyPath{
    if (![keyPath isKindOfClass:[NSString class]]) return;
    if (keyPath.dr_trim.length==0) return;
    @try {
        [self setValue:value forKeyPath:keyPath];
    } @catch (NSException *exception) {}
}

- (id)dr_valueForKey:(NSString *)key{
    if (![key isKindOfClass:[NSString class]]) return nil;
    if (key.dr_trim.length==0) return nil;
    id value = nil;
    @try {
        value = [self valueForKey:key];
    } @catch (NSException *exception) {}
    return value;
}

- (id)dr_valueForKeyPath:(NSString *)keyPath{
    if (![keyPath isKindOfClass:[NSString class]]) return nil;
    if (keyPath.dr_trim.length==0) return nil;
    id value = nil;
    @try {
        value = [self valueForKeyPath:keyPath];
    } @catch (NSException *exception) {}
    return value;
}

@end
