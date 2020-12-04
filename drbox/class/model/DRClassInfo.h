//
//  DRClassInfo.h
//  drbox
//
//  Created by dr.box on 2020/7/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, DREncodingType) {
    DREncodingTypeMask       = 0xFF, ///< mask of type value
    DREncodingTypeUnknown    = 0, ///< unknown
    DREncodingTypeVoid       = 1, ///< void
    DREncodingTypeBool       = 2, ///< bool
    DREncodingTypeInt8       = 3, ///< char / BOOL
    DREncodingTypeUInt8      = 4, ///< unsigned char
    DREncodingTypeInt16      = 5, ///< short
    DREncodingTypeUInt16     = 6, ///< unsigned short
    DREncodingTypeInt32      = 7, ///< int
    DREncodingTypeUInt32     = 8, ///< unsigned int
    DREncodingTypeInt64      = 9, ///< long long
    DREncodingTypeUInt64     = 10, ///< unsigned long long
    DREncodingTypeFloat      = 11, ///< float
    DREncodingTypeDouble     = 12, ///< double
    DREncodingTypeLongDouble = 13, ///< long double
    DREncodingTypeObject     = 14, ///< id
    DREncodingTypeClass      = 15, ///< Class
    DREncodingTypeSEL        = 16, ///< SEL
    DREncodingTypeBlock      = 17, ///< block
    DREncodingTypePointer    = 18, ///< void*
    DREncodingTypeStruct     = 19, ///< struct
    DREncodingTypeUnion      = 20, ///< union
    DREncodingTypeCString    = 21, ///< char*
    DREncodingTypeCArray     = 22, ///< char[10] (for example)
    
    DREncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    DREncodingTypeQualifierConst  = 1 << 8,  ///< const
    DREncodingTypeQualifierIn     = 1 << 9,  ///< in
    DREncodingTypeQualifierInout  = 1 << 10, ///< inout
    DREncodingTypeQualifierOut    = 1 << 11, ///< out
    DREncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    DREncodingTypeQualifierByref  = 1 << 13, ///< byref
    DREncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    DREncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    DREncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    DREncodingTypePropertyCopy         = 1 << 17, ///< copy
    DREncodingTypePropertyRetain       = 1 << 18, ///< retain
    DREncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    DREncodingTypePropertyWeak         = 1 << 20, ///< weak
    DREncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    DREncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    DREncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

FOUNDATION_EXPORT DREncodingType DREncodingGetType(const char *typeEncoding);

@interface DRClassIvarInfo : NSObject

@property (nonatomic, readonly, assign) Ivar ivar;
/// ivar（成员变量名）
@property (nonatomic, readonly, strong) NSString *name;
/// ivar.offset
@property (nonatomic, readonly, assign) ptrdiff_t offset;
/// ivar.typeEncoding
@property (nonatomic, readonly, strong) NSString *typeEncoding;
/// 成员变量类型
@property (nonatomic, readonly, assign) DREncodingType type;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithIvar:(Ivar)ivar NS_DESIGNATED_INITIALIZER;

@end

@interface DRClassMethodInfo : NSObject

@property (nonatomic, readonly, assign) Method method;
/// 方法名
@property (nonatomic, readonly, strong) NSString *name;
/// 方法的SEL
@property (nonatomic, readonly, assign) SEL sel;
/// 方法实现
@property (nonatomic, readonly, assign) IMP imp;
/// 方法签名类型
@property (nonatomic, readonly, strong) NSString *typeEncoding;
/// 返回值类型
@property (nonatomic, readonly, strong) NSString *returnTypeEncoding;
/// 参数类型
@property (nonatomic, readonly, strong, nullable) NSArray<NSString *> *argumentTypeEncodings;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithMethod:(Method)method NS_DESIGNATED_INITIALIZER;

@end

@interface DRClassPropertyInfo : NSObject

