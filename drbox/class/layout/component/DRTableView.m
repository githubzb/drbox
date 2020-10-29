//
//  DRTableView.m
//  drbox
//
//  Created by dr.box on 2020/8/3.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRTableView.h"
#import "DRTableView+private.h"
#import "UIView+DRLayout.h"
#import "DRLayout+private.h"
#import "DrboxMacro.h"
#import "DRLock.h"
#import "DRThreadPool.h"


/// 释放内存的线程队列
static inline dispatch_queue_t DRTableCellCacheGetReleaseQueue() {
    return DRThreadPoolGetQueue(NSQualityOfServiceUtility);
}

@interface _DRViewNode : NSObject{
    @package // 目的是让外部类可以通过node->访问到其内部成员变量，如：node->_key
    __unsafe_unretained _DRViewNode *_prev;
    __unsafe_unretained _DRViewNode *_next;
    NSString *_key;
    UIView *_value;
    NSInteger _section; // cell所在的组下标
    NSInteger _row; // cell所在组中的下标
}
@end
@implementation _DRViewNode
@end

@interface _DRViewNodeMap : NSObject{
    @package // 目的是让外部类可以通过map->访问到其内部成员变量，如：node->_dic
    CFMutableDictionaryRef _dic;
    NSUInteger _totalCount; // 总节点个数
    _DRViewNode *_head;
    _DRViewNode *_tail;
}

/**
 插入节点
 
 @param node 新节点
 
 @return 1：插入到链表的尾部；-1：插入到链表的头部
 */
- (NSInteger)insertNode:(_DRViewNode *)node;
- (_DRViewNode *)removeHeadNode;
- (_DRViewNode *)removeTailNode;
- (void)removeAllNode;

@end

@implementation _DRViewNodeMap

- (void)dealloc{
    CFRelease(_dic);
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _dic = CFDictionaryCreateMutable(NULL,
                                         0,
                                         &kCFTypeDictionaryKeyCallBacks,
                                         &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (NSInteger)insertNode:(_DRViewNode *)node{
    CFDictionarySetValue(_dic, (__bridge const void *)node->_key, (__bridge const void *)node);
    _totalCount ++;
    NSInteger tag = 1;
    if (_tail) {
        // 判断是添加到链表的头部还是尾部
        if (node->_section < _tail->_section ||
            (node->_section == _tail->_section && node->_row < _tail->_row)) {
            // 添加到链表头部
            tag = -1;
            node->_next = _head;
            _head->_prev = node;
            _head = node;
        }else{
            // 添加到链表尾部
            _tail->_next = node;
            node->_prev = _tail;
            _tail = node;
        }
    } else {
        _head = _tail = node;
    }
    return tag;
}

- (_DRViewNode *)removeHeadNode{
    if (!_head) return nil;
    _DRViewNode *head = _head;
    CFDictionaryRemoveValue(_dic, (__bridge const void *)head->_key);
    _totalCount --;
    if (_head == _tail) {
        // 最后一个节点
        _head = _tail = nil;
    }else{
        _head = _head->_next;
        _head->_prev = nil;
    }
    return head;
}

- (_DRViewNode *)removeTailNode{
    if (!_tail) return nil;
    _DRViewNode *tail = _tail;
    CFDictionaryRemoveValue(_dic, (__bridge const void *)tail->_key);
    _totalCount --;
    if (_head == _tail) {
        // 最后一个节点
        _head = _tail = nil;
    }else{
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return nil;
}

- (void)removeAllNode{
    _totalCount = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_dic) > 0){
        CFMutableDictionaryRef temp = _dic;
        _dic = CFDictionaryCreateMutable(NULL,
                                         0,
                                         &kCFTypeDictionaryKeyCallBacks,
                                         &kCFTypeDictionaryValueCallBacks);
        dispatch_async(DRTableCellCacheGetReleaseQueue(), ^{
            CFRelease(temp);
        });
    }
}

@end

@interface _DRTableViewCache : NSObject{
    _DRViewNodeMap *_map;
    DRMutexLock *_lock;
    NSUInteger _countLimit; // 缓存最大数量限制
}

- (instancetype)initWithCountLimit:(NSUInteger)countLimit;
/// 添加缓存视图
- (void)setView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath;
- (void)setView:(UIView *)view atSection:(NSInteger)section;
/// 获取缓存视图
- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)viewAtSection:(NSInteger)section;

- (void)removeAllCache;

@end

@implementation _DRTableViewCache

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
    [_map removeAllNode];
}

- (instancetype)initWithCountLimit:(NSUInteger)countLimit {
    self = [super init];
    if (self) {
        _map = [[_DRViewNodeMap alloc] init];
        _lock = [[DRMutexLock alloc] init];
        _countLimit = countLimit;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarningNotification)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}
- (instancetype)init{
    return [self initWithCountLimit:500];
}

