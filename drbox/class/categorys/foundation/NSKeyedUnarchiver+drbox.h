//
//  NSKeyedUnarchiver+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/13.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (drbox)

/**
 文件解档（兼容ios11之前的方法调用）
 
 @param cls 解档后的类对象
 @param data 归档二进制数据
 @param error 错误指针，用于获取错误信息
 
 @return 解档后的类对象
 */
+ (nullable id)dr_unarchivedObjectOfClass:(Class)cls
                                 fromData:(NSData *)data
                                    error:(NSError *_Nullable *_Nullable)error;

/**
 文件解档（兼容ios11之前的方法调用）

 @param cls 解档后的类对象
 @param path 归档二进制数据的文件绝对路径
 @param error 错误指针，用于获取错误信息

 @return 解档后的类对象
*/
+ (nullable id)dr_unarchiveObjectOfClass:(Class)cls
                            withFilePath:(NSString *)path
                                   error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
