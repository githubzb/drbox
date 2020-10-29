//
//  DRLayout+private.h
//  drbox
//
//  Created by dr.box on 2020/7/24.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRLayout (private)

/**
 构建view层级的节点链
 
 @param view 应用drlayout布局视图中的根视图
 */
- (void)attachNodesFromViewHierachy:(UIView *)view;
/**
 计算布局视图的尺寸
 
 @param size 视图布局的边界尺寸
 
 @return 计算后视图的尺寸
 */
- (CGSize)calculateLayoutWithSize:(CGSize)size;

/**
 应用布局
 
 @param preserveOrigin 是否保留根视图的原点坐标
 */
- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin;

@end

NS_ASSUME_NONNULL_END
