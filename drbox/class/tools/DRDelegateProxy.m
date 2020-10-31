//
//  DRDelegateProxy.m
//  drbox
//
//  Created by dr.box on 2020/9/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRDelegateProxy.h"
#import <objc/runtime.h>
#import "DRLock.h"
#import "NSInvocation+drbox.h"
#import "DRBlockDescription.h"

@interface _DRProxyBlock : NSObject{
    id _block;
    NSMethodSignature *_signature;
}

@property (nonatomic, assign, readonly) BOOL hasReturnValue;
@property (nonatomic, readonly) NSMethodSignature *signature;

- (instancetype)initWithBlock:(id)block;
- (id)invokeWithArgs:(NSArray *)args;

@end
@implementation _DRProxyBlock

- (instancetype)initWithBlock:(id)block{
    NSMethodSignature *sign = dr_signatureForBlock(block);
    if (!sign) return nil;
    self = [super init];
    if (self) {
        _block = [block copy];
        _signature = sign;
    }
    return self;
}

- (BOOL)hasReturnValue{
    return _signature.methodReturnLength > 0;
}

- (NSMethodSignature *)signature{
    return _signature;
}

- (id)invokeWithArgs:(NSArray *)args{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:_signature];
    for (int i=1; i<_signature.numberOfArguments; i++) {
        [inv dr_setArgument:args[i-1] atIndex:(NSUInteger)i];
    }
    [inv invokeWithTarget:_block];
    return [inv dr_getReturnValue];
}

@end

@interface DRDelegateProxy (){
    
    Protocol *_protocol;
    NSMutableDictionary *_callbacks;
    DRSemaphoreLock *_lock;
}

@end
@implementation DRDelegateProxy

- (instancetype)initWithProtocol:(Protocol *)protocol{
    NSCParameterAssert(protocol != NULL);
    self = [super init];
    if (self) {
        class_addProtocol(self.class, protocol);
        _protocol = protocol;
        _callbacks = [[NSMutableDictionary alloc] init];
        _lock = [[DRSemaphoreLock alloc] init];
    }
    return self;
}

+ (instancetype)proxyWithProtocol:(Protocol *)protocol{
    return [[self alloc] initWithProtocol:protocol];
}

- (void)bindSelector:(SEL)aSelector withBlock:(id)block{
    [_lock around:^{
        NSMethodSignature *selSign = [self methodSignatureForSelector:aSelector];
        NSError *err;
        if (dr_matchSignature(block, selSign, &err)) {
            NSString *key = NSStringFromSelector(aSelector);
            NSMutableArray *items = [self->_callbacks valueForKey:key];
            if (!items) {
                items = [NSMutableArray array];
                [self->_callbacks setValue:items forKey:key];
            }
            _DRProxyBlock *bk = [[_DRProxyBlock alloc] initWithBlock:block];
            if (bk) {
                [items addObject:bk];
            }
        }else{
#if DEBUG
            NSString *str = [NSString stringWithFormat:@"block与aSelector签名不匹配：%@", err.localizedDescription];
            NSAssert(NO, str);
#endif
        }
    }];
}

- (BOOL)isProxy{
    return YES;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [_lock around:^{
        NSArray *items = [self->_callbacks valueForKey:NSStringFromSelector(invocation.selector)];
        id ret = nil;
        BOOL hasReturnValue = NO;
        for (_DRProxyBlock *block in items) {
            // 只取最后一个返回值作为delegate方法的返回值
            hasReturnValue = block.hasReturnValue;
            ret = [block invokeWithArgs:[invocation dr_getAllArguments]];
        }
        if (invocation.methodSignature.methodReturnLength > 0 && hasReturnValue) {
            // delegate方法有返回值，并且block也有返回值，不调用delegate方法，直接将block返回值返回
            [invocation dr_setReturnValue:ret];
        }else{
            __autoreleasing id delegate = self.proxiedDelegate;
            if (delegate && [delegate respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:delegate];
            }
        }
    }];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    // 获取delegate的可选方法描述
    struct objc_method_description methodDescription = protocol_getMethodDescription(_protocol, selector, NO, YES);

    if (methodDescription.name == NULL) {
        // 获取delegate的必须方法描述
        methodDescription = protocol_getMethodDescription(_protocol, selector, YES, YES);
        if (methodDescription.name == NULL) return [super methodSignatureForSelector:selector];
    }

    return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
}

- (BOOL)respondsToSelector:(SEL)selector {
    __autoreleasing id delegate = self.proxiedDelegate;
    if ([delegate respondsToSelector:selector]) return YES;
    if ([[_callbacks allKeys] containsObject:NSStringFromSelector(selector)]) return YES;
    return [super respondsToSelector:selector];
}

@end
