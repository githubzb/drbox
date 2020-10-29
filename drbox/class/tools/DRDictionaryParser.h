//
//  DRDictionaryParser.h
//  drbox
//
//  Created by dr.box on 2020/7/23.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DRXMLAttributesMode) {
    /// xml属性名前增加“_”前缀
    DRXMLAttributesModePrefixed = 0,
    /// xml属性存储在节点字典中的以“__attributes”为key，的字典里
    DRXMLAttributesModeDictionary,
    /// xml属性名前不添加"_"前缀
    DRXMLAttributesModeUnprefixed,
    /// 忽略xml属性，不存储
    DRXMLAttributesModeDiscard
};


typedef NS_ENUM(NSInteger, DRXMLNodeNameMode) {
    /// 仅仅xml的根节点的名称以__name为key，存储在当前节点中
    DRXMLNodeNameModeRootOnly = 0,
    /// 所有xml节点的名称都以__name为key，存储在当前节点中
    DRXMLNodeNameModeAlways,
    /// 从不存储xml节点名称
    DRXMLNodeNameModeNever
};

@interface DRDictionaryParser : NSObject

/// 是否折叠xml中的文本标示方法，NO：会将文本包装一层{'__text'：textValue}；YES：直接表示文本，默认：YES
@property (nonatomic, assign) BOOL collapseTextNodes;
/// 是否跳过空文本节点，默认：YES
@property (nonatomic, assign) BOOL stripEmptyNodes;
/// 是否截取掉xml内容文本的两端空格或换行，默认：YES
@property (nonatomic, assign) BOOL trimWhiteSpace;
/// 子节点属性或元素是否采用数组包装，默认：NO
@property (nonatomic, assign) BOOL alwaysUseArrays;
/// 是否保留xml注释，默认：NO
@property (nonatomic, assign) BOOL preserveComments;
/// 是否用根节点的名称，包装根节点，默认：NO；例如：YES：{rootNodeName：{root字典}}；NO：{root字典}
@property (nonatomic, assign) BOOL wrapRootNode;

/// 处理xml属性的方式，默认：DRXMLAttributesModeUnprefixed
@property (nonatomic, assign) DRXMLAttributesMode attributesMode;
/// 处理xml节点名称的方式，默认：DRXMLNodeNameModeNever
@property (nonatomic, assign) DRXMLNodeNameMode nodeNameMode;

+ (nullable NSDictionary<NSString *, id> *)dictionaryWithParser:(NSXMLParser *)parser;
+ (nullable NSDictionary<NSString *, id> *)dictionaryWithData:(NSData *)data;
+ (nullable NSDictionary<NSString *, id> *)dictionaryWithString:(NSString *)string;
+ (nullable NSDictionary<NSString *, id> *)dictionaryWithFile:(NSString *)path;

/**
 根据NSXMLParser对象，解析xml
 
 @param parser NSXMLParser
 
 @return 解析成功，返回xml对应的字典格式，反之，nil
 */
- (nullable NSDictionary<NSString *, id> *)dictionaryWithParser:(NSXMLParser *)parser;
/**
 根据xml文件二进制数据，解析xml

 @param data xml二进制数据

 @return 解析成功，返回xml对应的字典格式，反之，nil
*/
- (nullable NSDictionary<NSString *, id> *)dictionaryWithData:(NSData *)data;
/**
 根据xml结构的字符串，解析xml

 @param string xml字符串

 @return 解析成功，返回xml对应的字典格式，反之，nil
*/
- (nullable NSDictionary<NSString *, id> *)dictionaryWithString:(NSString *)string;
/**
 根据xml文件所在路径，解析xml

 @param path xml文件路径

 @return 解析成功，返回xml对应的字典格式，反之，nil
*/
- (nullable NSDictionary<NSString *, id> *)dictionaryWithFile:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
