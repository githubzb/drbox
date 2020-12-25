//
//  CADisplayLink+drbox.m
//  drbox
//
//  Created by DHY on 2020/12/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "CADisplayLink+drbox.h"
#import "DRWeakProxy.h"
#import "DRDeallocHook.h"

@implementation CADisplayLink (drbox)

+ (instancetype)dr_scheduledDisplayLinkWithTarget:(id)target selector:(SEL)sel{
    if (!target) return nil;
    DRWeakProxy *weakProxy = [DRWeakProxy weakProxyForObject:target];
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:weakProxy selector:sel];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    return link;
}

+ (instancetype)dr_displayLinkWithTarget:(id)target selector:(SEL)sel{
    if (!target) return nil;
    DRWeakProxy *weakProxy = [DRWeakProxy weakProxyForObject:target];
    return [CADisplayLink displayLinkWithTarget:weakProxy selector:sel];
}

@end
