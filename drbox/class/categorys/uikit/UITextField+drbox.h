//
//  UITextField+drbox.h
//  drbox
//
//  Created by dr.box on 2020/9/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (drbox)

/// 选中全部文本
- (void)dr_selectAllText;

/// 选中指定范围的文本
- (void)dr_setSelectedRange:(NSRange)range;

/**
 添加文本变化回调
 
 @param block 回调函数 textField：当前的输入框
 */
- (void)dr_addTextChangedBlock:(void(^)(UITextField *textField))block;

// 设置代理
- (void)dr_setDelegate:(id<UITextFieldDelegate>)delegate;

- (void)dr_addShouldBeginEditingBlock:(BOOL(^)(UITextField *textField))block;
- (void)dr_addDidBeginEditingBlock:(void(^)(UITextField *textField))block;
- (void)dr_addShouldEndEditingBlock:(BOOL(^)(UITextField *textField))block;
- (void)dr_addDidEndEditingBlock:(void(^)(UITextField *textField))block;
- (void)dr_addDidEndEditingWithReasonBlock:(void(^)(UITextField *textField,
                                                    UITextFieldDidEndEditingReason reason))block API_AVAILABLE(ios(10.0));
- (void)dr_addShouldChangeCharactersInRangeBlock:(BOOL(^)(UITextField *textField, NSRange range, NSString *string))block;
- (void)dr_addDidChangeSelectionBlock:(void(^)(UITextField *textField))block API_AVAILABLE(ios(13.0), tvos(13.0));
- (void)dr_addShouldClearBlock:(BOOL(^)(UITextField *textField))block;
- (void)dr_addShouldReturnBlock:(BOOL(^)(UITextField *textField))block;

@end

NS_ASSUME_NONNULL_END
