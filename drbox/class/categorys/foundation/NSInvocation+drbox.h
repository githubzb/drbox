//
//  NSInvocation+drbox.h
//  drbox
//
//  Created by dr.box on 2020/9/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (drbox)

/**
 设置NSInvocation调用方法的参数（取代setArgument：atIndex：）
 
 @discussion 需要注意：可变参数的类型一定要跟实际方法签名参数类型一致，否则会出现一连串的取值错误，
 因为va_arg函数会找指定类型的值
 
 @discussion 如果当前位置的参数类型不匹配，它会向下移动指针，直到找到对应类型的值。
 这样一来，一旦对应位置的参数类型不匹配，后面的取值就会错乱。
 
 @param inv NSInvocation对象
 @param ... NSinvocation调用方法参数
 */
+ (void)dr_setArgumentsForInvocation:(NSInvocation *)inv, ...;

/**
 设置参数（注意：args需要手动va_start和va_end）
 
 @param args 可变参数列表
 */
- (void)dr_setArguments:(va_list)args;

/**
 设置参数值
 
 @discussion
 该方法比+dr_setArgumentsForInvocation稳定，它会根据实际参数类型对object进行转换，
 当object无法转换时，设置参数值为默认初始值。
 
 @discussion
 例如：方法参数类型为int，但是object的类型为NSDictionary，显而易见，这两种类型不能做转换，因此方法参数会被设置为默认初始值0
 
 @param object 参数值
 @param index 参数对应位置下标
 */
- (void)dr_setArgument:(id)object atIndex:(NSUInteger)index;

/**
 设置返回值，该方法会根据实际的返回值类型对value做类型转换，
 如果无法转换，则设置返回值为默认初始值。
 */
- (void)dr_setReturnValue:(id)value;

/**
 获取返回值（需要注意：当返回值为指针类型时，需要确保可以__bridge id，否则会crash）
 */
- (id)dr_getReturnValue;

/**
获取参数值（需要注意：当参数值为指针类型时，需要确保可以__bridge id，否则会crash）
*/
- (id)dr_argumentAtIndex:(NSInteger)index;

/**
 获取所有参数集合（参数是按照实际方法定义时的顺序排列，当参数值为nil，
 集合中对应保存的是NSNull对象，可根据实际情况处理）
 */
- (NSArray *)dr_getAllArguments;

@end

NS_ASSUME_NONNULL_END
