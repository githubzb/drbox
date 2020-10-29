//
//  UIColor+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/15.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// rgb 转 hsl
extern void DR_RGB2HSL(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *h, CGFloat *s, CGFloat *l);

/// hsl 转 rgb
extern void DR_HSL2RGB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *r, CGFloat *g, CGFloat *b);

/// rgb 转 hsb
extern void DR_RGB2HSB(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *hh, CGFloat *ss, CGFloat *bb);

/// hsb 转 rgb
extern void DR_HSB2RGB(CGFloat hh, CGFloat ss, CGFloat bb,
                       CGFloat *r, CGFloat *g, CGFloat *b);

/// rgb 转 cmyk
extern void DR_RGB2CMYK(CGFloat r, CGFloat g, CGFloat b,
                        CGFloat *c, CGFloat *m, CGFloat *y, CGFloat *k);

/// cmyk 转 rgb
extern void DR_CMYK2RGB(CGFloat c, CGFloat m, CGFloat y, CGFloat k,
                        CGFloat *r, CGFloat *g, CGFloat *b);

/// hsb 转 hsl
extern void DR_HSB2HSL(CGFloat h, CGFloat s, CGFloat b,
                       CGFloat *hh, CGFloat *ss, CGFloat *ll);

/// hsl 转 hsb
extern void DR_HSL2HSB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *hh, CGFloat *ss, CGFloat *bb);

#define DRColorFromHex(hex) [UIColor dr_colorWithHexString:((__bridge NSString *)CFSTR(#hex))]

@interface UIColor (drbox)

/**
 创建UIColor（RGB色彩模型）

 @param hue 色调：[0-1]
 @param saturation 色饱和度：[0-1]
 @param lightness  亮度：[0-1]
 @param alpha 透明度：[0-1]
 */
+ (UIColor *)dr_colorWithHue:(CGFloat)hue
                  saturation:(CGFloat)saturation
                   lightness:(CGFloat)lightness
                       alpha:(CGFloat)alpha;

/**
 创建UIColor（印刷四色模式）
 
 @param cyan 青色：[0-1]
 @param magenta 品红色：[0-1]
 @param yellow  黄色：[0-1]
 @param black  黑色：[0-1]
 @param alpha  透明度：[0-1]
 */
+ (UIColor *)dr_colorWithCyan:(CGFloat)cyan
                      magenta:(CGFloat)magenta
                       yellow:(CGFloat)yellow
                        black:(CGFloat)black
                        alpha:(CGFloat)alpha;

/**
 创建UIColor
 
 @param rgbValue  rgb 16进制的值，例如：0x66ccff
 */
+ (UIColor *)dr_colorWithRGB:(uint32_t)rgbValue;

/**
 创建UIColor
 
 @param rgbaValue  rgba 16进制的值，例如：0x66ccffff
 */
+ (UIColor *)dr_colorWithRGBA:(uint32_t)rgbaValue;

/**
 创建UIColor
 
 @param rgbValue  rgb 16进制的值，例如：0x66ccff
 @param alpha  透明度：[0-1]
 */
+ (UIColor *)dr_colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;

/**
 创建UIColor
 
 @discussion
 有效格式： #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 其中：#和0x不是必须的
 例如：@"0xF0F", @"66ccff", @"#66CCFF88"
 
 @param hexStr  hex字符串的值
 */
+ (nullable UIColor *)dr_colorWithHexString:(NSString *)hexStr;

/**
 混合颜色
 
 @param add 混合颜色
 @param blendMode 混合模式
 */
- (UIColor *)dr_colorByAddColor:(UIColor *)add blendMode:(CGBlendMode)blendMode;

/**
 改变当前颜色的hsba值
 
 @param hueDelta  色调：[-1-1]，0：表示没有变化
 @param saturationDelta  饱和度：[-1-1]，0：表示没有变化
 @param brightnessDelta  亮度：[-1-1]，0：表示没有变化
 @param alphaDelta  透明度：[-1-1]，0：表示没有变化
 */
- (UIColor *)dr_colorByChangeHue:(CGFloat)hueDelta
                      saturation:(CGFloat)saturationDelta
                      brightness:(CGFloat)brightnessDelta
                           alpha:(CGFloat)alphaDelta;


#pragma mark - Get color's description
///=============================================================================
/// @name Get color's description
///=============================================================================

/**
 获取颜色的rgb 16进制值
 
 @return 16进制表示，例如：0x66ccff
 */
- (uint32_t)dr_rgbValue;

/**
 获取颜色的rgba 16进制值
 
 @return 16进制表示，例如： 0x66ccffff
 */
- (uint32_t)dr_rgbaValue;

/// 获取颜色的16进制字符串表示值
- (nullable NSString *)dr_hexString;

/// 获取颜色的16进制字符串表示值，带透明度
- (nullable NSString *)dr_hexStringWithAlpha;

/**
 获取当前颜色的hsla值
 
 @param hue 色调指针（用于存储色调的值）
 @param saturation 饱和度指针（用于存储饱和度值）
 @param lightness  亮度指针（用于存储亮度值）
 @param alpha 透明度指针（用于存储透明度）
 
 @return YES：获取成功
 */
- (BOOL)dr_getHue:(CGFloat *)hue
       saturation:(CGFloat *)saturation
        lightness:(CGFloat *)lightness
            alpha:(CGFloat *)alpha;

/**
 获取当前颜色的cmyka的值（k：blac K）
 
 @param cyan 青色指针（用于存储青色值）
 @param magenta 品红色指针（用于存储品红色值）
 @param yellow 黄色指针（用于存储黄色值）
 @param black 黑色指针（用于存储黑色值）
 @param alpha 透明度指针（用于存储透明度值）
 
 @return YES：获取成功
 */
- (BOOL)dr_getCyan:(CGFloat *)cyan
           magenta:(CGFloat *)magenta
            yellow:(CGFloat *)yellow
             black:(CGFloat *)black
             alpha:(CGFloat *)alpha;

/// 颜色rgb中的r值：[0-1]
@property (nonatomic, readonly) CGFloat dr_red;

/// 颜色rgb中的g值：[0-1]
@property (nonatomic, readonly) CGFloat dr_green;

/// 颜色rgb中的b值：[0-1]
@property (nonatomic, readonly) CGFloat dr_blue;

/// 颜色的色调值：[0-1]
@property (nonatomic, readonly) CGFloat dr_hue;

/// 颜色的饱和度值：[0-1]
@property (nonatomic, readonly) CGFloat dr_saturation;

/// 颜色的亮度值：[0-1]
@property (nonatomic, readonly) CGFloat dr_brightness;

/// 颜色的透明度值：[0-1]
@property (nonatomic, readonly) CGFloat dr_alpha;

/// 获取当前颜色的色彩空间模式
@property (nonatomic, readonly) CGColorSpaceModel dr_colorSpaceModel;

/// 获取当前颜色的色彩空间模式的字符串表示
@property (nullable, nonatomic, readonly) NSString *dr_colorSpaceString;

@end

NS_ASSUME_NONNULL_END
