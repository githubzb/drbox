//
//  ViewController.m
//  drbox
//
//  Created by dr.box on 2020/7/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSDictionary *list;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试";
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    NSDictionary *list = @{
        @"Macros": @[@{@"DrboxMacro": @"DrboxMacroViewController"}],
        @"Categories":@[@{@"FoundationCategory":@"DrFoundationCategoryViewController"},
                        @{@"UIColor": @"DRColorViewController"},
                        @{@"UIImage": @"DRImageViewController"},
                        @{@"UIControl": @"DRUIControlViewController"},
                        @{@"UIGestureRecognizer": @"DRGestureViewController"},
                        @{@"UITextField": @"DRTextFieldViewController"},
                        @{@"test": @"DRTestViewController"},
                        @{@"notification": @"DRLocalNotificationViewController"}],
        @"tools": @[@{@"DRDictionaryParser": @"DRXMLParserViewController"},
                    @{@"DRUnfairLock": @"DRUnfairLockViewController"},
                    @{@"DRCGTools": @"DRCGToolsViewController"},
                    @{@"DRBlockDescription": @"DRBlockDescViewController"},
                    @{@"DRKeyChainStore": @"DRKeyChainsViewController"},
                    @{@"video": @"DRVideoViewController"},
                    @{@"KVO": @"DRKVOViewController"}],
        @"layout": @[@{@"DRLayout": @"DRLayoutViewController"},
                     @{@"UIScrollView+DRLayout": @"DRScrollViewController"},
                     @{@"DRTableView": @"DRTableViewController"}],
        @"cache": @[@{@"cache": @"DRCacheViewController"},],
        @"network": @[@{@"Session": @"DRURLSessionViewController"}]
    };
    self.list = list;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = self.list.allKeys[section];
    return [(NSArray *)self.list[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSString *key = self.list.allKeys[indexPath.section];
    NSDictionary *dic = ((NSArray *)self.list[key])[indexPath.row];
    cell.textLabel.text = [dic.allKeys firstObject];
    cell.textLabel.textColor = [UIColor blueColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *key = self.list.allKeys[section];
    return key;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key = self.list.allKeys[indexPath.section];
    NSDictionary *dic = ((NSArray *)self.list[key])[indexPath.row];
    NSString *vcName = [dic.allValues firstObject];
    UIViewController *vc = [[NSClassFromString(vcName) alloc] init];
    vc.title = [dic.allKeys firstObject];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
