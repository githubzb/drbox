//
//  UIScrollView+DRLayout.m
//  drbox
//
//  Created by dr.box on 2020/8/2.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UIScrollView+DRLayout.h"
#import "NSObject+drbox.h"
#import "UIView+DRLayout.h"
#import "DRLayout+private.h"

@implementation UIScrollView (DRLayout)

+ (void)load{
    __block NSInvocation *orgInv;
    [self dr_hookMethod:@selector(layoutSubviews)
              withBlock:^(UIScrollView *scrollView){
        [orgInv invokeWithTarget:scrollView];
        if ([scrollView isContentViewEnabled]) {
            if (scrollView.dr_contentView.dr_isLayoutEnabled && [scrollView dr_needsLayout]){
                [scrollView dr_setLayoutFinish];
                // 装配布局节点
                [scrollView.dr_contentView dr_setUpLayout];
                // 计算contentView尺寸
                DRSizeFlexibility flexibility;
                switch (scrollView.dr_contentView.dr_layout.flexDirection) {
                    case YGFlexDirectionRow: case YGFlexDirectionRowReverse:
                        // 横屏滚动
                        flexibility = DRSizeFlexibilityWidth;
                        break;
                    case YGFlexDirectionColumn: case YGFlexDirectionColumnReverse:
                        // 竖屏滚动
                        flexibility = DRSizeFlexibilityHeight;
                        break;
                        
                    default:
                        // 竖屏滚动
                        flexibility = DRSizeFlexibilityHeight;
                        break;
                }
                CGSize calculateSize = [scrollView calculateSizeWithSizeFlexibility:flexibility];
                if (scrollView.dr_layoutAsynchronously) {
                    [DRLayoutTransaction addTransaction:^{
                        CGSize size = [scrollView.dr_contentView.dr_layout calculateLayoutWithSize:calculateSize];
                        [scrollView setTempContentSize:size];
                    } complete:^{
                        CGSize size = [scrollView tempContentSize];
                        [scrollView clearTempContentSize];
                        CGSize scrollSize = scrollView.frame.size;
                        CGFloat contentW = size.width > scrollSize.width ? size.width : scrollSize.width;
                        CGFloat contentH = size.height > scrollSize.height ? size.height : scrollSize.height;
                        scrollView.contentSize = CGSizeMake(contentW, contentH);
                        [scrollView.dr_contentView dr_applyLayout];
                    }];
                } else {
                    CGSize size = [scrollView.dr_contentView.dr_layout calculateLayoutWithSize:calculateSize];
                    CGSize scrollSize = scrollView.frame.size;
                    CGFloat contentW = size.width > scrollSize.width ? size.width : scrollSize.width;
                    CGFloat contentH = size.height > scrollSize.height ? size.height : scrollSize.height;
                    scrollView.contentSize = CGSizeMake(contentW, contentH);
                    [scrollView.dr_contentView dr_applyLayout];
                }
            }
        }
    } orgInvocation:&orgInv];
}

- (UIView *)dr_contentView{
    UIView *v = [self dr_associateValueForKey:_cmd];
    if (!v) {
        v = [[UIView alloc] init];
        v.backgroundColor = [UIColor whiteColor];
        [self addSubview:v];
        [self dr_setAssociateStrongValue:v key:_cmd];
    }
    return v;
}

- (void)setDr_layoutAsynchronously:(BOOL)dr_layoutAsynchronously{
    [self dr_setAssociateWeakValue:@(dr_layoutAsynchronously)
                               key:@selector(dr_layoutAsynchronously)];
}

- (BOOL)dr_layoutAsynchronously{
    NSNumber *num = [self dr_associateValueForKey:_cmd];
    if (num) return [num boolValue];
    return YES; // 默认
}

- (void)dr_setNeedsLayout{
    [self dr_setAssociateCopyValue:@(YES) key:@selector(dr_needsLayout)];
    [self setNeedsLayout];
}

#pragma mark - private
- (BOOL)dr_needsLayout{
    NSNumber *num = [self dr_associateValueForKey:_cmd];
    if (!num) return YES; // 默认YES
    return [num boolValue];
}
- (void)dr_setLayoutFinish{
    [self dr_setAssociateCopyValue:@(NO) key:@selector(dr_needsLayout)];
}
- (BOOL)isContentViewEnabled{
    return [self dr_associateValueForKey:@selector(dr_contentView)] != nil;
}
// 用于临时存储contentView异步计算的尺寸
- (void)setTempContentSize:(CGSize)size{
    [self dr_setAssociateStrongValue:[NSValue valueWithCGSize:size]
                                 key:@selector(tempContentSize)];
}
- (CGSize)tempContentSize{
    NSValue *value = [self dr_associateValueForKey:_cmd];
    if (value) return [value CGSizeValue];
    return CGSizeZero;
}
- (void)clearTempContentSize{
    [self dr_setAssociateStrongValue:nil key:@selector(tempContentSize)];
}
- (CGSize)calculateSizeWithSizeFlexibility:(DRSizeFlexibility)flexibility{
    CGSize size = self.bounds.size;
    if (flexibility & DRSizeFlexibilityWidth) {
        size.width = YGUndefined; // 宽度无边界
    }
    if (flexibility & DRSizeFlexibilityHeight) {
        size.height = YGUndefined; // 高度无边界
    }
    return size;
}

@end
