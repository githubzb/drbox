//
//  NSObject+DRKVO.m
//  drbox
//
//  Created by dr.box on 2020/11/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSObject+DRKVO.h"
#import "DRKVObserver.h"
#import "NSObject+drbox.h"

@implementation NSObject (DRKVO)

- (BOOL)dr_observeKeyPath:(NSString *)keyPath target:(id)target action:(SEL)action{
    DRKVObserver *observer = [self _dr_observer];
    if (![observer addKeyPath:keyPath forTarget:target action:action]) {
        return NO;
    }
    if ([observer canAddObserverForKeyPath:keyPath]) {
        [self addObserver:observer
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:NULL];
    }
    return YES;
}

- (BOOL)dr_observeKeyPath:(NSString *)keyPath callback:(id)callback{
    DRKVObserver *observer = [self _dr_observer];
    if (![observer addKeyPath:keyPath forBlock:callback]) {
        return NO;
    }
    if ([observer canAddObserverForKeyPath:keyPath]) {
        [self addObserver:observer
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:NULL];
    }
    return YES;
}

- (DRKVObserver *)_dr_observer{
    DRKVObserver *observer = [self dr_associateValueForKey:_cmd];
    if (!observer) {
        observer = [[DRKVObserver alloc] initWithObservable:self];
        [self dr_setAssociateStrongValue:observer key:_cmd];
    }
    return observer;
}

@end
