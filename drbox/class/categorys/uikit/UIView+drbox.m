//
//  UIView+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/16.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UIView+drbox.h"
#import "NSObject+drbox.h"
#import "DrboxMacro.h"
#import "UIGestureRecognizer+drbox.h"

@interface DRViewFrame (){
    CGRect _rect;
}
@property (nonatomic, weak) UIView *view;

@end
@implementation DRViewFrame

- (instancetype)initWithView:(UIView *)view{
    self = [super init];
    if (self) {
        _rect = view.frame;
        self.view = view;
    }
    return self;
}

- (void)setFrame{
    dispatch_async_on_main_queue(^{
        self.view.frame = self->_rect;
    });
}

- (CGFloat)x{
    return CGRectGetMinX(_rect);
}

- (void)setX:(CGFloat)x{
    _rect.origin.x = x;
}

- (CGFloat)y{
    return CGRectGetMinY(_rect);
}

- (void)setY:(CGFloat)y{
    _rect.origin.y = y;
}

- (CGFloat)width{
    return CGRectGetWidth(_rect);
}

- (void)setWidth:(CGFloat)width{
    _rect.size.width = width;
}

- (CGFloat)height{
    return CGRectGetHeight(_rect);
}

- (void)setHeight:(CGFloat)height{
    _rect.size.height = height;
}

- (CGSize)size{
    return _rect.size;
}

- (void)setSize:(CGSize)size{
    _rect.size = size;
}

- (CGFloat)centerX{
    return self.x + self.width/2.0;
}

- (void)setCenterX:(CGFloat)centerX{
    _rect.origin.x = centerX - self.width/2.0;
}

- (CGFloat)centerY{
    return _rect.origin.y + self.height/2.0;
}

- (void)setCenterY:(CGFloat)centerY{
    _rect.origin.y = centerY - self.height/2.0;
}

@end


@implementation UIView (drbox)

- (CGPoint)dr_convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view{
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point toWindow:nil];
        } else {
            return [self convertPoint:point toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point toView:view];
    point = [self convertPoint:point toView:from];
    point = [to convertPoint:point fromWindow:from];
    point = [view convertPoint:point fromView:to];
    return point;
}

- (CGPoint)dr_convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view{
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point fromWindow:nil];
        } else {
            return [self convertPoint:point fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point fromView:view];
    point = [from convertPoint:point fromView:view];
    point = [to convertPoint:point fromWindow:from];
    point = [self convertPoint:point fromView:to];
    return point;
}

- (CGRect)dr_convertRect:(CGRect)rect toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect toWindow:nil];
        } else {
            return [self convertRect:rect toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!from || !to) return [self convertRect:rect toView:view];
    if (from == to) return [self convertRect:rect toView:view];
    rect = [self convertRect:rect toView:from];
    rect = [to convertRect:rect fromWindow:from];
    rect = [view convertRect:rect fromView:to];
    return rect;
}

- (CGRect)dr_convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect fromWindow:nil];
        } else {
            return [self convertRect:rect fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertRect:rect fromView:view];
    rect = [from convertRect:rect fromView:view];
    rect = [to convertRect:rect fromWindow:from];
    rect = [self convertRect:rect fromView:to];
    return rect;
}

- (UIImage *)dr_snapshotImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)dr_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates{
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self dr_snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    UIImage *snap = nil;
    if ([self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates]) {
        snap = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return snap;
}

- (NSData *)dr_snapshotPDF{
    CGRect bounds = self.bounds;
    NSMutableData *data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

- (void)dr_setLayerShadow:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = 1;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)dr_removeAllSubviews{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIViewController *)dr_viewController{
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (DRViewFrame *)dr_frame{
    DRViewFrame *frame = [self dr_associateValueForKey:_cmd];
    if (!frame) {
        frame = [[DRViewFrame alloc] initWithView:self];
        [self dr_setAssociateStrongValue:frame key:_cmd];
    }
    return frame;
}

- (void)dr_addClickOnceWithOneHand:(void (^)(UITapGestureRecognizer * _Nonnull))block{
    [self dr_addClickNumberOfTapsRequired:1 numberOfTouchesRequired:1 withBlock:block];
}

- (void)dr_addClickNumberOfTapsRequired:(NSUInteger)numOfTaps
                numberOfTouchesRequired:(NSUInteger)numOfTouches
                              withBlock:(void (^)(UITapGestureRecognizer * _Nonnull))block{
    if (!block) return;
    UITapGestureRecognizer *tap = [self getTapGestureWithNumberOfTapsRequired:numOfTaps
                                                      numberOfTouchesRequired:numOfTouches];
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:tap];
    }
    [tap dr_addActionBlock:block];
}

#pragma mark - private
/// 获取视图的tap手势
- (UITapGestureRecognizer *)getTapGestureWithNumberOfTapsRequired:(NSUInteger)numOfTaps
                      numberOfTouchesRequired:(NSUInteger)numOfTouches{
    for (UIGestureRecognizer *ges in self.gestureRecognizers) {
        if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *tap = (UITapGestureRecognizer *)ges;
            if (tap.numberOfTapsRequired == numOfTaps && tap.numberOfTouchesRequired == numOfTouches) {
                return tap;
            }
        }
    }
    return nil;
}

@end
