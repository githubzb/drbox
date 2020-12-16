//
//  DRModelProtocol.h
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DRModel <NSObject>

@optional
#pragma mark - 初始化
/// 初始化当前model，默认采用[NSObject new]
+ (instancetype)newModel;

#pragma mark - 字段或类映射
/**
 dictionary->model时容器类内部对应的数据类型映射
 
 @return {"list": CustomModel.class}，or {"list": "CustomModel"}
 */
+ (nullable NSDictionary<NSString *, id> *)toModelContainerInnerClassMapper;

/**
 model->dictionary时对应的key映射关系
 */
+ (nullable NSDictionary<NSString *, NSString *> *)toDictionaryKeyMapper;

/**
 dictionary->model时model成员变量或属性与字典key的映射
 
 @return {"_name": "user.name"} or {"name": ["user.name", "name", "user_name"]}
 */
+ (nullable NSDictionary<NSString *, id> *)toModelKeyMapper;

#pragma mark - 类型转换

/**
 日期转换（字符串转NSDate）
 */
+ (NSDate *)dateConvertFromString:(NSString *)string;

/**
 日期转换（NSTimeInterval转NSDate）
 */
+ (NSDate *)dateConvertFromTimeInterval:(NSTimeInterval)time;

/**
 NSData转换（字符串转NSData）
 */
+ (NSData *)dataConvertFromString:(NSString *)string;

/**
 NSURL转换（字符串转NSURL）
 */
+ (NSURL *)urlConvertFromString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
