//
//  DRClassInfo.h
//  drbox
//
//  Created by dr.box on 2020/7/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRClassInfo.h"

DREncodingType DREncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return DREncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return DREncodingTypeUnknown;
    
    DREncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= DREncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= DREncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= DREncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= DREncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= DREncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= DREncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= DREncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    len = strlen(type);
    if (len == 0) return DREncodingTypeUnknown | qualifier;

    switch (*type) {
        case 'v': return DREncodingTypeVoid | qualifier;
        case 'B': return DREncodingTypeBool | qualifier;
        case 'c': return DREncodingTypeInt8 | qualifier;
        case 'C': return DREncodingTypeUInt8 | qualifier;
        case 's': return DREncodingTypeInt16 | qualifier;
        case 'S': return DREncodingTypeUInt16 | qualifier;
        case 'i': return DREncodingTypeInt32 | qualifier;
        case 'I': return DREncodingTypeUInt32 | qualifier;
        case 'l': return DREncodingTypeInt32 | qualifier;
        case 'L': return DREncodingTypeUInt32 | qualifier;
        case 'q': return DREncodingTypeInt64 | qualifier;
        case 'Q': return DREncodingTypeUInt64 | qualifier;
        case 'f': return DREncodingTypeFloat | qualifier;
        case 'd': return DREncodingTypeDouble | qualifier;
        case 'D': return DREncodingTypeLongDouble | qualifier;
        case '#': return DREncodingTypeClass | qualifier;
        case ':': return DREncodingTypeSEL | qualifier;
        case '*': return DREncodingTypeCString | qualifier;
        case '^': return DREncodingTypePointer | qualifier;
        case '[': return DREncodingTypeCArray | qualifier;
        case '(': return DREncodingTypeUnion | qualifier;
        case '{': return DREncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return DREncodingTypeBlock | qualifier;
            else
                return DREncodingTypeObject | qualifier;
        }
        default: return DREncodingTypeUnknown | qualifier;
    }
}

@implementation DRClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar{
    if (!ivar) return nil;
    self = [super init];
    if (self) {
        _ivar = ivar;
        const char *name = ivar_getName(ivar);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        _offset = ivar_getOffset(ivar);
        const char *typeEncoding = ivar_getTypeEncoding(ivar);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
            _type = DREncodingGetType(typeEncoding);
        }
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"{name: %@, type: %@}", _name, _typeEncoding];
}

@end


@implementation DRClassMethodInfo

- (instancetype)initWithMethod:(Method)method{
    if (!method) return nil;
    self = [super init];
    if (self) {
        _method = method;
        _sel = method_getName(method);
        _imp = method_getImplementation(method);
        const char *name = sel_getName(_sel);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        const char *typeEncoding = method_getTypeEncoding(method);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        }
        char *returnType = method_copyReturnType(method);
        if (returnType) {
            _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
            free(returnType);
        }
        unsigned int argumentCount = method_getNumberOfArguments(method);
        if (argumentCount > 0) {
            NSMutableArray *argumentTypes = [NSMutableArray new];
            for (unsigned int i = 0; i < argumentCount; i++) {
                char *argumentType = method_copyArgumentType(method, i);
                NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
                [argumentTypes addObject:type ? type : @""];
                if (argumentType) free(argumentType);
            }
            _argumentTypeEncodings = [NSArray arrayWithArray:argumentTypes];
        }
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"{name: %@, type: %@, returnType: %@, argsType: %@}",
            _name,
            _typeEncoding,
            _returnTypeEncoding,
            [_argumentTypeEncodings componentsJoinedByString:@""]];
}

@end


