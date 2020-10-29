//
//  UITableView+drbox.m
//  drbox
//
//  Created by dr.box on 2020/9/7.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "UITableView+drbox.h"
#import "DRBlockDescription.h"
#import "NSObject+drbox.h"
#import "DRDelegateProxy.h"

@implementation UITableView (drbox)

- (void)dr_updateWithBlock:(void (^)(UITableView * _Nonnull))block{
    [self beginUpdates];
    dr_executeBlock(block, self);
    [self endUpdates];
}

- (void)dr_scrollToRow:(NSUInteger)row
             inSection:(NSUInteger)section
      atScrollPosition:(UITableViewScrollPosition)scrollPosition
              animated:(BOOL)animated{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)dr_insertRow:(NSUInteger)row
           inSection:(NSUInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self dr_insertRowAtIndexPath:indexPath withRowAnimation:animation];
}

- (void)dr_reloadRow:(NSUInteger)row
           inSection:(NSUInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self dr_reloadRowAtIndexPath:indexPath withRowAnimation:animation];
}

- (void)dr_deleteRow:(NSUInteger)row
           inSection:(NSUInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self dr_deleteRowAtIndexPath:indexPath withRowAnimation:animation];
}

- (void)dr_insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation{
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)dr_reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation{
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)dr_deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation{
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)dr_insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation{
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
    [self insertSections:set withRowAnimation:animation];
}

- (void)dr_deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation{
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
    [self deleteSections:set withRowAnimation:animation];
}

- (void)dr_reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation{
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
    [self reloadSections:set withRowAnimation:animation];
}

- (void)dr_clearSelectedRowsAnimated:(BOOL)animated{
    NSArray *indexs = [self indexPathsForSelectedRows];
    [indexs enumerateObjectsUsingBlock:^(NSIndexPath *path, NSUInteger idx, BOOL *stop) {
        [self deselectRowAtIndexPath:path animated:animated];
    }];
}

#pragma mark - delegate

- (void)dr_setDelegate:(id<UITableViewDelegate>)delegate{
    [self dr_delegateProxy].proxiedDelegate = delegate;
}

- (void)dr_setDataSource:(id<UITableViewDataSource>)dataSource{
    [self dr_dataSourceProxy].proxiedDelegate = dataSource;
}

- (void)dr_addWillDisplayCellBlock:(void (^)(UITableView * _Nonnull,
                                             UITableViewCell * _Nonnull,
                                             NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)
                                withBlock:block];
}

- (void)dr_addWillDisplayHeaderViewBlock:(void (^)(UITableView * _Nonnull, UIView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:willDisplayHeaderView:forSection:)
                                withBlock:block];
}

- (void)dr_addWillDisplayFooterViewBlock:(void (^)(UITableView * _Nonnull, UIView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:willDisplayFooterView:forSection:)
                                withBlock:block];
}

- (void)dr_addDidEndDisplayingCellBlock:(void (^)(UITableView * _Nonnull,
                                                  UITableViewCell * _Nonnull,
                                                  NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)
                                withBlock:block];
}

- (void)dr_addDidEndDisplayingHeaderViewBlock:(void (^)(UITableView * _Nonnull, UIView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)
                                withBlock:block];
}

- (void)dr_addDidEndDisplayingFooterViewBlock:(void (^)(UITableView * _Nonnull, UIView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)
                                withBlock:block];
}

- (void)dr_addHeightForRowAtIndexPathBlock:(CGFloat (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:heightForRowAtIndexPath:)
                                withBlock:block];
}

- (void)dr_addHeightForHeaderAtIndexPathBlock:(CGFloat (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:heightForHeaderInSection:)
                                withBlock:block];
}

- (void)dr_addHeightForFooterAtIndexPathBlock:(CGFloat (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:heightForFooterInSection:)
                                withBlock:block];
}

- (void)dr_addEstimatedHeightForRowAtIndexPathBlock:(CGFloat (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)
                                withBlock:block];
}

- (void)dr_addEstimatedHeightForHeaderAtIndexPathBlock:(CGFloat (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:estimatedHeightForHeaderInSection:)
                                withBlock:block];
}

- (void)dr_addEstimatedHeightForFooterAtIndexPathBlock:(CGFloat (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:estimatedHeightForFooterInSection:)
                                withBlock:block];
}

- (void)dr_addViewForHeaderInSectionBlock:(UIView * _Nullable (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:viewForHeaderInSection:)
                                withBlock:block];
}

