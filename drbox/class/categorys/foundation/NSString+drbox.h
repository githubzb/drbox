//
//  NSString+drbox.h
//  drbox
//
//  Created by dr.box on 2020/7/20.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (drbox)

- (nullable NSData *)dr_utf8Data;
- (nullable NSString *)dr_md5String;
- (nullable NSString *)dr_sha224String;
- (nullable NSString *)dr_sha256String;
- (nullable NSString *)dr_sha384String;
- (nullable NSString *)dr_sha512String;
- (nullable NSString *)dr_crc32String;
- (nullable NSString *)dr_hmacSHA224StringWithKey:(NSString *)key;
- (nullable NSString *)dr_hmacSHA256StringWithKey:(NSString *)key;
- (nullable NSString *)dr_hmacSHA384StringWithKey:(NSString *)key;
- (nullable NSString *)dr_hmacSHA512StringWithKey:(NSString *)key;

/// base64编码
- (nullable NSString *)dr_base64EncodedString API_AVAILABLE(ios(7.0));
/// base64解码
- (nullable NSString *)dr_base64DecodedString  API_AVAILABLE(ios(7.0));

- (nullable NSURL *)dr_URL;
/// 返回URL参数
- (NSDictionary<NSString *, NSString *> *)dr_parameters;
/// 返回URL参数（value为URLDecoding之后的值）
- (NSDictionary<NSString *, NSString *> *)dr_parametersForURLDecoding;
/**
 URL编码（会对整个字符串编码）
 
 @discussion
 例如：https://www.baidu.com/ww/dd/头像.jpg =》https%3A//www.baidu.com/ww/dd/%E5%A4%B4%E5%83%8F.jpg
 */
- (NSString *)dr_urlEncodedString;
/**
 URL编码（仅对URL query部分编码，或者说对字符 ":" 不做编码）
 
 @discussion
 例如：https://www.baidu.com/ww/dd/头像.jpg =》https://www.baidu.com/ww/dd/%E5%A4%B4%E5%83%8F.jpg
 */
- (NSString *)dr_urlQueryEncodedString;

/// URL解码
- (NSString *)dr_urlDecodedString;
/// 将json字符串转成NSDictionary或NSArray
- (nullable id)dr_jsonObj;

/// 去掉字符串两端空格和换行符
- (NSString *)dr_trim;

/**
 计算字符串bound.size
 
 @param font 字体，如果为nil，默认按照系统12号字体就算
 @param size 字符串设定的尺寸范围
 
 @return 字符串在指定size范围内的合适的size
 */
- (CGSize)dr_sizeForFont:(nullable UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;
/**
 计算指定字体的字符串的宽度，lineBreakMode==NSLineBreakByWordWrapping
 
 @param font 字体，如果为nil，默认按照系统12号字体计算
 
 @return 全部字符串所占的bound.size.width
 */
- (CGFloat)dr_widthForFont:(nullable UIFont *)font;
/**
 计算指定字体，最大宽度的字符串换行后的高度
 
 @param font 字体，如果为nil，默认按照系统12号字体计算
 
 @return 字符串折行后的最大高度
 */
- (CGFloat)dr_heightForFont:(nullable UIFont *)font width:(CGFloat)width;
/**
 判断是否匹配正则表达式
 
 @param regex 正则表达式，例如验证邮箱：@"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"
 @param options 匹配规则可选项
 
 @return 该字符串被当前正则表达式匹配，返回YES，反之：NO
 */
- (BOOL)dr_matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options;

/**
 枚举匹配到的字符串
 
 @param regex 正则表达式
 @param options 匹配规则可选项
 @param block 遍历匹配到的字符串回调
 */
- (void)dr_enumerateRegexMatches:(NSString *)regex
                         options:(NSRegularExpressionOptions)options
                      usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block;

/**
 替换正则匹配到的字符串
 
 @param regex 正则表达式
 @param options  匹配规则可选项
 @param replacement 将要替换的字符串
 */
- (NSString *)dr_stringByReplacingRegex:(NSString *)regex
                                options:(NSRegularExpressionOptions)options
                             withString:(NSString *)replacement;

/// 生成36位的UUID字符串，例如：297B742E-64E0-4763-8B52-C8A8A243EF3C
+ (NSString *)dr_uuidString;

/**
 判断字符串是否包含字符串string
 
 @param string 包含的字符串
 
 @return 如果包含字符串string,返回YES，否则NO
 */
- (BOOL)dr_containsString:(NSString *)string;
/**
 判断字符串是否包含字符集set
 
 @param set 字符集
 
 @return 如果包含字符集set，返回YES，否则NO
 */
- (BOOL)dr_containsCharacterSet:(NSCharacterSet *)set;

/// 将字符串转成NSNumber对象，转失败返回nil
- (nullable NSNumber *)dr_numberValue;

/// 判断当前字符串是否为16进制
- (BOOL)dr_isHexString;

@end

NS_ASSUME_NONNULL_END
