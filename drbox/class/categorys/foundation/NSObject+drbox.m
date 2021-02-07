//
//  NSObject+drbox.m
//  drbox
//
//  Created by dr.box on 2020/7/16.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSObject+drbox.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "DRClassInfo.h"

/// 用于isa swizzle
static void *DRSubclassAssociationKey = &DRSubclassAssociationKey;

static inline NSMutableSet *DRSwizzledClasses() {
    static NSMutableSet *set;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        set = [[NSMutableSet alloc] init];
    });
    return set;
}

/// swizzle 类的getClass方法
static inline void DRSwizzleGetClass(Class class, Class statedClass) {
    SEL selector = @selector(class);
    Method method = class_getInstanceMethod(class, selector);
    IMP newIMP = imp_implementationWithBlock(^(id self) {
        return statedClass;
    });
    class_replaceMethod(class, selector, newIMP, method_getTypeEncoding(method));
}
/// 获取实例对象的subclass
static Class DRSwizzleClass(NSObject *self){
    Class knownDynamicSubclass = [self dr_associateValueForKey:DRSubclassAssociationKey];
    if (knownDynamicSubclass) return knownDynamicSubclass;
    Class statedClass = self.class;
    Class baseClass = object_getClass(self);// 获取对应的isa
    NSString *className = NSStringFromClass(baseClass);
    if (statedClass != baseClass) {
        @synchronized (DRSwizzledClasses()) {
            if (![DRSwizzledClasses() containsObject:className]) {
                DRSwizzleGetClass(baseClass, statedClass);
                DRSwizzleGetClass(object_getClass(baseClass), statedClass);
                [DRSwizzledClasses() addObject:className];
            }
        }
        return baseClass;
    }
    const char *subclassName = [NSString stringWithFormat:@"_DRSub%@", className].UTF8String;
    Class subclass = objc_getClass(subclassName);
    if (subclass == nil) {
        subclass = objc_allocateClassPair(baseClass, subclassName, 0); // 创建self的子类
        if (subclass == nil) return nil;
        DRSwizzleGetClass(subclass, statedClass);
        DRSwizzleGetClass(object_getClass(subclass), statedClass);
        objc_registerClassPair(subclass);
    }
    object_setClass(self, subclass);
    [self dr_setAssociateWeakValue:subclass key:DRSubclassAssociationKey];
    return subclass;
}

@implementation NSObject (drbox)


- (Class)dr_instanceClassForHook{
    return DRSwizzleClass(self);
}

- (void)dr_setAssociateCopyValue:(id)value key:(const void *)key{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)dr_setAssociateStrongValue:(id)value key:(const void *)key{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)dr_setAssociateWeakValue:(id)value key:(const void *)key{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}
- (id)dr_associateValueForKey:(const void *)key{
    return objc_getAssociatedObject(self, key);
}
- (void)dr_removeAssociateAllKeys{
    objc_removeAssociatedObjects(self);
}

+ (BOOL)dr_swizzleOrgMethod:(SEL)orgSel withMethod:(SEL)atSel{
    Method orgMethod = class_getInstanceMethod(self, orgSel);
    if (!orgMethod) return NO;
    Method atMethod = class_getInstanceMethod(self, atSel);
    if (!atMethod) return NO;
    class_addMethod(self, orgSel, method_getImplementation(orgMethod), method_getTypeEncoding(orgMethod));
    class_addMethod(self, atSel, method_getImplementation(atMethod), method_getTypeEncoding(atMethod));
    /**
     注意：此时的orgMethod和atMethod都是addMethod之前的方法，需要重新class_getInstanceMethod
     获取到addMethod之后的新的方法。
     我们在交换子类的orgSel和atSel两个方法的时候，如果子类没有重写父类的orgSel方法，此时调用
     method_exchangeImplementations函数，将会把父类的orgSel方法和子类的atSel交换
     而我们的目的是将子类的orgSel方法与子类的atSel方法做交换，因此我们需要调用addMethod，让子类重写
     父类的orgSel方法，然后在做交换。
     */
    method_exchangeImplementations( class_getInstanceMethod(self, orgSel),
                                   class_getInstanceMethod(self, atSel));
    return YES;
}

+ (BOOL)dr_hookMethod:(SEL)orgSel withBlock:(id)block orgInvocation:(NSInvocation * _Nullable __autoreleasing *)invocation{
    IMP blockImp = imp_implementationWithBlock(block);
    if (!blockImp) return NO;
    SEL blockSel = NSSelectorFromString([NSString stringWithFormat:@"_dr_block_%@_%p",
                                         NSStringFromSelector(orgSel), block]);
    const char * orgMethodTypes = method_getTypeEncoding(class_getInstanceMethod(self, orgSel));
    if (orgMethodTypes == NULL) return NO;
    if (!class_addMethod(self, blockSel, blockImp, orgMethodTypes)) return NO;
    BOOL res = [self dr_swizzleOrgMethod:orgSel withMethod:blockSel];
    if (!res) return NO;
    NSMethodSignature *sign = [NSMethodSignature signatureWithObjCTypes:orgMethodTypes];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sign];
    inv.selector = blockSel;// 交换之后，blockSel就是原始方法了
    *invocation = inv;
    return YES;
}
+ (BOOL)dr_hookClassMethod:(SEL)orgSel withBlock:(id)block orgInvocation:(NSInvocation * _Nullable __autoreleasing *)invocation{
    // 实例对象存储在类对象的方法列表中，类方法存储在元类对象的方法列表中，因此这里应该用元类调用
    return [object_getClass(self) dr_hookMethod:orgSel withBlock:block orgInvocation:invocation];
}

- (BOOL)dr_hookMethod:(SEL)orgSel withBlock:(id)block orgInvocation:(NSInvocation * _Nullable __autoreleasing *)invocation{
    IMP blockImp = imp_implementationWithBlock(block);
    if (!blockImp) return NO;
    Class cls = DRSwizzleClass(self);
    if (!cls) return NO;
    const char * orgMethodTypes = method_getTypeEncoding(class_getInstanceMethod(cls, orgSel));
    if (orgMethodTypes == NULL) return NO;
    // 确保cls实现了orgSel方法
    class_addMethod(cls,
                    orgSel,
                    class_getMethodImplementation(cls, orgSel),
                    orgMethodTypes);
    IMP orgImp = class_replaceMethod(cls, orgSel, blockImp, orgMethodTypes);
    SEL newOrgSel = NSSelectorFromString([NSString stringWithFormat:@"_dr_org_%@",
                                          NSStringFromSelector(orgSel)]);
    class_addMethod(cls, newOrgSel, orgImp, orgMethodTypes);// 添加新的方法用于实现原始方法
    NSMethodSignature *sign = [NSMethodSignature signatureWithObjCTypes:orgMethodTypes];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sign];
    inv.selector = newOrgSel;// 交换之后，blockSel就是原始方法了
    *invocation = inv;
    return YES;
}

+ (DRClassInfo *)dr_classInfo{
    return [DRClassInfo infoWithClass:self];
}

- (DRClassInfo *)dr_classInfo{
    return [DRClassInfo infoWithClass:self.class];
}

- (instancetype)dr_deepCopy{
    
    return self;
}

@end
