//
//  DRKVObserver.h
//  drbox
//
//  Created by dr.box on 2020/11/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRKVObserver : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithObservable:(id)observable NS_DESIGNATED_INITIALIZER;

- (BOOL)addKeyPath:(NSString *)keyPath forTarget:(id)target action:(SEL)action;
- (BOOL)addKeyPath:(NSString *)keyPath forBlock:(id)block;

/// 判断是否需要重新添加属性观察者
- (BOOL)needAddObserverForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
