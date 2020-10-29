//
//  UITextView+drbox.h
//  drbox
//
//  Created by dr.box on 2020/9/6.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (drbox)

- (void)dr_setDelegate:(id<UITextViewDelegate>)delegate;
- (void)dr_addShouldBeginEditingBlock:(BOOL(^)(UITextView *textView))block;
- (void)dr_addShouldEndEditingBlock:(BOOL(^)(UITextView *textView))block;
- (void)dr_addDidBeginEditingBlock:(void(^)(UITextView *textView))block;
- (void)dr_addDidEndEditingBlock:(void(^)(UITextView *textView))block;
- (void)dr_addShouldChangeTextInRangeBlock:(BOOL(^)(UITextView *textView, NSRange range, NSString *text))block;
- (void)dr_addDidChangeBlock:(void(^)(UITextView *textView))block;
- (void)dr_addDidChangeSelectionBlock:(void(^)(UITextView *textView))block;
- (void)dr_addShouldInteractWithURLBlock:(BOOL(^)(UITextView *textView,
                                                  NSURL *URL,
                                                  NSRange *characterRange,
                                                  UITextItemInteraction interaction))block API_AVAILABLE(ios(10.0));
- (void)dr_addShouldInteractWithTextAttachmentBlock:(BOOL(^)(UITextView *textView,
                                                             NSTextAttachment *textAttachment,
                                                             NSRange characterRange,
                                                             UITextItemInteraction interaction))block API_AVAILABLE(ios(10.0));

@end

NS_ASSUME_NONNULL_END
