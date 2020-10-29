//
//  NSInvocation+drbox.m
//  drbox
//
//  Created by dr.box on 2020/9/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSInvocation+drbox.h"
#import <UIKit/UIKit.h>


@implementation NSInvocation (drbox)

+ (void)dr_setArgumentsForInvocation:(NSInvocation *)inv, ...{
    if (!inv) return;
    va_list args;
    va_start(args, inv);
    [inv dr_setArguments:args];
    va_end(args);
}

- (void)dr_setArguments:(va_list)args{
#define PULL_AND_SET_ARG(type) \
do { \
    type val = va_arg(args, type); \
    [self setArgument:&val atIndex:(NSInteger)i]; \
} while (0)
    
    NSUInteger count = [self.methodSignature numberOfArguments];
    BOOL isBlockInv = strcmp([self.methodSignature getArgumentTypeAtIndex:0], "@?") == 0;
    for (int i = isBlockInv ? 1 : 2; i < count; i++) {
        char * type = (char *)[self.methodSignature getArgumentTypeAtIndex:(NSUInteger)i];
        while (*type == 'r' || // const
               *type == 'n' || // in
               *type == 'N' || // inout
               *type == 'o' || // out
               *type == 'O' || // bycopy
               *type == 'R' || // byref
               *type == 'V') { // oneway
            type ++; // 移动字符串游标
            // const char * 这样的类型为：r*，所以在判断类型的时候，需要将字符串游标向后移动1位后，*type == '*'
        }
        BOOL unsupportedType = NO;
        switch (*type) {
            case 'v': // void
            case 'B': // bool
            case 'c': // BOOL / char
            case 'C': // unsigned char / Boolean
            case 's': // short
            case 'S': // unsigned short
            case 'i': // int / NSInteger(32bit)
            case 'I': // unsigned int / NSUInteger(32bit
            case 'l': // long(32bit)
            case 'L': // unsigned long(32bit)
            {
                PULL_AND_SET_ARG(int);
            } break;
            case 'q': // long long / long(64bit) / NSInteger(64bit)
            case 'Q': // unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
            {
                PULL_AND_SET_ARG(long long);
            } break;
            case 'f': // float / CGFloat(32bit)
            case 'd': // double / CGFloat(64bit)
            case 'D': // long double
            {
                PULL_AND_SET_ARG(double);
            } break;
            case '@': // id / Block
            {
                PULL_AND_SET_ARG(id);
            } break;
            case '*': // char *
            case '^': // 指针类型，例如：void *对应的类型为：^v;Class *为：^#;SEL *为：^:
            {
                PULL_AND_SET_ARG(void *);
            } break;
            case ':':
            {
                PULL_AND_SET_ARG(SEL);
            } break;
            case '#':
            {
                PULL_AND_SET_ARG(Class);
            } break;
            case '{': // struct
            {
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    PULL_AND_SET_ARG(CGPoint);
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    PULL_AND_SET_ARG(CGSize);
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    PULL_AND_SET_ARG(CGRect);
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    PULL_AND_SET_ARG(CGVector);
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    PULL_AND_SET_ARG(CGAffineTransform);
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    PULL_AND_SET_ARG(CATransform3D);
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    PULL_AND_SET_ARG(NSRange);
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    PULL_AND_SET_ARG(UIOffset);
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    PULL_AND_SET_ARG(UIEdgeInsets);
                } else {
                    unsupportedType = YES;
                }
            } break;
            default:
            {
                unsupportedType = YES;
            } break;
        }
#if DEBUG
        if (unsupportedType) {
            NSString *desc = [NSString stringWithFormat:@"drbox dr_setArguments unsupported type:%s",
            [self.methodSignature getArgumentTypeAtIndex:(NSUInteger)i]];
            NSAssert(NO, desc);
        }
#endif
    }
    
#undef PULL_AND_SET_ARG
}

