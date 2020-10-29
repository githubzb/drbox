//
//  DRBlockDescription.h
//  drbox
//
//  Created by dr.box on 2020/9/3.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrboxCommonMacro.h"

DR_EXTERN_C_BEGIN

/**
 获取block的签名，如果block不是Block类型，返回nil
 
 @discussion
 需要注意：
 Block的第一个参数是自身对象，从第二个参数起，是真正参数部分
 而
 类的方法签名的第一个参数是自身对象，第二个参数是方法名，从第三个参数起，是真正参数部分
 */
extern NSMethodSignature * dr_signatureForBlock(id block);

/**
 判断block的签名与sign是否完全一致
 
 @discussion
 注意：block与类方法签名参数的类型不能完全匹配，例如：NSNumber与NSDate都是id类型，所以认为匹配成功
 
 @param block Block对象
 @param sign 要比对的方法签名
 @param error 错误信息，return YES, error == NULL
 
 @return block || sign == nil return NO；签名参数（类型与数量）和返回值类型完全匹配，返回：YES
 */
extern BOOL dr_matchAllSignature(id block, NSMethodSignature *sign, NSError **error);

/**
 判断block的签名与sign是否一致（参数个数可以不同，但对应位置的参数类型要一致）
 
 @discussion
 注意：block与类方法签名参数的类型不能完全匹配，例如：NSNumber与NSDate都是id类型，所以认为匹配成功
 
 @param block Block对象
 @param sign 要比对的方法签名
 @param error 错误信息，return YES, error == NULL
 
 @return block || sign == nil return NO；签名参数（类型与数量）和返回值类型完全匹配，返回：YES
 */
extern BOOL dr_matchSignature(id block, NSMethodSignature *sign, NSError **error);

/**
 调用指定的block（后面可变参数对应的是block的参数）
 
 @discussion
 需要注意：可变参数的类型一定要跟实际block签名参数类型一致，否则会出现一连串的取值错误，因为
 va_arg函数会找指定类型的值，如果当前位置的参数类型不匹配，它会向下移动指针，直到找到对应类
 型的值。这样一来，一旦对应位置的参数类型不匹配，后面的取值就会错乱。
 
 @return block的返回值，如果block返回值类型是void，该方法返回nil
 */
extern id dr_executeBlock(id block, ...);

/**
 调用指定的block（注意：args需要手动va_start和va_end）
 
 @param block 调用的block
 @param args 可变参数列表
 
 @return block的返回值，如果block返回值类型是void，该方法返回nil
 */
extern id dr_executeBlockVaList(id block, va_list args);

/**
 调用指定的block
 
 @param block 调用的block
 @param args block的参数
 
 @return block的返回值，如果block返回值类型是void，该方法返回nil
 */
extern id dr_executeBlockArgs(id block, NSArray *args);


DR_EXTERN_C_END