- (void)dr_addViewForFooterInSectionBlock:(UIView * _Nullable (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:viewForFooterInSection:)
                                withBlock:block];
}

- (void)dr_addWillSelectRowAtIndexPathBlock:(NSIndexPath * _Nullable (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:willSelectRowAtIndexPath:) withBlock:block];
}

- (void)dr_addWillDeselectRowAtIndexPathBlock:(NSIndexPath * _Nullable (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:willDeselectRowAtIndexPath:) withBlock:block];
}

- (void)dr_addDidSelectRowAtIndexPathBlock:(void (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:didSelectRowAtIndexPath:) withBlock:block];
}

- (void)dr_addDidDeselectRowAtIndexPathBlock:(void (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:didDeselectRowAtIndexPath:) withBlock:block];
}

- (void)dr_addEditingStyleForRowAtIndexPathBlock:(UITableViewCellEditingStyle (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:editingStyleForRowAtIndexPath:) withBlock:block];
}

- (void)dr_addTitleForDeleteConfirmationButtonForRowAtIndexPathBlock:(NSString * _Nullable (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_delegateProxy] bindSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)
                                withBlock:block];
}

#pragma mark - datasource

- (void)dr_addNumberOfRowsInSectionBlock:(NSInteger (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(tableView:numberOfRowsInSection:) withBlock:block];
}

- (void)dr_addCellForRowAtIndexPathBlock:(UITableViewCell * _Nonnull (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(tableView:cellForRowAtIndexPath:) withBlock:block];
}

- (void)dr_addNumberOfSectionsInTableViewBlock:(NSInteger (^)(UITableView * _Nonnull))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(numberOfSectionsInTableView:) withBlock:block];
}

- (void)dr_addTitleForHeaderInSectionBlock:(NSString * _Nullable (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(tableView:titleForHeaderInSection:) withBlock:block];
}

- (void)dr_addTitleForFooterInSectionBlock:(NSString * _Nullable (^)(UITableView * _Nonnull, NSInteger))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(tableView:titleForFooterInSection:) withBlock:block];
}

- (void)dr_addCanEditRowAtIndexPathBlock:(BOOL (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(tableView:canEditRowAtIndexPath:) withBlock:block];
}

- (void)dr_addCanMoveRowAtIndexPathBlock:(BOOL (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(tableView:canMoveRowAtIndexPath:) withBlock:block];
}

- (void)dr_addSectionIndexTitlesForTableViewBlock:(NSArray<NSString *> * _Nullable (^)(UITableView * _Nonnull))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(sectionIndexTitlesForTableView:) withBlock:block];
}

- (void)dr_addSectionForSectionIndexTitleBlock:(NSInteger (^)(UITableView * _Nonnull, NSString * _Nonnull, NSInteger))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(sectionForSectionIndexTitleAtIndex:)
                                  withBlock:block];
}

- (void)dr_addCommitEditingStyleBlock:(void (^)(UITableView * _Nonnull, UITableViewCellEditingStyle, NSIndexPath * _Nonnull))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)
                                  withBlock:block];
}

- (void)dr_addMoveRowAtIndexPathBlock:(void (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull, NSIndexPath * _Nonnull))block{
    [[self dr_dataSourceProxy] bindSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)
                                  withBlock:block];
}

#pragma mark - private

- (DRDelegateProxy *)dr_delegateProxy{
    DRDelegateProxy *proxy = [self dr_associateValueForKey:_cmd];
    if (!proxy) {
        proxy = [DRDelegateProxy proxyWithProtocol:@protocol(UITableViewDelegate)];
        [self dr_setAssociateStrongValue:proxy key:_cmd];
    }
    if (!self.delegate || self.delegate != proxy) {
        proxy.proxiedDelegate = self.delegate;
        self.delegate = (id)proxy;
    }
    return proxy;
}

- (DRDelegateProxy *)dr_dataSourceProxy{
    DRDelegateProxy *proxy = [self dr_associateValueForKey:_cmd];
    if (!proxy) {
        proxy = [DRDelegateProxy proxyWithProtocol:@protocol(UITableViewDataSource)];
        [self dr_setAssociateStrongValue:proxy key:_cmd];
    }
    if (!self.dataSource || self.dataSource != proxy) {
        proxy.proxiedDelegate = self.dataSource;
        self.dataSource = (id)proxy;
    }
    return proxy;
}

@end
