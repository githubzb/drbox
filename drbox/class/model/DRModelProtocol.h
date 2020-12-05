//
//  DRModelProtocol.h
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DRModel <NSObject>


/**
 dictionary->model时容器类内部对应的数据类型映射
 */
+ (nullable NSDictionary<NSString *, id> *)toModelContainerInnerClassMapper;

/**
 model->dictionary时对应的key映射关系
 */
+ (nullable NSDictionary<NSString *, id> *)toDictionaryKeyMapper;

@end

NS_ASSUME_NONNULL_END
