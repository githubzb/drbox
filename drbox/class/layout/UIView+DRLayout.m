//
//  UIView+DRLayout.m
//  drbox
//
//  Created by dr.box on 2020/7/24.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UIView+DRLayout.h"
#import "NSObject+drbox.h"
#import "DRLayout+private.h"

@implementation UIView (DRLayout)

- (DRLayout *)dr_layout {
    DRLayout *layout = [self dr_associateValueForKey:@selector(dr_layout)];
    if (!layout) {
        layout = [[DRLayout alloc] initWithView:self];
        [self dr_setAssociateStrongValue:layout key:@selector(dr_layout)];
    }
    return layout;
}

- (BOOL)dr_isLayoutEnabled {
    return [self dr_associateValueForKey:@selector(dr_layout)] != nil;
}

- (void)setDr_layoutFinishBlock:(DRLayoutFinishBlock)dr_layoutFinishBlock{
    [self dr_setAssociateCopyValue:dr_layoutFinishBlock key:@selector(dr_layoutFinishBlock)];
}

- (DRLayoutFinishBlock)dr_layoutFinishBlock{
    return [self dr_associateValueForKey:@selector(dr_layoutFinishBlock)];
}


- (void)dr_makeLayoutWithBlock:(DRLayoutConfigurationBlock)block {
    if (block != nil) {
        self.dr_layout.isEnabled = YES;
        block(self.dr_layout);
    }
}

- (void)dr_setUpLayout{
    [self.dr_layout attachNodesFromViewHierachy:self];
}

- (CGSize)dr_calculateLayout{
    return [self.dr_layout calculateLayoutWithSize:self.bounds.size];
}

- (CGSize)dr_calculateLayoutWithSizeFlexibility:(DRSizeFlexibility)sizeFlexibility{
    CGSize size = self.bounds.size;
    if (sizeFlexibility & DRSizeFlexibilityWidth) {
        size.width = YGUndefined; // 宽度无边界
    }
    if (sizeFlexibility & DRSizeFlexibilityHeight) {
        size.height = YGUndefined; // 高度无边界
    }
    return [self.dr_layout calculateLayoutWithSize:size];
}

- (void)dr_applyLayout{
    [self.dr_layout applyLayoutPreservingOrigin:NO];
}

- (void)dr_applyLayoutPreservingOrigin:(BOOL)preserveOrigin{
    [self.dr_layout applyLayoutPreservingOrigin:preserveOrigin];
}

- (void)dr_displayLayout{
    // 根据当前视图的层级关系，构建布局节点链
    [self dr_setUpLayout];
    // 计算布局
    [self dr_calculateLayout];
    // 应用布局
    [self dr_applyLayout];
}

- (void)dr_displayLayoutPreservingOrigin:(BOOL)preservOrigin{
    // 根据当前视图的层级关系，构建布局节点链
    [self dr_setUpLayout];
    // 计算布局
    [self dr_calculateLayout];
    // 应用布局
    [self dr_applyLayoutPreservingOrigin:preservOrigin];
}

- (void)dr_displayLayoutPreservingOrigin:(BOOL)preservOrigin
                         sizeFlexibility:(DRSizeFlexibility)sizeFlexibility{
    // 根据当前视图的层级关系，构建布局节点链
    [self dr_setUpLayout];
    // 计算布局
    [self dr_calculateLayoutWithSizeFlexibility:sizeFlexibility];
    // 应用布局
    [self dr_applyLayoutPreservingOrigin:preservOrigin];
}

- (void)dr_asyncDisplayLayout{
    // 根据当前视图的层级关系，构建布局节点链
    [self dr_setUpLayout];
    CGSize size = self.bounds.size;
    [DRLayoutTransaction addTransaction:^{
        // 计算布局
        [self.dr_layout calculateLayoutWithSize:size];
    } complete:^{
        // 应用布局
        [self dr_applyLayout];
    }];
}

- (void)dr_asyncDisplayLayoutPreservingOrigin:(BOOL)preservOrigin{
    // 根据当前视图的层级关系，构建布局节点链
    [self dr_setUpLayout];
    CGSize size = self.bounds.size;
    [DRLayoutTransaction addTransaction:^{
        // 计算布局
        [self.dr_layout calculateLayoutWithSize:size];
    } complete:^{
        // 应用布局
        [self dr_applyLayoutPreservingOrigin:preservOrigin];
    }];
}

- (void)dr_asyncDisplayLayoutPreservingOrigin:(BOOL)preservOrigin
                              sizeFlexibility:(DRSizeFlexibility)sizeFlexibility{
    // 根据当前视图的层级关系，构建布局节点链
    [self dr_setUpLayout];
    CGSize size = self.bounds.size;
    if (sizeFlexibility & DRSizeFlexibilityWidth) {
        size.width = YGUndefined; // 宽度无边界
    }
    if (sizeFlexibility & DRSizeFlexibilityHeight) {
        size.height = YGUndefined; // 高度无边界
    }
    [DRLayoutTransaction addTransaction:^{
        // 计算布局
        [self.dr_layout calculateLayoutWithSize:size];
    } complete:^{
        // 应用布局
        [self dr_applyLayoutPreservingOrigin:preservOrigin];
    }];
}

@end
