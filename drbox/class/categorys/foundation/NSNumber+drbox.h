//
//  NSNumber+drbox.h
//  drbox
//
//  Created by dr.box on 2020/7/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (drbox)

/**
 将字符串转成NSNumber对象
 
 @param string 字符串
 
 @return 如果不能转成NSNumber，返回nil
 */
+ (nullable NSNumber *)dr_numberWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
