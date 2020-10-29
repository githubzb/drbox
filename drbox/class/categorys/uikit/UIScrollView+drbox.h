//
//  UIScrollView+drbox.h
//  drbox
//
//  Created by dr.box on 2020/9/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (drbox)

- (void)dr_setDelegate:(id<UIScrollViewDelegate>)delegate;

- (void)dr_addDidScrollBlock:(void(^)(UIScrollView *scrollView))block;
- (void)dr_addDidZoomBlock:(void(^)(UIScrollView *scrollView))block API_AVAILABLE(ios(3.2));
- (void)dr_addWillBeginDraggingBlock:(void(^)(UIScrollView *scrollView))block;
- (void)dr_addDidEndDraggingBlock:(void(^)(UIScrollView *scrollView, BOOL decelerate))block;
- (void)dr_addWillBeginDeceleratingBlock:(void(^)(UIScrollView *scrollView))block;
- (void)dr_addDidEndDeceleratingBlock:(void(^)(UIScrollView *scrollView))block;
- (void)dr_addDidEndScrollingAnimationBlock:(void(^)(UIScrollView *scrollView))block;
- (void)dr_addViewForZoomingInScrollView:(UIView *_Nullable(^)(UIScrollView *scrollView))block;
- (void)dr_addWillBeginZoomingBlock:(void(^)(UIScrollView *scrollView, UIView *_Nullable view))block API_AVAILABLE(ios(3.2));
- (void)dr_addDidEndZoomingBlock:(void(^)(UIScrollView *scrollView,
                                          UIView *_Nullable view,
                                          CGFloat scale))block;
- (void)dr_addShouldScrollToTopBlock:(BOOL(^)(UIScrollView *scrollView))block;
- (void)dr_addDidScrollToTopBlock:(void(^)(UIScrollView *scrollView))block;
- (void)dr_addDidChangeAdjustedContentInsetBlock:(void(^)(UIScrollView *scrollView))block API_AVAILABLE(ios(11.0), tvos(11.0));

@end

NS_ASSUME_NONNULL_END
