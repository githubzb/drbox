//
//  DRWeakProxy.m
//  drbox
//
//  Created by DHY on 2020/12/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRWeakProxy.h"

@interface DRWeakProxy ()

@property (nonatomic, weak) id target;

@end
@implementation DRWeakProxy

+ (instancetype)weakProxyForObject:(id)targetObject{
    if (!targetObject) return nil;
    DRWeakProxy *proxy = [DRWeakProxy alloc];
    proxy.target = targetObject;
    return proxy;
}

#pragma mark - Forwarding Messages

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // 当target==nil的时候，return 0/NULL/nil.
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end
