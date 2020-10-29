//
//  UIImage+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/15.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (drbox)

/**
 根据gif二进制数据创建UIImage
 
 @discussion
 它的显示性能更好，但内存开销大，所以它只适合显示小gif，比如动画表情符号。
 
 @param data  GIF二进制数据
 @param scale  显示分辨率
 */
+ (nullable UIImage *)dr_imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;

/// 判断data是否是gif
+ (BOOL)dr_isAnimatedGIFData:(NSData *)data;

/// 判断path文件是否是gif
+ (BOOL)dr_isAnimatedGIFFile:(NSString *)path;

/// 将PDF转成UIImage，dataOrPath：NSData或者NSString filePath（只取pdf的第一页）
+ (nullable UIImage *)dr_imageWithPDF:(id)dataOrPath;

/**
 将PDF转成UIImage（只取pdf的第一页）
 
 @param dataOrPath NSData或者NSString filePath
 @param size 指定UIImage的大小
 */
+ (nullable UIImage *)dr_imageWithPDF:(id)dataOrPath size:(CGSize)size;

/**
 创建表情符图片
 
 @param emoji 表情符字符串，例如： @"😄".
 @param size 表情符的尺寸
 */
+ (nullable UIImage *)dr_imageWithEmoji:(NSString *)emoji size:(CGFloat)size;

/**
 Create and return a 1x1 point size image with the given color.
 
 @param color  The color.
 */
+ (nullable UIImage *)dr_imageWithColor:(UIColor *)color;

/**
 根据颜色和尺寸创建图片
 
 @param color  图片的颜色
 @param size   图片的尺寸
 */
+ (nullable UIImage *)dr_imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 自定义绘制一个图片
 
 @param size 指定图片的尺寸
 @param drawBlock 绘制图片的代码块
 */
+ (nullable UIImage *)dr_imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock;

/// 通过抽样缓存数据创建一个UIImage对象
+ (nullable UIImage *)dr_imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// 通过抽样缓存数据创建一个UIImage对象
+ (nullable UIImage *)dr_imageFromCVSampleBuffer:(CVImageBufferRef)sampleBuffer;

/// 判断当前图片是否存在透明通道
- (BOOL)dr_hasAlphaChannel;

/**
 绘制当前图片到图形上下文中
 
 @param rect  指定绘制的区域
 @param contentMode 内容填充模型
 @param clips 内容超出rect范围，是否裁剪
 */
- (void)dr_drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;

/// 获取指定尺寸的当前图片
- (nullable UIImage *)dr_imageByResizeToSize:(CGSize)size;

/**
 获取指定尺寸的当前图片
 
 @param size 图片的尺寸
 @param contentMode 内容填充模式
 */
- (nullable UIImage *)dr_imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

/**
 获取指定区域内的图片
 
 @param rect 当前图片的指定区域（如果超出当前图片的边界，忽略不计）
 */
- (nullable UIImage *)dr_imageByCropToRect:(CGRect)rect;

/**
 根据当前图片创建一个带边框的图片
 
 @param insets  四条边框的宽度
 @param color 边框的颜色
 */
- (nullable UIImage *)dr_imageByBorderEdge:(UIEdgeInsets)insets withColor:(nullable UIColor *)color;

/// 根据当前图片创建一个带圆角的图片
- (nullable UIImage *)dr_imageByRoundCornerRadius:(CGFloat)radius;

/**
 根据当前图片，创建一个圆角图片
 
 @param radius 圆角角度
 @param borderWidth  边框宽度
 @param borderColor 边框颜色
 */
- (nullable UIImage *)dr_imageByRoundCornerRadius:(CGFloat)radius
                                      borderWidth:(CGFloat)borderWidth
                                      borderColor:(nullable UIColor *)borderColor;

/**
 根据当前图片，创建一个圆角图片
 
 @param radius  圆角角度
 @param corners 指定哪些角采用圆角
 @param borderWidth 边框宽度
 @param borderColor 边框颜色
 @param borderLineJoin 边框线的样式
 */
- (nullable UIImage *)dr_imageByRoundCornerRadius:(CGFloat)radius
                                          corners:(UIRectCorner)corners
                                      borderWidth:(CGFloat)borderWidth
                                      borderColor:(nullable UIColor *)borderColor
                                   borderLineJoin:(CGLineJoin)borderLineJoin;

/**
 旋转当前图片的角度，创建一个新的图片
 
 @param radians  逆时针旋转弧度数
 @param fitSize  旋转后是否自适应尺寸
 */
- (nullable UIImage *)dr_imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;

/// 左旋转当前图片90度，创建一个新的图片（旋转后自适应图片尺寸）
- (nullable UIImage *)dr_imageByRotateLeft90;
/// 右旋转当前图片90度，创建一个新的图片（旋转后自适应图片尺寸）
- (nullable UIImage *)dr_imageByRotateRight90;

/// 获取当前图片反转180度后的图片
- (nullable UIImage *)dr_imageByRotate180;

/// 获取当前图片垂直翻转后的图片
- (nullable UIImage *)dr_imageByFlipVertical;

/// 获取当前图片水平翻转后的图片
- (nullable UIImage *)dr_imageByFlipHorizontal;

/**
 获取当前图片指定颜色的图片（将图片的颜色改变），关于图片draw时的blendMode参考：
 https://onevcat.com/2013/04/using-blending-in-ios/
 */
- (nullable UIImage *)dr_imageByTintColor:(UIColor *)color;

/// 获取当前图片的灰度图片
- (nullable UIImage *)dr_imageByGrayscale;

/// 获取当前图片的模糊效果（全模糊）
- (nullable UIImage *)dr_imageByBlurSoft;

/// 获取当前图片的模糊效果（适合模糊除纯白色以外的任何内容）
- (nullable UIImage *)dr_imageByBlurLight;

/// 获取当前图片的模糊效果（适合显示黑色文本）
- (nullable UIImage *)dr_imageByBlurExtraLight;

/// 获取当前图片的模糊效果（适合显示白色文本）
- (nullable UIImage *)dr_imageByBlurDark;

/// 获取当前图片的模糊效果（设置模糊色）
- (nullable UIImage *)dr_imageByBlurWithTint:(UIColor *)tintColor;

/**
 获取当前图片的模糊效果
 
 @param blurRadius 模糊半径，0表示没有模糊效果。
 @param tintColor 模糊着色颜色，alpha通道的颜色决定了颜色的强弱色彩
 @param tintBlendMode tintColor混合模式，默认：kCGBlendModeNormal
 @param saturation 等于1.0：不会对图像产生任何改变；
                    小于1.0：将导致图像的饱和度降低；
                    大于1.0：则会产生相反的效果。
                    等于0：代表灰度。
 @param maskImage 图像掩码，模糊效果会在这个掩码区域内生效
 */
- (nullable UIImage *)dr_imageByBlurRadius:(CGFloat)blurRadius
                                 tintColor:(nullable UIColor *)tintColor
                                  tintMode:(CGBlendMode)tintBlendMode
                                saturation:(CGFloat)saturation
                                 maskImage:(nullable UIImage *)maskImage;
/**
 在当前图片的上面覆盖一个图片
 
 @param image 当前图片上覆盖的图片
 @param insets image距离当前图片边缘的偏移量
 */
- (nullable UIImage *)dr_imageByCoverImage:(UIImage *)image
                                edgeInsets:(UIEdgeInsets)insets;

/// 当前图片所占内存
@property (nonatomic, readonly) NSUInteger dr_memoryCost;

@end

NS_ASSUME_NONNULL_END
