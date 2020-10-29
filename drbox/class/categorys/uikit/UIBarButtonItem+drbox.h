//
//  UIBarButtonItem+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/30.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DRBarButtonItemBlock)(id sender);

@interface UIBarButtonItem (drbox)

@property (nullable, nonatomic, copy) DRBarButtonItemBlock actionBlock;

+ (instancetype)dr_itemWithTitle:(nullable NSString *)title
                            style:(UIBarButtonItemStyle)style
                            block:(DRBarButtonItemBlock)block;

+ (instancetype)dr_itemWithImage:(nullable UIImage *)image
                           style:(UIBarButtonItemStyle)style
                           block:(DRBarButtonItemBlock)block;

+ (instancetype)dr_itemWithImage:(nullable UIImage *)image
             landscapeImagePhone:(nullable UIImage *)landscapeImagePhone
                           style:(UIBarButtonItemStyle)style
                           block:(DRBarButtonItemBlock)block;

@end

NS_ASSUME_NONNULL_END
