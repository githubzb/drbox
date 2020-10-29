//
//  UITableView+drbox.h
//  drbox
//
//  Created by dr.box on 2020/9/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (drbox)

- (void)dr_updateWithBlock:(void (^)(UITableView *tableView))block;

/**
 滚动指定section和row的cell到指定的位置position
 */
- (void)dr_scrollToRow:(NSUInteger)row
             inSection:(NSUInteger)section
      atScrollPosition:(UITableViewScrollPosition)scrollPosition
              animated:(BOOL)animated;

/**
 插入cell到指定的section和row
 */
- (void)dr_insertRow:(NSUInteger)row
           inSection:(NSUInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation;

/**
 重新加载section和row下的cell
 */
- (void)dr_reloadRow:(NSUInteger)row
           inSection:(NSUInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除section和row下的cell
 */
- (void)dr_deleteRow:(NSUInteger)row
           inSection:(NSUInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation;

/**
 插入cell到指定的indexPath
 */
- (void)dr_insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 重新加载指定位置的cell
 */
- (void)dr_reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除指定indexPath的cell
 */
- (void)dr_deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 在指定的section中插入cell
 */
- (void)dr_insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除指定section中的cell
 */
- (void)dr_deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 重新加载指定section中的cell
 */
- (void)dr_reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 将已选中的cell至为未选中状态
 */
- (void)dr_clearSelectedRowsAnimated:(BOOL)animated;

#pragma mark - delegate

- (void)dr_setDelegate:(id<UITableViewDelegate>)delegate;

- (void)dr_setDataSource:(id<UITableViewDataSource>)dataSource;

- (void)dr_addWillDisplayCellBlock:(void(^)(UITableView *tableView,
                                            UITableViewCell *cell,
                                            NSIndexPath *indexPath))block;

- (void)dr_addWillDisplayHeaderViewBlock:(void(^)(UITableView *tableView,
                                                  UIView *header,
                                                  NSInteger section))block API_AVAILABLE(ios(6.0));

- (void)dr_addWillDisplayFooterViewBlock:(void(^)(UITableView *tableView,
                                                  UIView *footer,
                                                  NSInteger section))block API_AVAILABLE(ios(6.0));

- (void)dr_addDidEndDisplayingCellBlock:(void(^)(UITableView *tableView,
                                                 UITableViewCell *cell,
                                                 NSIndexPath *indexPath))block API_AVAILABLE(ios(6.0));

- (void)dr_addDidEndDisplayingHeaderViewBlock:(void(^)(UITableView *tableView,
                                                       UIView *header,
                                                       NSInteger section))block API_AVAILABLE(ios(6.0));

- (void)dr_addDidEndDisplayingFooterViewBlock:(void(^)(UITableView *tableView,
                                                       UIView *footer,
                                                       NSInteger section))block API_AVAILABLE(ios(6.0));

- (void)dr_addHeightForRowAtIndexPathBlock:(CGFloat(^)(UITableView *tableView, NSIndexPath *indexPath))block;
- (void)dr_addHeightForHeaderAtIndexPathBlock:(CGFloat(^)(UITableView *tableView, NSInteger section))block;
- (void)dr_addHeightForFooterAtIndexPathBlock:(CGFloat(^)(UITableView *tableView, NSInteger section))block;

- (void)dr_addEstimatedHeightForRowAtIndexPathBlock:(CGFloat(^)(UITableView *tableView,
                                                                NSIndexPath *indexPath))block API_AVAILABLE(ios(7.0));
- (void)dr_addEstimatedHeightForHeaderAtIndexPathBlock:(CGFloat(^)(UITableView *tableView,
                                                                   NSInteger section))block API_AVAILABLE(ios(7.0));
- (void)dr_addEstimatedHeightForFooterAtIndexPathBlock:(CGFloat(^)(UITableView *tableView,
                                                                   NSInteger section))block API_AVAILABLE(ios(7.0));

- (void)dr_addViewForHeaderInSectionBlock:(UIView * _Nullable(^)(UITableView *tableView, NSInteger section))block;
- (void)dr_addViewForFooterInSectionBlock:(UIView * _Nullable(^)(UITableView *tableView, NSInteger section))block;

- (void)dr_addWillSelectRowAtIndexPathBlock:(NSIndexPath * _Nullable(^)(UITableView *tableView,
                                                                        NSIndexPath *indexPath))block;
- (void)dr_addWillDeselectRowAtIndexPathBlock:(NSIndexPath * _Nullable(^)(UITableView *tableView,
                                                                          NSIndexPath *indexPath))block API_AVAILABLE(ios(3.0));

- (void)dr_addDidSelectRowAtIndexPathBlock:(void(^)(UITableView *tableView, NSIndexPath *indexPath))block;
- (void)dr_addDidDeselectRowAtIndexPathBlock:(void(^)(UITableView *tableView, NSIndexPath *indexPath))block API_AVAILABLE(ios(3.0));

- (void)dr_addEditingStyleForRowAtIndexPathBlock:(UITableViewCellEditingStyle(^)(UITableView *tableView,
                                                                                 NSIndexPath *indexPath))block;
- (void)dr_addTitleForDeleteConfirmationButtonForRowAtIndexPathBlock:(NSString *_Nullable(^)(UITableView *tableView, NSIndexPath *indexPath))block API_AVAILABLE(ios(3.0));

#pragma mark - datasource

- (void)dr_addNumberOfRowsInSectionBlock:(NSInteger(^)(UITableView *tableView, NSInteger section))block;
- (void)dr_addCellForRowAtIndexPathBlock:(UITableViewCell *(^)(UITableView *tableView, NSIndexPath *indexPath))block;

- (void)dr_addNumberOfSectionsInTableViewBlock:(NSInteger(^)(UITableView *tableView))block;
- (void)dr_addTitleForHeaderInSectionBlock:(NSString *_Nullable(^)(UITableView *tableView, NSInteger section))block;
- (void)dr_addTitleForFooterInSectionBlock:(NSString *_Nullable(^)(UITableView *tableView, NSInteger section))block;

- (void)dr_addCanEditRowAtIndexPathBlock:(BOOL(^)(UITableView *tableView, NSIndexPath *indexPath))block;
- (void)dr_addCanMoveRowAtIndexPathBlock:(BOOL(^)(UITableView *tableView, NSIndexPath *indexPath))block;

- (void)dr_addSectionIndexTitlesForTableViewBlock:(NSArray<NSString *> *_Nullable(^)(UITableView *tableView))block;
- (void)dr_addSectionForSectionIndexTitleBlock:(NSInteger(^)(UITableView *tableView,
                                                             NSString *title,
                                                             NSInteger index))block;
- (void)dr_addCommitEditingStyleBlock:(void(^)(UITableView *tableView,
                                               UITableViewCellEditingStyle editingStyle,
                                               NSIndexPath *indexPath))block;
- (void)dr_addMoveRowAtIndexPathBlock:(void(^)(UITableView *tableView,
                                               NSIndexPath *sourceIndexPath,
                                               NSIndexPath *destinationIndexPath))block;

@end

NS_ASSUME_NONNULL_END