- (void)setView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath & !view) return;
    [_lock around:^{
        NSString *key = [NSString stringWithFormat:@"%ld_%ld", indexPath.section, (long)indexPath.row];
        _DRViewNode *node = CFDictionaryGetValue(self->_map->_dic,
                                                 (__bridge const void *)key);
        NSInteger tag = 0;
        if (node) {
            // 节点存在，替换视图
            node->_value = view;
        } else {
            // 添加新节点
            node = [[_DRViewNode alloc] init];
            node->_key = key;
            node->_value = view;
            node->_section = indexPath.section;
            node->_row = indexPath.row;
            tag = [self->_map insertNode:node];
        }
        // 判断是否越限
        if (self->_map->_totalCount > self->_countLimit) {
            _DRViewNode *node;
            if (tag == -1) {
                // 当前节点插入到了链表的头部，应该从链表的尾部删除
                node = [self->_map removeTailNode];
            } else {
                // 当前节点插入到了链表的尾部，应该从链表的头部删除
                node = [self->_map removeHeadNode];
            }
            dispatch_async(DRTableCellCacheGetReleaseQueue(), ^{
                [node class]; // 将node捕获到线程中去释放
            });
        }
    }];
}

- (void)setView:(UIView *)view atSection:(NSInteger)section{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [self setView:view atIndexPath:indexPath];
}

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath) return nil;
    _DRViewNode *node = [_lock aroundReturnId:^id _Nullable{
        NSString *key = [NSString stringWithFormat:@"%ld_%ld", indexPath.section, (long)indexPath.row];
        return CFDictionaryGetValue(self->_map->_dic, (__bridge const void *)key);
    }];
    return node ? node->_value : nil;
}

- (UIView *)viewAtSection:(NSInteger)section{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    return [self viewAtIndexPath:indexPath];
}

- (void)removeAllCache{
    [_map removeAllNode];
}

#pragma mark - private
- (void)handleMemoryWarningNotification{
    [_lock around:^{
        [self removeAllCache];
    }];
}

@end


#define DRTableViewCellIdentifier @"com.drbox.drtableview.cell"
#define DRTableViewCellTag 2020

@interface DRTableView ()<UITableViewDataSource, UITableViewDelegate>{
    
    _DRTableViewCache *_cellCache; // cell视图的缓存
    NSMutableDictionary *_headerCache; // header视图的缓存（注意：该缓存不能清除，否则对应的header视图将消失）
    NSMutableDictionary *_footerCache; // footer视图的缓存（注意：该缓存不能清除，否则对应的footer视图将消失）
    CGFloat _uniformRowHeight; // cell一致的高度，当rowHeightUniform==YES时使用
    BOOL _rowHeightCalculateFinish; // cell高度是否计算完成，当rowHeightUniform==YES时使用
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, readonly) _DRTableViewCache *cellCache;
@property (nonatomic, readonly) NSMutableDictionary *headerCache;// header创建的时候可能出现了无序的情况，因此采用字典作为缓存数据结构
@property (nonatomic, readonly) NSMutableDictionary *footerCache;// footer创建的时候可能出现了无序的情况，因此采用字典作为缓存数据结构

@end
@implementation DRTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:frame style:style];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:DRTableViewCellIdentifier];
        [self addSubview:_tableView];
    }
    return self;
}

- (instancetype)init{
    return [self initWithFrame:CGRectZero style:UITableViewStylePlain];
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (void)layoutSubviews{
    self.tableView.frame = self.bounds;
    if (self.headerView.dr_isLayoutEnabled) {
        [self displayView:self.headerView];
    }
    if (self.footerView.dr_isLayoutEnabled) {
        [self displayView:self.footerView];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    self.tableView.backgroundColor = backgroundColor;
}

- (void)setPrefetchDataSource:(id<UITableViewDataSourcePrefetching>)prefetchDataSource{
    self.tableView.prefetchDataSource = prefetchDataSource;
}

- (id<UITableViewDataSourcePrefetching>)prefetchDataSource{
    return self.tableView.prefetchDataSource;
}

- (void)setDragDelegate:(id<UITableViewDragDelegate>)dragDelegate{
    self.tableView.dragDelegate = dragDelegate;
}

- (id<UITableViewDragDelegate>)dragDelegate{
    return self.tableView.dragDelegate;
}

- (void)setDropDelegate:(id<UITableViewDropDelegate>)dropDelegate{
    self.tableView.dropDelegate = dropDelegate;
}

- (id<UITableViewDropDelegate>)dropDelegate{
    return self.dropDelegate;
}

- (void)setHeaderView:(UIView *)headerView{
    self.tableView.tableHeaderView = headerView;
}

- (UIView *)headerView{
    return self.tableView.tableHeaderView;
}

- (void)setFooterView:(UIView *)footerView{
    self.tableView.tableFooterView = footerView;
}

- (UIView *)footerView{
    return self.tableView.tableFooterView;
}

- (void)setRowHeightUniform:(BOOL)rowHeightUniform{
    NSAssert([NSThread isMainThread], @"setRowHeightUniform: method must be called on the main thread.");
    [self.cellCache removeAllCache];
    _rowHeightCalculateFinish = NO;
    _rowHeightUniform = rowHeightUniform;
}

- (void)reloadData{
    // 清空缓存
    [self removeAllCache];
    [self.tableView reloadData];
}

- (UIView *)cellViewForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.cellCache viewAtIndexPath:indexPath];
}

