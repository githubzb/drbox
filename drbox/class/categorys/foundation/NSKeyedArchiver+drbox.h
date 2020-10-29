//
//  NSKeyedArchiver+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/13.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedArchiver (drbox)

/**
 归档类对象（兼容ios11之前的方法调用）
 
 @param rootObject 归档的类对象
 @param error 错误指针，用于获取错误信息
 
 @return 归档成功，返回data，反之，return nil
 */
+ (nullable NSData *)dr_archivedDataWithRootObject:(id)rootObject
                                             error:(__autoreleasing NSError **)error;

/**
 归档类对象（兼容ios11之前的方法调用）

 @param rootObject 归档的类对象
 @param path 保存归档数据的绝对路径
 @param error 错误指针，用于获取错误信息

 @return YES：成功
*/
+ (BOOL)dr_archiveRootObject:(id)rootObject
                      toFile:(NSString *)path
                       error:(__autoreleasing NSError **)error;

@end

NS_ASSUME_NONNULL_END
