//
//  DRDelegateProxy.h
//  drbox
//
//  Created by dr.box on 2020/9/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRDelegateProxy : NSObject

/// 原代理对象
@property (nonatomic, unsafe_unretained) id proxiedDelegate;

/**
实例化delegate的代理类

@param protocol delegate的协议
*/
- (instancetype)initWithProtocol:(Protocol *)protocol;

/**
 实例化delegate的代理类
 
 @param protocol delegate的协议
 */
+ (instancetype)proxyWithProtocol:(Protocol *)protocol;

/**
 绑定delegate的selector到block上（注意：谨慎循环引用问题）
 */
- (void)bindSelector:(SEL)aSelector withBlock:(id)block;

@end

NS_ASSUME_NONNULL_END
