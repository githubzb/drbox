//
//  DRBlockDescription.m
//  drbox
//
//  Created by dr.box on 2020/9/3.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRBlockDescription.h"
#import "NSInvocation+drbox.h"
#import <UIKit/UIKit.h>

struct ZBBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;    // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};
// flags enum
typedef NS_ENUM(int, DRBlockDescriptionFlags) {
    DRBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    DRBlockDescriptionFlagsHasCtor = (1 << 26),
    DRBlockDescriptionFlagsIsGlobal = (1 << 28),
    DRBlockDescriptionFlagsHasStret = (1 << 29),
    DRBlockDescriptionFlagsHasSignature = (1 << 30)
};


NSMethodSignature * dr_signatureForBlock(id block){
    if (!block) return nil;
    struct ZBBlockLiteral *blockRef = (__bridge struct ZBBlockLiteral *)block;
     DRBlockDescriptionFlags _flags = blockRef->flags;
     if (_flags & DRBlockDescriptionFlagsHasSignature) {
         void *signatureLocation = blockRef->descriptor;
         signatureLocation += sizeof(unsigned long int);
         signatureLocation += sizeof(unsigned long int);
         if (_flags & DRBlockDescriptionFlagsHasCopyDispose) {
             signatureLocation += sizeof(void(*)(void *dst, void *src));
             signatureLocation += sizeof(void (*)(void *src));
         }
         const char *signature = (*(const char **)signatureLocation);
         return [NSMethodSignature signatureWithObjCTypes:signature];
     }
    return nil;
}

static inline NSError *dr_error(NSString *reason){
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:3000
                           userInfo:@{NSLocalizedFailureReasonErrorKey: reason ?: @""}];
}

static inline NSString * dr_argumentNoMatchReason(int index, const char *signType, const char *blockType){
    return [NSString stringWithFormat:@"argumentType no match,"
            "at index %i. sign`s type: %s and block`s type: %s", index, signType, blockType];
}

static inline NSString * dr_returnTypeNoMatchReason(const char *signType, const char *blockType){
    return [NSString stringWithFormat:@"return type no match,"
            "sign`s type: %s and block`s type: %s", signType, blockType];
}

BOOL dr_matchAllSignature(id block, NSMethodSignature *sign, NSError **error){
    *error = NULL;
    if (!sign){
        *error = dr_error(@"sign is nil");
        return NO;
    }
    NSMethodSignature *blockSign = dr_signatureForBlock(block);
    if (!blockSign) {
        *error = dr_error(@"block`s signature is nil");
        return NO;
    }
    // 需要判断sign是否是block的签名
    if (strcmp([sign getArgumentTypeAtIndex:0], "@?") == 0) {
        // sign是Block的签名
        if (blockSign.numberOfArguments != sign.numberOfArguments) {
            *error = dr_error(@"numberOfArguments no match");
            return NO;
        }
        if (strcmp(blockSign.methodReturnType, sign.methodReturnType) != 0) {
            *error = dr_error(dr_returnTypeNoMatchReason(sign.methodReturnType, blockSign.methodReturnType));
            return NO;
        }
        for (int i = 1; i < sign.numberOfArguments; i++) {
            const char * signType = [sign getArgumentTypeAtIndex:(NSUInteger)i];
            const char * blockType = [blockSign getArgumentTypeAtIndex:(NSUInteger)i];
            if (strcmp(signType, blockType) != 0) {
                *error = dr_error(dr_argumentNoMatchReason(i-1, signType, blockType));
                return NO;
            }
        }
        return YES;
    }
    
    // sign 是类方法签名
    if (blockSign.numberOfArguments+1 != sign.numberOfArguments) {
        *error = dr_error(@"numberOfArguments no match");
        return NO;
    }
    
    /**
     具体类：NSNumber
     signType:@
     blockType:@"NSNumber"
             
     block
     signType:@?
     blockType:@?<v@?>
     */
    if (strcmp(sign.methodReturnType, @encode(id)) == 0) {
        // id
        if (!(strncmp(blockSign.methodReturnType, "@", 1) == 0 &&
              strncmp(blockSign.methodReturnType, "@?", 2) != 0)) {
            *error = dr_error(dr_returnTypeNoMatchReason(sign.methodReturnType, blockSign.methodReturnType));
            return NO;
        }
    }else if (strcmp(sign.methodReturnType, @encode(dispatch_block_t)) == 0) {
        // block
        if (strncmp(blockSign.methodReturnType, @encode(dispatch_block_t), 2) !=0 ) {
            *error = dr_error(dr_returnTypeNoMatchReason(sign.methodReturnType, blockSign.methodReturnType));
            return NO;
        }
    }else{
        if (strcmp(sign.methodReturnType, blockSign.methodReturnType) != 0) {
            *error = dr_error(dr_returnTypeNoMatchReason(sign.methodReturnType, blockSign.methodReturnType));
            return NO;
        }
    }
    
    for (int i = 2; i < sign.numberOfArguments; i++) {
        const char * signType = [sign getArgumentTypeAtIndex:(NSUInteger)i];
        const char * blockType = [blockSign getArgumentTypeAtIndex:(NSUInteger)(i-1)];
        if (strcmp(signType, "@") == 0) {
            // id
            if (!(strncmp(blockType, "@", 1) == 0 && strncmp(blockType, "@?", 2) != 0)) {
                *error = dr_error(dr_argumentNoMatchReason(i-2, signType, blockType));
                return NO;
            }
        }else if (strcmp(signType, "@?") == 0){
            // block类型
            if (strncmp(signType, blockType, 2) != 0) {
                *error = dr_error(dr_argumentNoMatchReason(i-2, signType, blockType));
                return NO;
            }
        }else{
            if (strcmp(signType, blockType) != 0) {
                *error = dr_error(dr_argumentNoMatchReason(i-2, signType, blockType));
                return NO;
            }
        }
    }
    
    return YES;
}


