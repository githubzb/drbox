//
//  UIView+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/16.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRViewFrame : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

- (instancetype)initWithView:(UIView *)view;
- (void)setFrame;

@end

@interface UIView (drbox)

/**
 将当前视图坐标系中的point，转换成指定视图view或window坐标系中的point
 
 @param point 当前视图坐标系下的点坐标
 @param view 指定要转换坐标系的视图
 */
- (CGPoint)dr_convertPoint:(CGPoint)point toViewOrWindow:(nullable UIView *)view;
/**
 将给定view或window坐标系中的point，转换成当前视图坐标系中的point

 @param point 给定view或window坐标系下的点坐标
 @param view point所在坐标系的视图
*/
- (CGPoint)dr_convertPoint:(CGPoint)point fromViewOrWindow:(nullable UIView *)view;
/**
 将当前视图坐标系中的rect，转换成指定视图view或window坐标系中的rect
 
 @param rect 当前视图坐标系下的rect
 @param view 指定要转换坐标系的视图
 */
- (CGRect)dr_convertRect:(CGRect)rect toViewOrWindow:(nullable UIView *)view;
/**
 将给定view或window坐标系中的rect，转换成当前视图坐标系中的rect

 @param rect 给定view或window坐标系下的rect
 @param view rect所在坐标系的视图
*/
- (CGRect)dr_convertRect:(CGRect)rect fromViewOrWindow:(nullable UIView *)view;

/// 创建一个当前视图的截屏
- (nullable UIImage *)dr_snapshotImage;
/// 创建一个当前视图的截屏
- (nullable UIImage *)dr_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;
/// 创建当前视图的PDF快照
- (nullable NSData *)dr_snapshotPDF;

/**
 设置当前视图的阴影（采用光栅化实现）
 
 @param color 阴影的颜色
 @param offset 阴影偏移量
 @param radius 阴影角度
 */
- (void)dr_setLayerShadow:(nullable UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

- (void)dr_removeAllSubviews;

/// 获取当前视图所在的控制器
@property (nullable, nonatomic, readonly) UIViewController *dr_viewController;

/**
 获取当前视图的frame包装类（注意：修改这个类的frame值，不会立刻对当前视图生效，
 需要调用该类的setFrame完成当前视图frame的修改）
 */
@property (nonatomic, strong, readonly) DRViewFrame *dr_frame;

/// 添加tap手势（单手指点击一次）
- (void)dr_addClickOnceWithOneHand:(void(^)(UITapGestureRecognizer *tap))block;
/**
 添加tap手势，自定义其他参数
 
 @param numOfTaps 点击次数
 @param numOfTouches 触摸屏幕的点数
 @param block 回调
 */
- (void)dr_addClickNumberOfTapsRequired:(NSUInteger)numOfTaps
                numberOfTouchesRequired:(NSUInteger)numOfTouches
                              withBlock:(void(^)(UITapGestureRecognizer *tap))block;

@end

NS_ASSUME_NONNULL_END
