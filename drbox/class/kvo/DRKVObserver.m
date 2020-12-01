//
//  DRKVObserver.m
//  drbox
//
//  Created by dr.box on 2020/11/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRKVObserver.h"
#import "NSInvocation+drbox.h"
#import "NSString+drbox.h"
#import "DRDeallocHook.h"
#import "DRBlockDescription.h"

@interface _DRKVOAction : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, copy) id block;
@property (nonatomic, strong) NSMethodSignature *blockSign;

- (nullable instancetype)initWithTarget:(id)target action:(SEL)action;
- (nullable instancetype)initWithBlock:(id)block;

- (void)invokeWithNewValue:(id)newValue oldValue:(id)oldValue;

@end
@implementation _DRKVOAction

- (instancetype)initWithTarget:(id)target action:(SEL)action{
    if (![target respondsToSelector:action]) return nil;
    self = [super init];
    if (self) {
        self.target = target;
        self.action = action;
    }
    return self;
}

- (instancetype)initWithBlock:(id)block{
    NSMethodSignature *blockSign = dr_signatureForBlock(block);
    if (!blockSign) return nil;
    self = [super init];
    if (self) {
        self.block = block;
        self.blockSign = blockSign;
    }
    return self;
}

- (void)invokeWithNewValue:(id)newValue oldValue:(id)oldValue{
    if ([self.target respondsToSelector:self.action]) {
        NSMethodSignature *sign = [self.target methodSignatureForSelector:self.action];
        NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:sign];
        if (sign.numberOfArguments > 2 && newValue){
            [invoke dr_setArgument:newValue atIndex:2];
        }
        if (sign.numberOfArguments > 3 && oldValue) {
            [invoke dr_setArgument:newValue atIndex:3];
        }
        invoke.selector = self.action;
        [invoke invokeWithTarget:self.target];
    }
    if (self.block) {
        NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:self.blockSign];
        if (self.blockSign.numberOfArguments > 1 && newValue){
            [invoke dr_setArgument:newValue atIndex:1];
        }
        if (self.blockSign.numberOfArguments > 2 && oldValue) {
            [invoke dr_setArgument:newValue atIndex:2];
        }
        [invoke invokeWithTarget:self.block];
    }
}

@end

@interface DRKVObserver (){
    
    NSMutableDictionary<NSString *, NSMutableSet<_DRKVOAction *> *> *_maps;
}
@property (nonatomic, weak) id observable;

@end
@implementation DRKVObserver

- (instancetype)initWithObservable:(id)observable{
    self = [super init];
    if (self) {
        _maps = [[NSMutableDictionary alloc] init];
        self.observable = observable;
        [DRDeallocHook addDeallocHookToObject:observable withBlock:^(id  _Nonnull hookObj) {
            [self removeObserver];
        }];
    }
    return self;
}

- (BOOL)addKeyPath:(NSString *)keyPath forTarget:(id)target action:(SEL)action{
    if (keyPath.dr_trim.length==0) return NO;
    _DRKVOAction *ac = [[_DRKVOAction alloc] initWithTarget:target action:action];
    if (!ac) return NO;
    NSMutableSet *set = _maps[keyPath];
    if (!set) {
        set = [NSMutableSet set];
        _maps[keyPath] = set;
    }
    [set addObject:ac];
    return YES;
}

- (BOOL)addKeyPath:(NSString *)keyPath forBlock:(id)block{
    if (keyPath.dr_trim.length==0) return NO;
    _DRKVOAction *ac = [[_DRKVOAction alloc] initWithBlock:block];
    if (!ac) return NO;
    NSMutableSet *set = _maps[keyPath];
    if (!set) {
        set = [NSMutableSet set];
        _maps[keyPath] = set;
    }
    [set addObject:ac];
    return YES;
}

- (void)removeObserver{
    NSArray *keys = [_maps allKeys];
    for (NSString *keyPath in keys) {
        [self.observable removeObserver:self forKeyPath:keyPath];
    }
}

- (BOOL)canAddObserverForKeyPath:(NSString *)keyPath{
    if (keyPath.dr_trim.length==0) return NO;
    NSMutableSet *set = _maps[keyPath];
    return set.count==1;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    NSMutableSet *set = _maps[keyPath];
    if (set.count) {
        id newVal = change[NSKeyValueChangeNewKey];
        id oldVal = change[NSKeyValueChangeOldKey];
        newVal = [newVal isKindOfClass:[NSNull class]] ? nil : newVal;
        oldVal = [oldVal isKindOfClass:[NSNull class]] ? nil : oldVal;
        for (_DRKVOAction *action in set) {
            [action invokeWithNewValue:newVal oldValue:oldVal];
        }
    }
}

@end
