//
//  UIBarButtonItem+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/30.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UIBarButtonItem+drbox.h"
#import "NSObject+drbox.h"

@interface _DRBarButtonItemBlockTarget : NSObject

@property (nonatomic, copy) DRBarButtonItemBlock block;

- (id)initWithBlock:(DRBarButtonItemBlock)block;
- (void)invoke:(id)sender;

@end

@implementation _DRBarButtonItemBlockTarget

- (id)initWithBlock:(DRBarButtonItemBlock)block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) self.block(sender);
}

@end

@implementation UIBarButtonItem (drbox)

+ (instancetype)dr_itemWithTitle:(NSString *)title
                           style:(UIBarButtonItemStyle)style
                           block:(DRBarButtonItemBlock)block{
    _DRBarButtonItemBlockTarget *target = [[_DRBarButtonItemBlockTarget alloc] initWithBlock:block];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                             style:style
                                                            target:target
                                                            action:@selector(invoke:)];
    [item dr_setAssociateStrongValue:target key:@selector(actionBlock)];
    return item;
}

+ (instancetype)dr_itemWithImage:(UIImage *)image
                           style:(UIBarButtonItemStyle)style
                           block:(DRBarButtonItemBlock)block{
    _DRBarButtonItemBlockTarget *target = [[_DRBarButtonItemBlockTarget alloc] initWithBlock:block];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image
                                                             style:style
                                                            target:target
                                                            action:@selector(invoke:)];
    [item dr_setAssociateStrongValue:target key:@selector(actionBlock)];
    return item;
}

+ (instancetype)dr_itemWithImage:(UIImage *)image
             landscapeImagePhone:(UIImage *)landscapeImagePhone
                           style:(UIBarButtonItemStyle)style
                           block:(DRBarButtonItemBlock)block{
    _DRBarButtonItemBlockTarget *target = [[_DRBarButtonItemBlockTarget alloc] initWithBlock:block];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image
                                               landscapeImagePhone:landscapeImagePhone
                                                             style:style
                                                            target:target
                                                            action:@selector(invoke:)];
    [item dr_setAssociateStrongValue:target key:@selector(actionBlock)];
    return item;
}

- (void)setActionBlock:(DRBarButtonItemBlock)actionBlock{
    _DRBarButtonItemBlockTarget *target = [self dr_associateValueForKey:@selector(actionBlock)];
    if (actionBlock) {
        target.block = actionBlock;
    }else{
        target = [[_DRBarButtonItemBlockTarget alloc] initWithBlock:actionBlock];
        self.target = target;
        self.action = @selector(invoke:);
        [self dr_setAssociateStrongValue:target key:@selector(actionBlock)];
    }
}

- (DRBarButtonItemBlock)actionBlock{
    _DRBarButtonItemBlockTarget *target = [self dr_associateValueForKey:_cmd];
    return target.block;
}

@end
