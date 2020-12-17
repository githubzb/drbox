//
//  NSObject+DRModel.h
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DRModel)

/**
 根据json对象初始化model
 
 @param json NSDictionary、NSData、NSString
 */
+ (nullable instancetype)dr_modelWithJSON:(id)json;

/// 根据字典初始化model
+ (nullable instancetype)dr_modelWithDictionary:(NSDictionary *)dic;

/**
 根据json为当前实例成员变量赋值
 
 @param json NSDictionary、NSData、NSString
 */
- (BOOL)dr_modelSetWithJSON:(id)json;

/// 根据dic为当前实例成员变量赋值
- (BOOL)dr_modelSetWithDictionary:(NSDictionary *)dic;

/// model -> NSDictionary or NSArray
- (nullable id)dr_modelToJSONObject;

/// model -> Json Data
- (nullable NSData *)dr_modelToJSONData;

/// model -> Json string
- (nullable NSString *)dr_modelToJSONString;

/// 如果当前对象实现了NSCopying协议，直接采用copy返回，反之遍历成员变量一一赋值
- (instancetype)dr_copy;

/// model 归档
- (void)dr_modelEncodeWithCoder:(NSCoder *)aCoder;

/// model 解档
- (instancetype)dr_modelInitWithCoder:(NSCoder *)aDecoder;

/// 安全调用，不会crash
- (void)dr_setValue:(nullable id)value forKey:(NSString *)key;
/// 安全调用，不会crash
- (void)dr_setValue:(nullable id)value forKeyPath:(NSString *)keyPath;
/// 安全调用，不会crash
- (id)dr_valueForKey:(NSString *)key;
/// 安全调用，不会crash
- (id)dr_valueForKeyPath:(NSString *)keyPath;

@end


@interface NSArray (DRModel)

+ (nullable NSArray *)dr_modelArrayWithClass:(Class)cls json:(id)json;

+ (nullable NSArray *)dr_modelArrayWithClass:(Class)cls array:(NSArray *)arr;

@end


@interface NSDictionary (DRModel)

+ (nullable NSDictionary *)dr_modelDictionaryWithClass:(Class)cls json:(id)json;

+ (nullable NSDictionary *)dr_modelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dic;

@end


NS_ASSUME_NONNULL_END
