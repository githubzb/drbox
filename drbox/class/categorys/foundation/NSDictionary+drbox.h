//
//  NSDictionary+drbox.h
//  drbox
//
//  Created by dr.box on 2020/7/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (drbox)

/**
 将plist文件数据转成dictionary对象
 
 @param plist plist文件数据
 
 @return 如果plist文件数据支持字典格式的，返回字典对象，否则：nil
 */
+ (nullable NSDictionary *)dr_dictionaryWithPlistData:(NSData *)plist;

/// 将字典转成plist文件格式数据
- (nullable NSData *)dr_plistData;

/// 将字典转成plist文件xml格式的字符串
- (nullable NSString *)dr_plistString;

/// 获取排序好的key数组，采用caseInsensitiveCompare:排序
- (NSArray<KeyType> *)dr_allKeysSorted;
/// 获取所有的value数组，其顺序是key排序后的顺序
- (NSArray<ObjectType> *)dr_allValuesSortedByKeys;
/// 判断字典中是否存在key
- (BOOL)dr_containsObjectForKey:(id)key;

/// 将字典转成json格式的字符串
- (nullable NSString *)dr_jsonString;
/// 将字典转成json格式的字符串（格式化后的）
- (nullable NSString *)dr_jsonPrettyString;

/// 过滤字典元素，返回字典中包含block返回YES的元素
- (NSDictionary *)dr_filter:(BOOL(^)(KeyType key, ObjectType value))block;
/// 通过指定函数处理字典的每个元素，并返回处理后的字典。
- (NSDictionary *)dr_map:(NSDictionary * _Nullable(^)(KeyType key, ObjectType value))block;
/// 返回通过测试（函数内判断）的字典的第一个元素的值。
- (nullable NSDictionary *)dr_find:(BOOL(^)(KeyType key, ObjectType value))block;

/**
 将xml数据转成dictionary对象
 
 @param xmlData xml文件二进制数据
 
 @return 如果是xml格式的数据，返回解析后的字典，反之，nil
 */
+ (nullable NSDictionary *)dr_dictionaryWithXMLData:(NSData *)xmlData;

/**
 将xml字符串转成dictionary对象
 
 @param xmlString xml格式的字符串
 
 @return 如果是xml格式的数据，返回解析后的字典，反之，nil
 */
+ (nullable NSDictionary *)dr_dictionaryWithXMLString:(NSString *)xmlString;

/**
 将xml文件转成dictionary对象
 
 @param xmlFilePath xml文件绝对路径
 
 @return 如果是xml格式的数据，返回解析后的字典，反之，nil
 */
+ (nullable NSDictionary *)dr_dictionaryWithXMLFile:(NSString *)xmlFilePath;

@end

NS_ASSUME_NONNULL_END
