//
//  UIGestureRecognizer+drbox.h
//  drbox
//
//  Created by dr.box on 2020/8/30.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DRGestureRecognizerBlock)(id sender);

@interface UIGestureRecognizer (drbox)

- (void)dr_addActionBlock:(DRGestureRecognizerBlock)block;

- (void)dr_removeAllActionBlocks;

@end

NS_ASSUME_NONNULL_END
