//
//  UIScrollView+drbox.m
//  drbox
//
//  Created by dr.box on 2020/9/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UIScrollView+drbox.h"
#import "NSObject+drbox.h"
#import "DRDelegateProxy.h"

@implementation UIScrollView (drbox)

- (void)dr_setDelegate:(id<UIScrollViewDelegate>)delegate{
    [self dr_delegateProxy].proxiedDelegate = delegate;
}

- (void)dr_addDidScrollBlock:(void (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewDidScroll:) withBlock:block];
}

- (void)dr_addDidZoomBlock:(void (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewDidZoom:) withBlock:block];
}

- (void)dr_addWillBeginDraggingBlock:(void (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewWillBeginDragging:) withBlock:block];
}

- (void)dr_addDidEndDraggingBlock:(void (^)(UIScrollView * _Nonnull, BOOL))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewDidEndDragging:willDecelerate:) withBlock:block];
}

- (void)dr_addWillBeginDeceleratingBlock:(void (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewWillBeginDecelerating:) withBlock:block];
}

- (void)dr_addDidEndDeceleratingBlock:(void (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewDidEndDecelerating:) withBlock:block];
}

- (void)dr_addDidEndScrollingAnimationBlock:(void (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewDidEndScrollingAnimation:) withBlock:block];
}

- (void)dr_addViewForZoomingInScrollView:(UIView * _Nullable (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(viewForZoomingInScrollView:) withBlock:block];
}

- (void)dr_addWillBeginZoomingBlock:(void (^)(UIScrollView * _Nonnull, UIView * _Nullable))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewWillBeginZooming:withView:) withBlock:block];
}

- (void)dr_addDidEndZoomingBlock:(void (^)(UIScrollView * _Nonnull, UIView * _Nullable, CGFloat))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewDidEndZooming:withView:atScale:) withBlock:block];
}

- (void)dr_addShouldScrollToTopBlock:(BOOL (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewShouldScrollToTop:) withBlock:block];
}

- (void)dr_addDidScrollToTopBlock:(void (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewDidScrollToTop:) withBlock:block];
}

- (void)dr_addDidChangeAdjustedContentInsetBlock:(void (^)(UIScrollView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(scrollViewDidChangeAdjustedContentInset:) withBlock:block];
}

#pragma mark - private

- (DRDelegateProxy *)dr_delegateProxy{
    DRDelegateProxy *proxy = [self dr_associateValueForKey:_cmd];
    if (!proxy) {
        proxy = [DRDelegateProxy proxyWithProtocol:@protocol(UITableViewDelegate)];
        [self dr_setAssociateStrongValue:proxy key:_cmd];
    }
    if (self.delegate == nil || (!self.delegate && self.delegate != proxy)) {
        proxy.proxiedDelegate = self.delegate;
        self.delegate = (id)proxy;
    }
    return proxy;
}

@end
