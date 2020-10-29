//
//  DRTableViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/3.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRTableViewController.h"
#import "Drbox.h"

@interface DRTableViewController ()<DRTableViewDataSource, DRTableViewDelegate>

@property (nonatomic, strong) DRTableView *tableView;

@end

@implementation DRTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
    }];
    
    for (int i=0; i<5; i++) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = DRColorFromRGB(189-i*10, 220-i*20, 100-i*5);
        v.dr_layoutFinishBlock = ^(__kindof UIView * _Nonnull view) {
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = view.bounds.size.height/2.0;
        };
        [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
            layout.margin = DRPointValue(8);
            layout.flex = 1;
            layout.aspectRatio = 1;
        }];
        [headerView addSubview:v];
    }
    self.tableView.headerView = headerView;
    
    UIView *footerView = [[UIView alloc] init];
    [footerView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
    }];
    
    for (int i=0; i<5; i++) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = DRColorFromRGB(189-i*10, 220-i*20, 100-i*5);
        v.dr_layoutFinishBlock = ^(__kindof UIView * _Nonnull view) {
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = view.bounds.size.height/2.0;
        };
        [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
            layout.margin = DRPointValue(8);
            layout.flex = 1;
            layout.aspectRatio = 1;
        }];
        [footerView addSubview:v];
    }
    self.tableView.footerView = footerView;
}

- (void)loadView{
    DRTableView *tableView = [[DRTableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeightUniform = YES; // cell会采用异步布局
    self.view = tableView;
}
- (DRTableView *)tableView{
    return (DRTableView *)self.view;
}

#pragma mark - DRTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(DRTableView *)tableView{
    return 50;
}
- (NSInteger)tableView:(DRTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(DRTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIView *v = [[UIView alloc] init];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
    }];
    for (int i=0; i<5; i++) {
        UIView *sv = [[UIView alloc] init];
        sv.backgroundColor = DRColorFromRGB(189-i*10, 220-i*20, 100-i*5);
        [v addSubview:sv];
        [sv dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
            layout.margin = DRPointValue(8);
            layout.flex = 1;
            layout.height = DRPointValue(100);
        }];
    }
    return v;
}

#pragma mark - DRTableViewDelegate
- (UIView *)tableView:(DRTableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor blueColor];
    [header dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
        layout.padding = DRPointValue(8);
    }];
    UILabel *lb = [[UILabel alloc] init];
    lb.textColor = [UIColor redColor];
    lb.backgroundColor = [UIColor greenColor];
    lb.font = [UIFont systemFontOfSize:15];
    lb.text = [NSString stringWithFormat:@"this is header:%ld", section];
    [lb dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.height = DRPointValue(30);
    }];
    lb.dr_layoutFinishBlock = ^(UILabel * _Nonnull label) {
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = label.bounds.size.height/2.0;
    };
    [header addSubview:lb];
    return header;
}

- (void)tableView:(DRTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"-----点击secion:%ld,row:%ld", indexPath.section, indexPath.row);
}

@end
