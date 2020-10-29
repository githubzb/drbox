//
//  NSNotificationCenter+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/13.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSNotificationCenter+drbox.h"
#import "DRDeallocHook.h"

@implementation NSNotificationCenter (drbox)

+ (void)dr_addObserver:(id)observer
              selector:(SEL)aSelector
                  name:(NSNotificationName)aName
                object:(id)anObject{
    if (!observer) return;
    [[self defaultCenter] addObserver:observer
                             selector:aSelector
                                 name:aName
                               object:anObject];
    [DRDeallocHook addDeallocHookToObject:observer
                                 observer:[self defaultCenter]
                         observerSelector:@selector(removeObserver:)];
}

+ (void)dr_postOnMainThread:(NSNotification *)notification{
    [self dr_postOnMainThread:notification waitUntilDone:NO];
}

+ (void)dr_postOnMainThread:(NSNotification *)notification waitUntilDone:(BOOL)wait{
    if ([NSThread isMainThread]) {
        [[self defaultCenter] postNotification:notification];
        return;
    }
    [self performSelectorOnMainThread:@selector(_dr_postNotification:)
                           withObject:notification
                        waitUntilDone:wait];
}

+ (void)dr_postOnMainThreadWithName:(NSString *)name object:(nullable id)object{
    [self dr_postOnMainThreadWithName:name object:object userInfo:nil];
}

+ (void)dr_postOnMainThreadWithName:(NSString *)name
                             object:(nullable id)object
                           userInfo:(nullable NSDictionary *)userInfo{
    [self dr_postOnMainThreadWithName:name object:object userInfo:userInfo waitUntilDone:NO];
}

+ (void)dr_postOnMainThreadWithName:(NSString *)name
                             object:(nullable id)object
                           userInfo:(nullable NSDictionary *)userInfo
                      waitUntilDone:(BOOL)wait{
    if ([NSThread isMainThread]) {
        [[self defaultCenter] postNotificationName:name object:object userInfo:userInfo];
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:name forKey:@"name"];
    [dic setValue:object forKey:@"object"];
    [dic setValue:userInfo forKey:@"userInfo"];
    [self performSelectorOnMainThread:@selector(_dr_postNotificationName:)
                           withObject:[NSDictionary dictionaryWithDictionary:dic]
                        waitUntilDone:wait];
}

+ (void)_dr_postNotification:(NSNotification *)notification {
    [[self defaultCenter] postNotification:notification];
}

+ (void)_dr_postNotificationName:(NSDictionary *)info {
    NSString *name = [info objectForKey:@"name"];
    id object = [info objectForKey:@"object"];
    NSDictionary *userInfo = [info objectForKey:@"userInfo"];
    
    [[self defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}

@end
