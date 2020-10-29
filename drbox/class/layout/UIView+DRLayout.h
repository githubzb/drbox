//
//  UIView+DRLayout.h
//  drbox
//
//  Created by dr.box on 2020/7/24.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRLayout.h"
#import "DRLayoutTransaction.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DRLayoutConfigurationBlock)(DRLayout *layout);
typedef void (^DRLayoutFinishBlock)(__kindof UIView *view);
typedef void (^DRCalculateLayoutBlock)(CGSize size);

@interface UIView (DRLayout)

/**
 懒加载的DRLayout布局对象
 */
@property (nonatomic, readonly, strong) DRLayout *dr_layout;
/**
 标记UIView是否可以使用DRLayout布局（即：layout已初始化）
 */
@property (nonatomic, readonly, assign) BOOL dr_isLayoutEnabled;
/**
 视图布局完成的回调block
 */
@property (nonatomic, copy) DRLayoutFinishBlock dr_layoutFinishBlock;

/**
 设置布局属性，此时dr_layout.isEnabled=YES
 */
- (void)dr_makeLayoutWithBlock:(DRLayoutConfigurationBlock)block;
/**
 根据当前视图的层级关系，构建YGNodeRef关系链
 */
- (void)dr_setUpLayout;

#pragma mark - 计算布局尺寸

/**
 计算视图布局的尺寸（根视图边界为自身的尺寸）
 
 @return 根据视图层级节点关系，计算出的视图尺寸
 */
- (CGSize)dr_calculateLayout;
/**
 计算视图布局的尺寸
 
 @param sizeFlexibility 根视图边界的自适应方式，例如：DRSizeFlexibilityWidth（宽度无边界）
 
 @return 根据视图层级节点关系，计算出的视图尺寸
 */
- (CGSize)dr_calculateLayoutWithSizeFlexibility:(DRSizeFlexibility)sizeFlexibility;

#pragma mark - 应用布局尺寸

/**
 应用布局，根据计算出来的尺寸，对视图进行布局（当前视图不保留原点坐标）
 */
- (void)dr_applyLayout;
/**
 应用布局，根据计算出来的尺寸，对视图进行布局
 
 @param preserveOrigin 布局根视图时，是否保留当前视图的原点坐标
 */
- (void)dr_applyLayoutPreservingOrigin:(BOOL)preserveOrigin;

#pragma mark - 计算并应用布局

/**
 计算并应用布局（同步计算布局，不保留当前视图原点坐标，边界尺寸为自身尺寸）
 */
- (void)dr_displayLayout;

/**
 计算并应用布局（同步计算布局，边界尺寸为自身尺寸）
 
 @param preservOrigin  布局根视图时，是否保留当前视图的原点坐标
 */
- (void)dr_displayLayoutPreservingOrigin:(BOOL)preservOrigin;

/**
 计算并应用布局（同步计算布局）
 
 @param preservOrigin 布局根视图时，是否保留当前视图的原点坐标
 @param sizeFlexibility  根视图边界的自适应方式，例如：DRSizeFlexibilityWidth（宽度无边界）
 */
- (void)dr_displayLayoutPreservingOrigin:(BOOL)preservOrigin
                         sizeFlexibility:(DRSizeFlexibility)sizeFlexibility;

/**
 计算并应用布局（异步计算布局，不保留当前视图原点坐标，边界尺寸为自身尺寸）
 */
- (void)dr_asyncDisplayLayout;

/**
计算并应用布局（异步计算布局，边界尺寸为自身尺寸）

@param preservOrigin  布局根视图时，是否保留当前视图的原点坐标
*/
- (void)dr_asyncDisplayLayoutPreservingOrigin:(BOOL)preservOrigin;

/**
 计算并应用布局（异步计算布局）
 
 @param preservOrigin 布局根视图时，是否保留当前视图的原点坐标
 @param sizeFlexibility  根视图边界的自适应方式，例如：DRSizeFlexibilityWidth（宽度无边界）
 */
- (void)dr_asyncDisplayLayoutPreservingOrigin:(BOOL)preservOrigin
                              sizeFlexibility:(DRSizeFlexibility)sizeFlexibility;;


@end

NS_ASSUME_NONNULL_END
