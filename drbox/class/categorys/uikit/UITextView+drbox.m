//
//  UITextView+drbox.m
//  drbox
//
//  Created by dr.box on 2020/9/6.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UITextView+drbox.h"
#import "DRDelegateProxy.h"
#import "NSObject+drbox.h"

@implementation UITextView (drbox)

- (void)dr_setDelegate:(id<UITextViewDelegate>)delegate{
    [self dr_delegateProxy].proxiedDelegate = delegate;
}

- (void)dr_addShouldBeginEditingBlock:(BOOL (^)(UITextView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textViewShouldBeginEditing:) withBlock:block];
}

- (void)dr_addShouldEndEditingBlock:(BOOL (^)(UITextView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textViewShouldEndEditing:) withBlock:block];
}

- (void)dr_addDidBeginEditingBlock:(void (^)(UITextView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textViewDidBeginEditing:) withBlock:block];
}

- (void)dr_addDidEndEditingBlock:(void (^)(UITextView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textViewDidEndEditing:) withBlock:block];
}

- (void)dr_addShouldChangeTextInRangeBlock:(BOOL (^)(UITextView * _Nonnull, NSRange, NSString * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textView:shouldChangeTextInRange:replacementText:)
                                withBlock:block];
}

- (void)dr_addDidChangeBlock:(void (^)(UITextView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textViewDidChange:) withBlock:block];
}

- (void)dr_addDidChangeSelectionBlock:(void (^)(UITextView * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textViewDidChangeSelection:) withBlock:block];
}

- (void)dr_addShouldInteractWithURLBlock:(BOOL (^)(UITextView * _Nonnull, NSURL * _Nonnull, NSRange * _Nonnull, UITextItemInteraction))block{
    [[self dr_delegateProxy] bindSelector:@selector(textView:shouldInteractWithURL:inRange:interaction:)
                                withBlock:block];
}

- (void)dr_addShouldInteractWithTextAttachmentBlock:(BOOL (^)(UITextView * _Nonnull, NSTextAttachment * _Nonnull, NSRange, UITextItemInteraction))block{
    [[self dr_delegateProxy] bindSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)
                                withBlock:block];
}

#pragma mark - private

- (DRDelegateProxy *)dr_delegateProxy{
    DRDelegateProxy *proxy = [self dr_associateValueForKey:_cmd];
    if (!proxy) {
        proxy = [DRDelegateProxy proxyWithProtocol:@protocol(UITextViewDelegate)];
        [self dr_setAssociateStrongValue:proxy key:_cmd];
    }
    if (!self.delegate || self.delegate != proxy) {
        proxy.proxiedDelegate = self.delegate;
        self.delegate = (id)proxy;
    }
    return proxy;
}

@end
