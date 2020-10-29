//
//  NSArray+drbox.h
//  drbox
//
//  Created by dr.box on 2020/7/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (drbox)

/**
 将plist文件数据转成数组
 
 @param plist plist文件数据
 
 @return 如果plist是一个数组格式，那么返回对应的数组对象，反之，nil
 */
+ (nullable NSArray *)dr_arrayWithPlistData:(NSData *)plist;

/// 将array转成plist文件数据
- (nullable NSData *)dr_plistData;
/// 将array转成plist格式的xml字符串
- (nullable NSString *)dr_plistString;

/// 随机的获取数组中的对象
- (nullable ObjectType)dr_randomObject;

/// 获取数组下标的对象，如果下标越界，返回nil
- (nullable ObjectType)dr_objectAtIndex:(NSUInteger)index;

/// 将数组转成json格式的字符串
- (nullable NSString *)dr_jsonString;
/// 将数组转成json格式的字符串（格式化后的）
- (nullable NSString *)dr_jsonPrettyString;


@end

@interface NSMutableArray<ObjectType>  (drbox)

/**
 将plist文件数据转成NSMutableArray对象
 
 @param plist plist文件数据
 
 @return 如果plist是一个数组格式，那么返回对应的数组对象，反之，nil
 */
+ (nullable NSMutableArray *)dr_arrayWithPlistData:(NSData *)plist;

/// 删除数组中第一个元素
- (void)dr_removeFirstObject;

/// 删除数组中第一个元素，并返回被删除的元素
- (nullable ObjectType)dr_popFirstObject;
/// 删除数组中最后一个元素，并返回被删除的元素
- (nullable ObjectType)dr_popLastObject;

/// 反转数组中的元素，例如：之前的数组：【1、2、3】；之后的数组：【3，2，1】
- (void)dr_reverse;
/// 随机打乱数组中的元素，对数组中的元素重新洗牌
- (void)dr_shuffle;

@end

NS_ASSUME_NONNULL_END
