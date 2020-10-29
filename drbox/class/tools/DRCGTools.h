//
//  DRCGTools.h
//  drbox
//
//  Created by dr.box on 2020/8/16.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DrboxCommonMacro.h"

DR_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

/**
 创建ARGB Bitmap context
 
 @param size 画布context的尺寸
 @param opaque 是否透明，YES：不透明
 @param scale 分辨率
 */
CGContextRef _Nullable DRCGContextCreateARGBBitmapContext(CGSize size, BOOL opaque, CGFloat scale);

/**
 创建灰度Bitmap context
 
 @param size 画布context的尺寸
 @param scale 分辨率
 */
CGContextRef _Nullable DRCGContextCreateGrayBitmapContext(CGSize size, CGFloat scale);

/// 角度 转 弧度
static inline CGFloat DRDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

/// 弧度 转 角度
static inline CGFloat DRRadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

/// 获取transform的旋转的 弧度数（通过CGAffineTransformMakeRotation(弧度)进行旋转的弧度）
static inline CGFloat DRCGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

/// 获取缩放的x值（通过CGAffineTransformMakeScale（x，y）缩放的x值）
static inline CGFloat DRCGAffineTransformGetScaleX(CGAffineTransform transform) {
    return  sqrt(transform.a * transform.a + transform.c * transform.c);
}

/// 获取缩放的y值（通过CGAffineTransformMakeScale（x，y）缩放的y值）
static inline CGFloat DRCGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

/// 获取平移的x值（通过CGAffineTransformMakeTranslation（x，y）平移的x值）
static inline CGFloat DRCGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

/// 获取平移的y值（通过CGAffineTransformMakeTranslation（x，y）平移的y值）
static inline CGFloat DRCGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

/**
 see：
 http://stackoverflow.com/questions/13291796/calculate-values-for-a-cgaffinetransform-from-three-points-in-each-of-two-uiview
 */
CGAffineTransform DRCGAffineTransformGetFromPoints(CGPoint before[_Nonnull 3], CGPoint after[_Nonnull 3]);
/// 获取两个视图，从from视图到to视图的仿射变换
CGAffineTransform DRCGAffineTransformGetFromViews(UIView *from, UIView *to);

/**
 创建一个倾斜的仿射变换
 
 @param x 沿x轴倾斜的距离
 @param y 沿y轴倾斜的距离
 */
static inline CGAffineTransform DRCGAffineTransformMakeSkew(CGFloat x, CGFloat y){
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.c = -x;
    transform.b = y;
    return transform;
}

/// 将layer的contentsGravity，转成UIViewContentMode枚举
UIViewContentMode DRCAGravityToUIViewContentMode(NSString *gravity);
/// 将UIViewContentMode枚举 转成 layer的contentsGravity
NSString *DRUIViewContentModeToCAGravity(UIViewContentMode contentMode);

/**
 获取根据UIViewContentMode计算出的rect
 
 @param rect 指定mode相对的矩形区域
 @param size content的尺寸
 @param mode content的mode
 */
CGRect DRCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

/// 获取rect矩形的中心点坐标
static inline CGPoint DRCGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// 获取rect矩形框的面积
static inline CGFloat DRCGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// 获取两点之间的距离
static inline CGFloat DRCGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/// 获取insets的绝对值
static inline UIEdgeInsets DREdgeInsetsABS(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(fabs(insets.top), fabs(insets.left), fabs(insets.bottom), fabs(insets.right));
}


NS_ASSUME_NONNULL_END

DR_EXTERN_C_END