- (UIView *)headerViewForSection:(NSInteger)section{
    return [self.headerCache valueForKey:[@(section) stringValue]];
}

- (UIView *)footerViewForSection:(NSInteger)section{
    return [self.footerCache valueForKey:[@(section) stringValue]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [self.dataSource numberOfSectionsInTableView:self];
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource tableView:self numberOfRowsInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DRTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIView *view = [self.cellCache viewAtIndexPath:indexPath];
    [[cell.contentView viewWithTag:DRTableViewCellTag] removeFromSuperview];
    [cell.contentView addSubview:view];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [self.dataSource tableView:self titleForHeaderInSection:section];
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]){
        return [self.dataSource tableView:self titleForFooterInSection:section];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [self.dataSource tableView:self canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        return [self.dataSource tableView:self canMoveRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    if ([self.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        [self.dataSource tableView:self
                moveRowAtIndexPath:sourceIndexPath
                       toIndexPath:destinationIndexPath];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.dataSource tableView:self
                commitEditingStyle:editingStyle
                 forRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:self willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIView *view = [self.cellCache viewAtIndexPath:indexPath];
    if (!view){
        view = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
        view.tag = DRTableViewCellTag;
        [self.cellCache setView:view atIndexPath:indexPath];
        if ([view dr_isLayoutEnabled]) {
            [self layoutCellView:view];
        }
    }
    return _rowHeightCalculateFinish ? _uniformRowHeight : view.bounds.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.headerCache valueForKey:[@(section) stringValue]];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.footerCache valueForKey:[@(section) stringValue]];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        UIView *view = [self.footerCache valueForKey:[@(section) stringValue]];
        if (!view) {
            view = [self.delegate tableView:self viewForHeaderInSection:section];
            [self.headerCache setValue:view forKey:[@(section) stringValue]];
            if ([view dr_isLayoutEnabled]) {
                [self displayView:view];
            }
        }
        return view.bounds.size.height;
    }
    return tableView.style == UITableViewStyleGrouped?0.001:0;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        UIView *view = [self.footerCache valueForKey:[@(section) stringValue]];
        if (!view) {
            view = [self.delegate tableView:self viewForFooterInSection:section];
            [self.footerCache setValue:view forKey:[@(section) stringValue]];
            if ([view dr_isLayoutEnabled]) {
                [self displayView:view];
            }
        }
        return view.bounds.size.height;
    }
    return tableView.style == UITableViewStyleGrouped?0.001:0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
        return [self.delegate tableView:self editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.delegate scrollViewDidZoom:scrollView];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view{
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.delegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.delegate scrollViewDidScrollToTop:scrollView];
    }
}
- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidChangeAdjustedContentInset:)]) {
        if (@available(iOS 11.0, *)) {
            [self.delegate scrollViewDidChangeAdjustedContentInset:scrollView];
        } else {
            // Fallback on earlier versions
        }
    }
}



#pragma mark - private
- (UITableView *)innerTableView{
    return self.tableView;
}
- (_DRTableViewCache *)cellCache{
    if (!_cellCache) {
        _cellCache = [[_DRTableViewCache alloc] init];
    }
    return _cellCache;
}
- (NSMutableDictionary *)headerCache{
    if (!_headerCache) {
        _headerCache = [[NSMutableDictionary alloc] init];
    }
    return _headerCache;
}
- (NSMutableDictionary *)footerCache{
    if (!_footerCache) {
        _footerCache = [[NSMutableDictionary alloc] init];
    }
    return _footerCache;
}
- (void)removeAllCache{
    [self.cellCache removeAllCache];
}
- (void)displayView:(UIView *)view{
    CGSize calculateSize = _tableView.bounds.size;
    calculateSize.height = YGUndefined; // 高度自适应
    [view dr_setUpLayout]; // 装载view上的布局节点
    [view.dr_layout calculateLayoutWithSize:calculateSize];
    [view dr_applyLayout]; // 对view以及子视图应用布局
}
- (void)asyncDisplayView:(UIView *)view{
    CGRect frame = view.frame;
    frame.size = CGSizeMake(_tableView.bounds.size.width, _uniformRowHeight);
    view.frame = frame;
    [view dr_asyncDisplayLayout];
}
// 采用drlayout布局
- (void)layoutCellView:(UIView *)view{
    if (_rowHeightUniform) {
        if (_rowHeightCalculateFinish) {
            // 异步布局
            [self asyncDisplayView:view];
        }else{
            // 同步布局
            [self displayView:view];
            _uniformRowHeight = view.bounds.size.height;
            _rowHeightCalculateFinish = YES;
        }
    }else{
        [self displayView:view];
    }
}

@end
