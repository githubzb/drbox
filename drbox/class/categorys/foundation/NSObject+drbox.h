//
//  NSObject+drbox.h
//  drbox
//
//  Created by dr.box on 2020/7/16.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DRClassInfo;
@interface NSObject (drbox)

/**
 为对象添加关联属性，并赋予值
 
 @param value   属性值
 @param key     属性名
 */
- (void)dr_setAssociateCopyValue:(nullable id)value key:(const void *)key;
/**
 为对象添加关联属性，并赋予值
 
 @param value   属性值
 @param key     属性名
 */
- (void)dr_setAssociateStrongValue:(nullable id)value key:(const void *)key;
/**
 为对象添加关联属性，并赋予值
 
 @param value   属性值
 @param key     属性名
 */
- (void)dr_setAssociateWeakValue:(nullable id)value key:(const void *)key;

/**
 获取对象的关联属性
 
 @param key 属性名
 @return    属性值
 */
- (nullable id)dr_associateValueForKey:(const void *)key;

// 删除对象所有关联属性
- (void)dr_removeAssociateAllKeys;

/**
 交换两个方法（注意：如果重复交换相同的两个方法，等同于未交换），
 类方法存储在元类对象的方法列表中，实例对象存储在类对象的方法列表中，所以在交换类方法时，
 应该使用元类对象来调用该方法。
 
@param orgSel 原始方法
@param atSel 目标方法
*/
+ (BOOL)dr_swizzleOrgMethod:(SEL)orgSel withMethod:(SEL)atSel;

/**
 hook类的方法（注意：该方法多次hook同一个类的同一个方法，hook会被叠加）
 
 @param orgSel 原始方法
 @param block 钩子回调block（第一个参数即：hook方法的调用者,id或Class类型，后面的参数：hook方法对应的参数）
 @param invocation 被hook的原始方法的调用者，可以通过该类的[invokeWithTarget:(block回调中的第一个参数)]，调用被hook的原始实例方法。
 @return YES：hook成功 or 失败
 
 @discussion
 hook类的实例方法
 __block NSInvocation *invocation;
 [[self class] dr_hookMethod:@selector(hookMethodTest:) withBlock:^(id obj, NSString *str){
     
    NSLog(@"-----hook:%@", str);
    [invocation setArgument:&str atIndex:2];
    [invocation invokeWithTarget:obj];
    // 获取原始方法的返回值
    void *res;
    [invocation getReturnValue:&res];
    NSLog(@"hookMethodTest return value:%@", (__bridge id)res);
    return (__bridge id)res;
 } orgInvocation:&invocation];
 
 // 调用被hook的方法
 [self hookMethodTest:@"hello!"];
 */
+ (BOOL)dr_hookMethod:(SEL)orgSel withBlock:(id)block orgInvocation:(NSInvocation *_Nullable*_Nullable)invocation;
/**
 hook类的类方法（注意：该方法多次hook同一个类的同一个方法，hook会被叠加）
 
 @param orgSel 原始类方法
 @param block 钩子回调block（第一个参数即：hook方法的调用者,class类型，后面的参数：hook方法对应的参数）
 @param invocation 被hook的原始类方法的调用者，可以通过该类的[invokeWithTarget:(block回调中的第一个参数)]，调用被hook的原始实例方法。
 @return YES：hook成功 or 失败
 
 @discussion
 // hook 类方法
 __block NSInvocation *invocation2;
 [self dr_hookClassMethod:@selector(hookClassMethodTest:) withBlock:^NSString * (id obj, NSString *str){
     
     NSLog(@"-----class hook:%@", str);
     [NSObject dr_setArgumentsForInvocation:invocation2, [NSString stringWithFormat:@"hookValue-%@", str]];
     [invocation2 invokeWithTarget:obj];
     NSString *res = [NSObject dr_getReturnValueForInvocation:invocation2];
     NSLog(@"------hookClassMethodTest return Value:%@", res);
     return res;
 } orgInvocation:&invocation2];
 */
+ (BOOL)dr_hookClassMethod:(SEL)orgSel withBlock:(id)block orgInvocation:(NSInvocation *_Nullable*_Nullable)invocation;

/**
 hook实例对象的实例方法（注意：该方法多次hook同一个对象的同一个方法，hook不会被叠加，也就是后一个hook会覆盖前一个hook；hook只作用于当前实例对象，不影响其他实例）

 @discussion
 具体使用：可以参考对应的类方法

 @param orgSel 原始方法
 @param block 钩子回调block（第一个参数即：hook方法的调用者,id或Class类型，后面的参数：hook方法对应的参数）
 @param invocation 被hook的原始方法的调用者，可以通过该类的[invokeWithTarget:(block回调中的第一个参数)]，调用被hook的原始实例方法。
 @return YES：hook成功 or 失败
*/
- (BOOL)dr_hookMethod:(SEL)orgSel withBlock:(id)block orgInvocation:(NSInvocation *_Nullable*_Nullable)invocation;


/// 当前类的信息
@property (nonatomic, readonly, class) DRClassInfo *dr_classInfo;


@end

NS_ASSUME_NONNULL_END
