//
//  NSObject+DRModel.h
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DRModel)


+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