@implementation DRClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property{
    if (!property) return nil;
    self = [super init];
    if (self) {
        _property = property;
        const char *name = property_getName(property);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        
        DREncodingType type = 0;
        unsigned int attrCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attrs[i].name[0]) {
                case 'T': { // Type encoding
                    if (attrs[i].value) {
                        _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                        type = DREncodingGetType(attrs[i].value);
                        
                        if ((type & DREncodingTypeMask) == DREncodingTypeObject && _typeEncoding.length) {
                            NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                            if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                            
                            NSString *clsName = nil;
                            if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                                if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                            }
                            
                            NSMutableArray *protocols = nil;
                            while ([scanner scanString:@"<" intoString:NULL]) {
                                NSString* protocol = nil;
                                if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                    if (protocol.length) {
                                        if (!protocols) protocols = [NSMutableArray new];
                                        [protocols addObject:protocol];
                                    }
                                }
                                [scanner scanString:@">" intoString:NULL];
                            }
                            if (protocols) {
                                _protocols = [NSArray arrayWithArray:protocols];
                            }
                        }
                    }
                } break;
                case 'V': { // 成员变量
                    if (attrs[i].value) {
                        _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                    }
                } break;
                case 'R': {
                    type |= DREncodingTypePropertyReadonly;
                } break;
                case 'C': {
                    type |= DREncodingTypePropertyCopy;
                } break;
                case '&': {
                    type |= DREncodingTypePropertyRetain;
                } break;
                case 'N': {
                    type |= DREncodingTypePropertyNonatomic;
                } break;
                case 'D': {
                    type |= DREncodingTypePropertyDynamic;
                } break;
                case 'W': {
                    type |= DREncodingTypePropertyWeak;
                } break;
                case 'G': {
                    type |= DREncodingTypePropertyCustomGetter;
                    if (attrs[i].value) {
                        _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                } break;
                case 'S': {
                    type |= DREncodingTypePropertyCustomSetter;
                    if (attrs[i].value) {
                        _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                } // break; commented for code coverage in next line
                default: break;
            }
        }
        if (attrs) {
            free(attrs);
            attrs = NULL;
        }
        
        _type = type;
        if (_name.length) {
            if (!_getter) {
                _getter = NSSelectorFromString(_name);
            }
            if (!_setter && !((type & DREncodingTypePropertyMask) & DREncodingTypePropertyReadonly)) {
                _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
            }
        }
    }
    return self;
}

- (NSString *)description{
    if (_cls) {
        return [NSString stringWithFormat:@"{name: %@, type: %@, ivar: %@, class: %@, protocols: <%@>, getter: %@, setter: %@}",
                _name,
                _typeEncoding,
                _ivarName,
                NSStringFromClass(_cls),
                [_protocols componentsJoinedByString:@","],
                NSStringFromSelector(_getter),
                NSStringFromSelector(_setter)];
    }
    return [NSString stringWithFormat:@"{name: %@, type: %@, ivar: %@, protocols: <%@>, getter: %@, setter: %@}",
            _name,
            _typeEncoding,
            _ivarName,
            [_protocols componentsJoinedByString:@","],
            NSStringFromSelector(_getter),
            NSStringFromSelector(_setter)];
}

@end

@implementation DRProtocolMethodInfo

- (instancetype)initWithMethodDescription:(struct objc_method_description)desc{
    self = [super init];
    if (self) {
        _methodDesc = desc;
        if (desc.name) {
            _name = NSStringFromSelector(desc.name);
        }
        if (desc.types) {
            _typeEncoding = [NSString stringWithUTF8String:desc.types];
        }
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"{name: %@, type: %@}", _name, _typeEncoding];
}

@end

@implementation DRClassProtocolInfo

