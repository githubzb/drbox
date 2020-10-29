//
//  DRTableView.h
//  drbox
//
//  Created by dr.box on 2020/8/3.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

// 如果你需要用到内部的tableView，你可以导入<drbox/DRTableView+private.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DRTableView;
@protocol DRTableViewDataSource <NSObject>

@required
- (NSInteger)tableView:(DRTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UIView *)tableView:(DRTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInTableView:(DRTableView *)tableView;
- (NSString *)tableView:(DRTableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(DRTableView *)tableView titleForFooterInSection:(NSInteger)section;
- (BOOL)tableView:(DRTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(DRTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(DRTableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath;

- (void)tableView:(DRTableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol DRTableViewDelegate <UIScrollViewDelegate>

@optional
- (void)tableView:(DRTableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(DRTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableView:(DRTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(DRTableView *)tableView viewForFooterInSection:(NSInteger)section;
- (UITableViewCellEditingStyle)tableView:(DRTableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DRTableView : UIView

@property (nonatomic, weak, nullable) id<DRTableViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<DRTableViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <UITableViewDataSourcePrefetching> prefetchDataSource API_AVAILABLE(ios(10.0));
@property (nonatomic, weak, nullable) id <UITableViewDragDelegate> dragDelegate API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos);
@property (nonatomic, weak, nullable) id <UITableViewDropDelegate> dropDelegate API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos);

/// tableView的头部视图
@property (nonatomic, strong, nullable) UIView *headerView;
/// tableView的尾部视图
@property (nonatomic, strong, nullable) UIView *footerView;

/**
 设置是否cell的高度一致，这样除了第一个cell采用同步计算布局外，其余cell均采用异步计算。
 注意：每次设置该属性后，都会清空cell的缓存，进行重新计算布局
 */
@property (nonatomic, assign) BOOL rowHeightUniform;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

- (void)reloadData;

/**
 从cell缓存中获取view，如果下标越界，或者缓存中不存在，返回nil
 */
- (nullable __kindof UIView *)cellViewForRowAtIndexPath:(NSIndexPath *)indexPath;

- (nullable UIView *)headerViewForSection:(NSInteger)section;
- (nullable UIView *)footerViewForSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
