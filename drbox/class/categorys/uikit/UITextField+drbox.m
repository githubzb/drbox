//
//  UITextField+drbox.m
//  drbox
//
//  Created by dr.box on 2020/9/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UITextField+drbox.h"
#import "UIControl+drbox.h"
#import "NSObject+drbox.h"
#import "DRDelegateProxy.h"


@implementation UITextField (drbox)

- (void)dr_selectAllText{
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument
                                          toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

- (void)dr_setSelectedRange:(NSRange)range{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}

- (void)dr_addTextChangedBlock:(void (^)(UITextField * _Nonnull))block{
    if (!block) return;
    [self dr_addActionBlock:^(UITextField *textField) {
        NSString *orgText = [textField dr_originalText] ? : @"";
        if (![orgText isEqualToString:textField.text]) {
            [textField dr_setOriginalText:textField.text];
            block(textField);
        }
    } forControlEvents:UIControlEventAllEditingEvents];
}

- (void)dr_setDelegate:(id<UITextFieldDelegate>)delegate{
    [self dr_delegateProxy].proxiedDelegate = delegate;
}

- (void)dr_addShouldBeginEditingBlock:(BOOL (^)(UITextField * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textFieldShouldBeginEditing:) withBlock:block];
}

- (void)dr_addDidBeginEditingBlock:(void (^)(UITextField * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textFieldDidBeginEditing:) withBlock:block];
}

- (void)dr_addShouldEndEditingBlock:(BOOL (^)(UITextField * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textFieldShouldEndEditing:) withBlock:block];
}

- (void)dr_addDidEndEditingBlock:(void (^)(UITextField * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textFieldDidEndEditing:) withBlock:block];
}

- (void)dr_addDidEndEditingWithReasonBlock:(void (^)(UITextField * _Nonnull, UITextFieldDidEndEditingReason))block{
    [[self dr_delegateProxy] bindSelector:@selector(textFieldDidEndEditing:reason:) withBlock:block];
}

- (void)dr_addShouldChangeCharactersInRangeBlock:(BOOL (^)(UITextField * _Nonnull, NSRange, NSString * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)
                                withBlock:block];
}

- (void)dr_addDidChangeSelectionBlock:(void (^)(UITextField * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textFieldDidChangeSelection:) withBlock:block];
}

- (void)dr_addShouldClearBlock:(BOOL (^)(UITextField * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textFieldShouldClear:) withBlock:block];
}

- (void)dr_addShouldReturnBlock:(BOOL (^)(UITextField * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(textFieldShouldReturn:) withBlock:block];
}

#pragma mark - private
- (NSString *)dr_originalText{
    return [self dr_associateValueForKey:_cmd];
}
- (void)dr_setOriginalText:(NSString *)text{
    [self dr_setAssociateCopyValue:text key:@selector(dr_originalText)];
}
- (DRDelegateProxy *)dr_delegateProxy{
    DRDelegateProxy *proxy = [self dr_associateValueForKey:_cmd];
    if (!proxy) {
        proxy = [DRDelegateProxy proxyWithProtocol:@protocol(UITextFieldDelegate)];
        [self dr_setAssociateStrongValue:proxy key:_cmd];
    }
    if (self.delegate == nil || (!self.delegate && self.delegate != proxy)) {
        proxy.proxiedDelegate = self.delegate;
        self.delegate = (id)proxy;
    }
    return proxy;
}

@end
