//
//  NSURL+drbox.h
//  drbox
//
//  Created by DHY on 2021/1/11.
//  Copyright © 2021 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (drbox)

/// 返回URL参数
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *dr_parameters;
/// 返回URL参数（value为URLDecoding之后的值）
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *dr_parametersForURLDecoding;

@end

NS_ASSUME_NONNULL_END
