//
//  DRWeakProxy.h
//  drbox
//
//  Created by DHY on 2020/12/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRWeakProxy : NSProxy

+ (nullable instancetype)weakProxyForObject:(id)targetObject;

@end

NS_ASSUME_NONNULL_END
