//
//  UIControl+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/29.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UIControl+drbox.h"
#import "NSObject+drbox.h"

@interface _DRControlBlockTarget : NSObject

@property (nonatomic, copy) DRControlEventBlock block;
@property (nonatomic, assign) UIControlEvents events;

- (id)initWithBlock:(DRControlEventBlock)block events:(UIControlEvents)events;
- (void)invoke:(id)sender;

@end

@implementation _DRControlBlockTarget

- (id)initWithBlock:(DRControlEventBlock)block events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        _block = [block copy];
        _events = events;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end

@implementation UIControl (drbox)

- (void)dr_removeAllTargets{
    [self.allTargets enumerateObjectsUsingBlock:^(id  _Nonnull target, BOOL * _Nonnull stop) {
        [self removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
    }];
    [[self allControlBlockTargets] removeAllObjects];
}

- (void)dr_setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    if (!target || !action || !controlEvents) return;
    NSSet *targets = [self allTargets];
    for (id currentTarget in targets) {
        NSArray *actions = [self actionsForTarget:currentTarget forControlEvent:controlEvents];
        for (NSString *currentAction in actions) {
            [self removeTarget:currentTarget
                        action:NSSelectorFromString(currentAction)
              forControlEvents:controlEvents];
        }
    }
    [self addTarget:target action:action forControlEvents:controlEvents];
}

- (void)dr_addActionBlock:(DRControlEventBlock)block forControlEvents:(UIControlEvents)controlEvents{
    if (!controlEvents) return;
    _DRControlBlockTarget *target = [[_DRControlBlockTarget alloc] initWithBlock:block
                                                                          events:controlEvents];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    NSMutableArray *targets = [self allControlBlockTargets];
    [targets addObject:target];
}

- (void)dr_setActionBlock:(DRControlEventBlock)block forControlEvents:(UIControlEvents)controlEvents{
    [self dr_removeAllActionBlocksForControlEvents:controlEvents];
    [self dr_addActionBlock:block forControlEvents:controlEvents];
}

- (void)dr_removeAllActionBlocksForControlEvents:(UIControlEvents)controlEvents{
    if (!controlEvents) return;
    NSMutableArray *targets = [self allControlBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    for (_DRControlBlockTarget *target in targets) {
        if (target.events & controlEvents) {
            /**
             target.events：UIControlEventTouchDown | UIControlEventTouchUpInside | UIControlEventTouchUpOutside
             controlEvents：UIControlEventTouchDown | UIControlEventTouchUpOutside
             newEvent：UIControlEventTouchUpInside
             */
            UIControlEvents newEvent = target.events & (~controlEvents);
            if (newEvent) {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                target.events = newEvent;
                [self addTarget:target action:@selector(invoke:) forControlEvents:target.events];
            } else {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                [removes addObject:target];
            }
        }
    }
    [targets removeObjectsInArray:removes];
}

#pragma mark - private
- (NSMutableArray *)allControlBlockTargets {
    NSMutableArray *targets = [self dr_associateValueForKey:_cmd];
    if (!targets) {
        targets = [NSMutableArray array];
        [self dr_setAssociateStrongValue:targets key:_cmd];
    }
    return targets;
}

@end
