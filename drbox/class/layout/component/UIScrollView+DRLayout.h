//
//  UIScrollView+DRLayout.h
//  drbox
//
//  Created by dr.box on 2020/8/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (DRLayout)

@property (nonatomic, strong, readonly) UIView *dr_contentView;
/// 是否对contentView异步计算布局，默认：YES
@property (nonatomic, assign) BOOL dr_layoutAsynchronously;

/// 让scrollview重新对contentview进行布局
- (void)dr_setNeedsLayout;

@end

NS_ASSUME_NONNULL_END
