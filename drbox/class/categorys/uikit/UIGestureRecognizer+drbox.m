//
//  UIGestureRecognizer+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/30.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UIGestureRecognizer+drbox.h"
#import "NSObject+drbox.h"

@interface _DRGestureRecognizerBlockTarget : NSObject{
    NSMutableArray *_blocks;
}

- (id)initWithBlock:(DRGestureRecognizerBlock)block;
- (void)addBlock:(DRGestureRecognizerBlock)block;
- (void)invoke:(id)sender;

@end

@implementation _DRGestureRecognizerBlockTarget

- (instancetype)init{
    self = [super init];
    if (self) {
        _blocks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithBlock:(DRGestureRecognizerBlock)block{
    self = [self init];
    if (self) {
        [_blocks addObject:block];
    }
    return self;
}

- (void)addBlock:(DRGestureRecognizerBlock)block{
    [_blocks addObject:block];
}

- (void)invoke:(id)sender {
    for (DRGestureRecognizerBlock block in _blocks) {
        block(sender);
    }
}

@end

@implementation UIGestureRecognizer (drbox)

- (void)dr_addActionBlock:(DRGestureRecognizerBlock)block{
    if (!block) return;
    _DRGestureRecognizerBlockTarget *target = [self blockTarget];
    if (target) {
        [target addBlock:block];
    }else{
        target = [[_DRGestureRecognizerBlockTarget alloc] initWithBlock:block];
        [self addTarget:target action:@selector(invoke:)];
        [self setBlockTarget:target];
    }
}

- (void)dr_removeAllActionBlocks{
    _DRGestureRecognizerBlockTarget *target = [self blockTarget];
    if (target) {
        [self removeTarget:target action:@selector(invoke:)];
        [self setBlockTarget:nil];
    }
}


#pragma mark - private
- (_DRGestureRecognizerBlockTarget *)blockTarget{
    return [self dr_associateValueForKey:_cmd];
}
- (void)setBlockTarget:(_DRGestureRecognizerBlockTarget *)target{
    [self dr_setAssociateStrongValue:target key:@selector(blockTarget)];
}

@end
