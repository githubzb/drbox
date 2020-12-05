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
/// 映射的字典key：[name, userName, myName...]
@property (nonatomic, readonly, strong) NSArray<NSString *> *jsonKeys;
/// 映射的字典keyPath：[user.name, user.userName, user.myName...]
@property (nonatomic, readonly, strong) NSArray<NSString *> *jsonKeyPaths;
/// 转json时对应的key
@property (nonatomic, readonly, strong) NSString *toJsonKey;
/// 自身的class
@property (nonatomic, readonly, assign, nullable) Class cls;
/// 如果cls为数组或字典，innerCls：表示这个数组或字典值对应的元素类型
@property (nonatomic, readonly, assign, nullable) Class innerCls;
@property (nonatomic, readonly, assign) DREncodingType type;

- (nullable instancetype)initWithIvarInfo:(DRClassIvarInfo *)info ofModel:(id<DRModel>)model;

@end

@implementation _DRIvarWrap

- (instancetype)initWithIvarInfo:(DRClassIvarInfo *)info ofModel:(id<DRModel>)model{
    if (!info || info.name.length==0) return nil;
    self = [super init];
    if (self) {
        _ivarName = [info.name copy];
        _cls = info.cls;
        if ([model respondsToSelector:@selector(toModelContainerInnerClassMapper)]) {
            NSDictionary *dic = [model toModelContainerInnerClassMapper];
            if (dic.count) {
                id val = dic[_ivarName];
                Class cls = nil;
                if ([val isKindOfClass:[NSString class]]) {
                    cls = NSClassFromString(val);
                }else {
                    cls = object_getClass(val);
                    if (class_isMetaClass(cls)) {
                        
                    }
                }
//                Class cls = object_getClass(dic[_ivarName]);
                
            }
        }
    }
    return self;
}

@end


static inline void DRModelSetValue(id model, _DRIvarWrap *ivar, id value){
    if (!model || !ivar) return;
    if ([ivar.cls isKindOfClass: [NSString class]]) {
        
    }
}


@implementation NSObject (DRModel)

+ (instancetype)modelWithDictionary:(NSDictionary *)dic{
    if (!dic || dic == (id)kCFNull) return nil;
    if (![dic isKindOfClass:[NSDictionary class]]) return nil;
    Class cls = [self class];
    DRClassInfo *info = [DRClassInfo infoWithClass:cls];
    if (!info) return nil;
    NSObject *instance = [cls new];
    NSArray *ivars = [info.ivarInfos allKeys];
    for (NSString *ivarName in ivars) {
        NSString *key = [ivarName hasPrefix:@"_"] ? [ivarName substringFromIndex:1] : ivarName;
        id val = [self transformValue:dic[key]];
        [instance setValue:val forKey:ivarName];
    }
    return instance;
}

+ (id)transformValue:(id)value{
    if (!value || value == (id)kCFNull) return nil;
    return value;
}

@end