BOOL dr_matchSignature(id block, NSMethodSignature *sign, NSError **error){
    *error = NULL;
    if (!sign){
        *error = dr_error(@"sign is nil");
        return NO;
    }
    NSMethodSignature *blockSign = dr_signatureForBlock(block);
    if (!blockSign) {
        *error = dr_error(@"block`s signature is nil");
        return NO;
    }
    // 需要判断sign是否是block的签名
    if (strcmp([sign getArgumentTypeAtIndex:0], "@?") == 0) {
        // sign是Block的签名
        if (strcmp(blockSign.methodReturnType, sign.methodReturnType) != 0) {
            *error = dr_error(dr_returnTypeNoMatchReason(sign.methodReturnType, blockSign.methodReturnType));
            return NO;
        }
        for (int i = 1; i < sign.numberOfArguments; i++) {
            if (i >= blockSign.numberOfArguments) {
                break;
            }
            const char * signType = [sign getArgumentTypeAtIndex:(NSUInteger)i];
            const char * blockType = [blockSign getArgumentTypeAtIndex:(NSUInteger)i];
            if (strcmp(signType, blockType) != 0) {
                *error = dr_error(dr_argumentNoMatchReason(i-1, signType, blockType));
                return NO;
            }
        }
        return YES;
    }
    
    // sign 是类方法签名
    
    /**
     具体类：NSNumber
     signType:@
     blockType:@"NSNumber"
             
     block
     signType:@?
     blockType:@?<v@?>
     */
    if (strcmp(sign.methodReturnType, @encode(id)) == 0) {
        // id
        if (!(strncmp(blockSign.methodReturnType, "@", 1) == 0 &&
              strncmp(blockSign.methodReturnType, "@?", 2) != 0)) {
            *error = dr_error(dr_returnTypeNoMatchReason(sign.methodReturnType, blockSign.methodReturnType));
            return NO;
        }
    }else if (strcmp(sign.methodReturnType, @encode(dispatch_block_t)) == 0) {
        // block
        if (strncmp(blockSign.methodReturnType, @encode(dispatch_block_t), 2) !=0 ) {
            *error = dr_error(dr_returnTypeNoMatchReason(sign.methodReturnType, blockSign.methodReturnType));
            return NO;
        }
    }else{
        if (strcmp(sign.methodReturnType, blockSign.methodReturnType) != 0) {
            *error = dr_error(dr_returnTypeNoMatchReason(sign.methodReturnType, blockSign.methodReturnType));
            return NO;
        }
    }
    
    for (int i = 2; i < sign.numberOfArguments; i++) {
        if (i-1 >= blockSign.numberOfArguments) {
            break;
        }
        
        const char * signType = [sign getArgumentTypeAtIndex:(NSUInteger)i];
        const char * blockType = [blockSign getArgumentTypeAtIndex:(NSUInteger)(i-1)];
        if (strcmp(signType, "@") == 0) {
            // id
            if (!(strncmp(blockType, "@", 1) == 0 && strncmp(blockType, "@?", 2) != 0)) {
                *error = dr_error(dr_argumentNoMatchReason(i-2, signType, blockType));
                return NO;
            }
        }else if (strcmp(signType, "@?") == 0){
            // block类型
            if (strncmp(signType, blockType, 2) != 0) {
                *error = dr_error(dr_argumentNoMatchReason(i-2, signType, blockType));
                return NO;
            }
        }else{
            if (strcmp(signType, blockType) != 0) {
                *error = dr_error(dr_argumentNoMatchReason(i-2, signType, blockType));
                return NO;
            }
        }
    }
    
    return YES;
}

id dr_executeBlock(id block, ...){
    va_list args;
    va_start(args, block);
    id ret = dr_executeBlockVaList(block, args);
    va_end(args);
    return ret;
}

id dr_executeBlockVaList(id block, va_list args){
    if (!block) return nil;
    NSMethodSignature *blockSign = dr_signatureForBlock(block);
    if (!blockSign) return nil;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:blockSign];
    inv.target = block;
    [inv dr_setArguments:args];
    [inv invoke];
    if (blockSign.methodReturnLength == 0) {
        return nil;
    }
    return [inv dr_getReturnValue];
}

id dr_executeBlockArgs(id block, NSArray *args){
    if (!block) return nil;
    NSMethodSignature *sign = dr_signatureForBlock(block);
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sign];
    inv.target = block;
    for (int i=0; i<args.count; i++) {
        [inv dr_setArgument:args[i] atIndex:(NSUInteger)i+1];
    }
    [inv invoke];
    if (sign.methodReturnLength == 0) {
        return nil;
    }
    return [inv dr_getReturnValue];
}