- (void)dr_setArgument:(id)object atIndex:(NSUInteger)index {
#define PULL_AND_SET_ARG(type, selector, defaultVal) \
do { \
    type val = defaultVal; \
    @try {  \
        val = [object selector]; \
    } @catch (NSException *exception) { \
        NSAssert(NO, @"object:%@ cannot be convert to type:%s", [object description], @encode(type)); \
    } \
    [self setArgument:&val atIndex:(NSInteger)index]; \
} while (0)

    const char *type = [self.methodSignature getArgumentTypeAtIndex:index];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type ++; // 移动字符串游标
        // const char * 这样的类型为：r*，所以在判断类型的时候，需要将字符串游标向后移动1位后，*type == '*'
    }

    // 需要注意：block中的id类型与类方法中的id类型的区别
    if (strcmp(type, @encode(id)) == 0 ||
        strcmp(type, @encode(Class)) == 0 ||
        strncmp(type, "@\"", 2) == 0 ||
        strncmp(type, @encode(dispatch_block_t), 2) == 0) {
        // 例如：block中的NSString表示为：@"NSString", Block表示为：@?<block的签名>
        [self setArgument:&object atIndex:(NSInteger)index];
    } else if (strcmp(type, @encode(char)) == 0) {
        PULL_AND_SET_ARG(char, charValue, 0);
    } else if (strcmp(type, @encode(int)) == 0) {
        PULL_AND_SET_ARG(int, intValue, 0);
    } else if (strcmp(type, @encode(short)) == 0) {
        PULL_AND_SET_ARG(short, shortValue, 0);
    } else if (strcmp(type, @encode(long)) == 0) {
        PULL_AND_SET_ARG(long, longValue, 0);
    } else if (strcmp(type, @encode(long long)) == 0) {
        PULL_AND_SET_ARG(long long, longLongValue, 0);
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        PULL_AND_SET_ARG(unsigned char, unsignedCharValue, 0);
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        PULL_AND_SET_ARG(unsigned int, unsignedIntValue, 0);
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        PULL_AND_SET_ARG(unsigned short, unsignedShortValue, 0);
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        PULL_AND_SET_ARG(unsigned long, unsignedLongValue, 0);
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        PULL_AND_SET_ARG(unsigned long long, unsignedLongLongValue, 0);
    } else if (strcmp(type, @encode(float)) == 0) {
        PULL_AND_SET_ARG(float, floatValue, 0.0);
    } else if (strcmp(type, @encode(double)) == 0) {
        PULL_AND_SET_ARG(double, doubleValue, 0.0);
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        PULL_AND_SET_ARG(BOOL, boolValue, 0.0);
    } else if (strcmp(type, @encode(char *)) == 0) {
        const char *cString = NULL;
        if ([object respondsToSelector:@selector(UTF8String)]) {
            cString = [object UTF8String];
        }else{
            NSAssert(NO, @"object:%@ cannot be convert to type:%s", [object description], type);
        }
        [self setArgument:&cString atIndex:(NSInteger)index];
    } else if (strncmp(type, "^", 1) == 0){
        // void *：^v；int *：^i ...
        void * p = (__bridge void *)object;
        [self setArgument:&p atIndex:(NSInteger)index];
    } else {
        NSCParameterAssert([object isKindOfClass:NSValue.class]);

        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment([object objCType], &valueSize, NULL);

#if DEBUG
        NSUInteger argSize = 0;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        NSCAssert(valueSize == argSize, @"Value size does not match argument size in -dr_setArgument: %@ atIndex: %lu", object, (unsigned long)index);
#endif
        
        unsigned char valueBytes[valueSize];
        [object getValue:valueBytes];

        [self setArgument:valueBytes atIndex:(NSInteger)index];
    }

#undef PULL_AND_SET_ARG
}

- (void)dr_setReturnValue:(id)value{
#define PULL_AND_SET_RET(type, selector, defaultVal) \
do { \
    type val = defaultVal; \
    @try {  \
        val = [value selector]; \
    } @catch (NSException *exception) { \
        NSAssert(NO, @"value:%@ cannot be convert to type:%s", [value description], @encode(type)); \
    } \
    [self setReturnValue:&val]; \
} while (0)
    const char * type = self.methodSignature.methodReturnType;
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type ++; // 移动字符串游标
        // const char * 这样的类型为：r*，所以在判断类型的时候，需要将字符串游标向后移动1位后，*type == '*'
    }
    if (strcmp(type, @encode(id)) == 0 ||
        strcmp(type, @encode(Class)) == 0 ||
        strncmp(type, "@\"", 2) == 0 ||
        strncmp(type, @encode(dispatch_block_t), 2) == 0) {
        [self setReturnValue:&value];
    } else if (strcmp(type, @encode(char)) == 0) {
        PULL_AND_SET_RET(char, charValue, 0);
    } else if (strcmp(type, @encode(int)) == 0) {
        PULL_AND_SET_RET(int, intValue, 0);
    } else if (strcmp(type, @encode(short)) == 0) {
        PULL_AND_SET_RET(short, shortValue, 0);
    } else if (strcmp(type, @encode(long)) == 0) {
        PULL_AND_SET_RET(long, longValue, 0);
    } else if (strcmp(type, @encode(long long)) == 0) {
        PULL_AND_SET_RET(long long, longLongValue, 0);
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        PULL_AND_SET_RET(unsigned char, unsignedCharValue, 0);
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        PULL_AND_SET_RET(unsigned int, unsignedIntValue, 0);
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        PULL_AND_SET_RET(unsigned short, unsignedShortValue, 0);
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        PULL_AND_SET_RET(unsigned long, unsignedLongValue, 0);
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        PULL_AND_SET_RET(unsigned long long, unsignedLongLongValue, 0);
    } else if (strcmp(type, @encode(float)) == 0) {
        PULL_AND_SET_RET(float, floatValue, 0.0);
    } else if (strcmp(type, @encode(double)) == 0) {
        PULL_AND_SET_RET(double, doubleValue, 0.0);
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        PULL_AND_SET_RET(BOOL, boolValue, 0.0);
    } else if (strcmp(type, @encode(char *)) == 0) {
        const char *cString = NULL;
        if ([value respondsToSelector:@selector(UTF8String)]) {
            cString = [value UTF8String];
        }else{
            NSAssert(NO, @"value:%@ cannot be convert to type:%s", [value description], type);
        }
        [self setReturnValue:&cString];
    } else if (strncmp(type, "^", 1) == 0){
        // void *：^v；int *：^i ...
        void * p = (__bridge void *)value;
        [self setArgument:&p atIndex:(NSInteger)index];
    } else {
        NSCParameterAssert([value isKindOfClass:NSValue.class]);

        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment([value objCType], &valueSize, NULL);

#if DEBUG
        NSUInteger argSize = 0;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        NSCAssert(valueSize == argSize, @"Value size does not match argument size in -dr_setReturnValue: %@ atIndex: %lu", value, (unsigned long)index);
#endif
        
        unsigned char valueBytes[valueSize];
        [value getValue:valueBytes];
        [self setReturnValue:valueBytes];
    }