- (instancetype)initWithProtocol:(Protocol *)protocol{
    if (!protocol) return nil;
    self = [super init];
    if (self) {
        _protocol = protocol;
        const char * name = protocol_getName(protocol);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
            unsigned int count = 0;
            // 必选 实例方法
            struct objc_method_description *requiredInstanceMethods = protocol_copyMethodDescriptionList(protocol, YES, YES, &count);
            if (requiredInstanceMethods) {
                NSMutableDictionary *requiredInstanceMethodInfos = [NSMutableDictionary new];
                for (unsigned int i = 0; i < count; i++) {
                    struct objc_method_description method = requiredInstanceMethods[i];
                    DRProtocolMethodInfo *info = [[DRProtocolMethodInfo alloc] initWithMethodDescription:method];
                    if (info.name) requiredInstanceMethodInfos[info.name] = info;
                }
                free(requiredInstanceMethods);
                _requiredInstanceMethodInfos = [NSDictionary dictionaryWithDictionary:requiredInstanceMethodInfos];
            }
            
            // 必选 类方法
            struct objc_method_description *requiredClassMethods = protocol_copyMethodDescriptionList(protocol, YES, NO, &count);
            if (requiredClassMethods) {
                NSMutableDictionary *requiredClassMethodInfos = [NSMutableDictionary new];
                for (unsigned int i = 0; i < count; i++) {
                    struct objc_method_description method = requiredClassMethods[i];
                    DRProtocolMethodInfo *info = [[DRProtocolMethodInfo alloc] initWithMethodDescription:method];
                    if (info.name) requiredClassMethodInfos[info.name] = info;
                }
                free(requiredClassMethods);
                _requiredClassMethodInfos = [NSDictionary dictionaryWithDictionary:requiredClassMethodInfos];
            }
            
            // 可选 实例方法
            struct objc_method_description *optionInstanceMethods = protocol_copyMethodDescriptionList(protocol, NO, YES, &count);
            if (optionInstanceMethods) {
                NSMutableDictionary *optionInstanceMethodInfos = [NSMutableDictionary new];
                for (unsigned int i = 0; i < count; i++) {
                    struct objc_method_description method = optionInstanceMethods[i];
                    DRProtocolMethodInfo *info = [[DRProtocolMethodInfo alloc] initWithMethodDescription:method];
                    if (info.name) optionInstanceMethodInfos[info.name] = info;
                }
                free(optionInstanceMethods);
                _optionInstanceMethodInfos = [NSDictionary dictionaryWithDictionary:optionInstanceMethodInfos];
            }
            
            // 可选 类方法
            struct objc_method_description *optionClassMethods = protocol_copyMethodDescriptionList(protocol, NO, NO, &count);
            if (optionClassMethods) {
                NSMutableDictionary *optionClassMethodInfos = [NSMutableDictionary new];
                for (unsigned int i = 0; i < count; i++) {
                    struct objc_method_description method = optionClassMethods[i];
                    DRProtocolMethodInfo *info = [[DRProtocolMethodInfo alloc] initWithMethodDescription:method];
                    if (info.name) optionClassMethodInfos[info.name] = info;
                }
                free(optionClassMethods);
                _optionClassMethodInfos = [NSDictionary dictionaryWithDictionary:optionClassMethodInfos];
            }
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{name: %@, requiredInstanceMethod: %@, requiredClassMethod: %@, optionInstanceMethod: %@, optionClassMethod: %@}",
            _name,
            _requiredInstanceMethodInfos,
            _requiredClassMethodInfos,
            _optionInstanceMethodInfos,
            _optionClassMethodInfos];
}

@end


@implementation DRClassInfo

- (instancetype)initWithClass:(Class)cls{
    if (!cls) return nil;
    self = [super init];
    if (self) {
        const char * name = class_getName(cls);
        _cls = cls;
        _superCls = class_getSuperclass(cls);
        _isMetaCls = class_isMetaClass(cls);
        if (!_isMetaCls) {
            _metaCls = objc_getMetaClass(name);
        }
        _name = [NSString stringWithUTF8String:name];
        _superClsInfo = [[DRClassInfo alloc] initWithClass:_superCls];
        [self _update];
    }
    return self;
}

- (void)_update{
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    _protocolInfos = nil;
    Class cls = self.cls;
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        for (unsigned int i = 0; i < ivarCount; i++) {
            DRClassIvarInfo *info = [[DRClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
        _ivarInfos = [NSDictionary dictionaryWithDictionary:ivarInfos];
    }
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        for (unsigned int i = 0; i < methodCount; i++) {
            DRClassMethodInfo *info = [[DRClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
        _methodInfos = [NSDictionary dictionaryWithDictionary:methodInfos];
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        for (unsigned int i = 0; i < propertyCount; i++) {
            DRClassPropertyInfo *info = [[DRClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
        _propertyInfos = [NSDictionary dictionaryWithDictionary:propertyInfos];
    }
    
    unsigned int protocolCount = 0;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(cls, &protocolCount);
    if (protocols) {
        NSMutableDictionary *protocolInfos = [NSMutableDictionary new];
        for (unsigned int i = 0; i < protocolCount; i++) {
            Protocol *protocol = protocols[i];
            DRClassProtocolInfo *info = [[DRClassProtocolInfo alloc] initWithProtocol:protocol];
            if (info.name) protocolInfos[info.name] = info;
        }
        free(protocols);
        _protocolInfos = [NSDictionary dictionaryWithDictionary:protocolInfos];
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    if (!_protocolInfos) _protocolInfos = @{};
}

- (void)update{
    [self _update];
    [self.superClsInfo _update];
}

+ (instancetype)infoWithClass:(Class)cls{
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    DRClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)cls);
    dispatch_semaphore_signal(semaphore);
    if (!info) {
        info = [[DRClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMetaCls ? metaCache : classCache, (__bridge const void *)cls, (__bridge const void *)info);
            dispatch_semaphore_signal(semaphore);
        }
    }
    return info;
}

+ (instancetype)infoWithClassName:(NSString *)clsName{
    if (clsName.length==0) return nil;
    Class cls = NSClassFromString(clsName);
    return [self infoWithClass:cls];
}

@end