@property (nonatomic, readonly, assign) objc_property_t property;
/// 属性名
@property (nonatomic, readonly, strong) NSString *name;
/// 属性类型
@property (nonatomic, readonly, assign) DREncodingType type;
/// 属性类型字符串
@property (nonatomic, readonly, strong) NSString *typeEncoding;
/// 属性对应的成员变量名（当前属性作为只读方法时，没有成员变量，此处为nil）
@property (nonatomic, readonly, strong, nullable) NSString *ivarName;
/// 属性如果是NSObject类型，cls为该类的class
@property (nonatomic, readonly, assign, nullable) Class cls;
/// 属性如果是id<protocol>
@property (nonatomic, strong, readonly, nullable) NSArray<NSString *> *protocols;
/// 当前属性的getter方法
@property (nonatomic, readonly, assign) SEL getter;
/// 当前属性的setter方法（当前属性为只读，setter==nil）
@property (nonatomic, readonly, assign, nullable) SEL setter;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithProperty:(objc_property_t)property NS_DESIGNATED_INITIALIZER;

@end

@interface DRProtocolMethodInfo : NSObject

@property (nonatomic, readonly, assign) struct objc_method_description methodDesc;
/// 协议方法名
@property (nonatomic, readonly, strong) NSString *name;
/// 协议方法类型
@property (nonatomic, readonly, strong) NSString *typeEncoding;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithMethodDescription:(struct objc_method_description)desc NS_DESIGNATED_INITIALIZER;

@end

@interface DRClassProtocolInfo : NSObject

@property (nonatomic, readonly, unsafe_unretained) Protocol *protocol;
/// 协议名称
@property (nonatomic, readonly, strong) NSString *name;
/// 可选协议实例方法信息，key：方法名
@property (nonatomic, readonly, strong, nullable) NSDictionary<NSString *, DRProtocolMethodInfo *> *optionInstanceMethodInfos;
/// 可选协议类方法信息，key：方法名
@property (nonatomic, readonly, strong, nullable) NSDictionary<NSString *, DRProtocolMethodInfo *> *optionClassMethodInfos;
/// 必选协议实例方法信息，key：方法名
@property (nonatomic, readonly, strong, nullable) NSDictionary<NSString *, DRProtocolMethodInfo *> *requiredInstanceMethodInfos;
/// 必选协议类方法信息，key：方法名
@property (nonatomic, readonly, strong, nullable) NSDictionary<NSString *, DRProtocolMethodInfo *> *requiredClassMethodInfos;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithProtocol:(Protocol *)protocol;

@end


@interface DRClassInfo : NSObject

/// class的名称
@property (nonatomic, readonly, strong) NSString *name;
/// 当前类的Class
@property (nonatomic, readonly, assign) Class cls;
/// 父类的Class
@property (nonatomic, readonly, assign, nullable) Class superCls;
/// 当前类的metaClass
@property (nonatomic, readonly, assign, nullable) Class metaCls;
/// 当前是否为metaClass
@property (nonatomic, readonly, assign) BOOL isMetaCls;
/// 父类的class info
@property (nonatomic, readonly, strong, nullable) DRClassInfo *superClsInfo;
/// 当前类的ivar（成员变量）信息，key：ivar的名字
@property (nonatomic, readonly, strong, nullable) NSDictionary<NSString *, DRClassIvarInfo *> *ivarInfos;
/// 当前类的method（方法）信息，key：method的名字
@property (nonatomic, readonly, strong, nullable) NSDictionary<NSString *, DRClassMethodInfo *> *methodInfos;
/// 当前类的property（属性）信息，key：property的名字
@property (nonatomic, readonly, strong, nullable) NSDictionary<NSString *, DRClassPropertyInfo *> *propertyInfos;
/// 当前类实现的protocol协议信息
@property (nonatomic, readonly, strong, nullable) NSDictionary<NSString *, DRClassProtocolInfo *> *protocolInfos;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
/**
 实例化方法（该方法不会对当前的classInfo缓存）
 */
- (nullable instancetype)initWithClass:(Class)cls NS_DESIGNATED_INITIALIZER;

/**
 获取cls的classInfo对象描述，该方法存在缓存，会将每次cls的classInfo缓存下来，来提高效率
 */
+ (nullable instancetype)infoWithClass:(Class)cls;
+ (nullable instancetype)infoWithClassName:(NSString *)clsName;

/// 更新当前类和父类的ivar、method、property列表
- (void)update;

@end

NS_ASSUME_NONNULL_END