#undef PULL_AND_SET_RET
}

- (id)dr_getReturnValue{
#define WRAP_AND_RETURN(type) \
do { \
    type val = 0; \
    [self getReturnValue:&val]; \
    return @(val); \
} while (0)
    NSUInteger length = [self.methodSignature methodReturnLength];
    if (length == 0) return nil;
    char *type = (char *)[self.methodSignature methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type ++; // 移动字符串游标
        // const char * 这样的类型为：r*，所以在判断类型的时候，需要将字符串游标向后移动1位后，*type == '*'
    }
    // 需要注意：block中的id类型与类方法中的id类型的区别
    if (strcmp(type, @encode(id)) == 0 ||
        strcmp(type, @encode(Class)) == 0 ||
        strncmp(type, "@\"", 2) == 0) {
        // 例如：block中的NSString表示为：@"NSString"
        __autoreleasing id returnObj;
        [self getReturnValue:&returnObj];
        return returnObj;
    } else if (strncmp(type, @encode(dispatch_block_t), 2) == 0) {
        // block中的Block类型表示为：@?<block的签名>
        __unsafe_unretained id block = nil;
        [self getReturnValue:&block];
        return [block copy];
    } else if (strcmp(type, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(type, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(type, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(type, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(type, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(type, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(type, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(type, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strncmp(type, "^", 1) == 0){
        // void *：^v；int *：^i ...
        void *v = NULL;
        [self getReturnValue:&v];
        if (v != NULL) {
            return (__bridge id)v; // 这里可能导致crash，当v指针无法转换id类型时
        }
        // 其他类型的指针不作处理
        return nil;
    } else {
        // struct or other
        unsigned char valueBytes[length];
        [self getReturnValue:valueBytes];
        
        return [NSValue valueWithBytes:valueBytes objCType:type];
    }
        
#undef WRAP_AND_RETURN
}

- (id)dr_argumentAtIndex:(NSInteger)index{
#define WRAP_AND_RETURN(type) \
do { \
    type val = 0; \
    [self getArgument:&val atIndex:index]; \
    return @(val); \
} while (0)
    const char *type = [self.methodSignature getArgumentTypeAtIndex:index];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type ++; // 移动字符串游标
        // const char * 这样的类型为：r*，所以在判断类型的时候，需要将字符串游标向后移动1位后，*type == '*'
    }
    if (strcmp(type, @encode(id)) == 0 ||
        strcmp(type, @encode(Class)) == 0 ||
        strncmp(type, "@\"", 2) == 0) {
        __autoreleasing id returnObj;
        [self getArgument:&returnObj atIndex:index];
        return returnObj;
    } else if (strcmp(type, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(type, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(type, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(type, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(type, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(type, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(type, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(type, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strncmp(type, "^", 1) == 0){
        // void *：^v；int *：^i ...
        void *v = NULL;
        [self getArgument:&v atIndex:index];
        if (v != NULL) {
            return (__bridge id)v; // 这里可能导致crash，当v指针无法转换id类型时
        }
        return nil;
    } else if (strncmp(type, @encode(dispatch_block_t), 2) == 0) {
        __unsafe_unretained id block = nil;
        [self getArgument:&block atIndex:index];
        return [block copy];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(type, &valueSize, NULL);

        unsigned char valueBytes[valueSize];
        [self getArgument:valueBytes atIndex:index];
        
        return [NSValue valueWithBytes:valueBytes objCType:type];
    }
#undef WRAP_AND_RETURN
}

- (NSArray *)dr_getAllArguments{
    NSUInteger numberOfArguments = self.methodSignature.numberOfArguments;
    NSMutableArray *argumentsArray = [NSMutableArray arrayWithCapacity:numberOfArguments - 2];
    for (NSUInteger index = 2; index < numberOfArguments; index++) {
        [argumentsArray addObject:[self dr_argumentAtIndex:index] ?: [NSNull null]];
    }
    return [NSArray arrayWithArray:argumentsArray];
}

@end
