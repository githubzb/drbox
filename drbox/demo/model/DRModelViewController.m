//
//  DRModelViewController.m
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRModelViewController.h"
#import "DRUserInfo.h"
#import "NSObject+DRModel.h"

@interface DRModelViewController (){
    
    CGRect _rect;
}

@property (nonatomic, readonly) NSString *name;

@end

@implementation DRModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dic = @{
        @"userInfo": @{@"name":
                           @{@"first": @"zhang", @"second": @"san"},
                        @"age": @35,
                       @"birthday": @"1970-08-23",
                       @"job": @{
                                    @"job_company": @"beijing drbox",
                                    @"job_post": @"ios developer",
                                    @"address": @"beijng chaoyang dawanglu"},
                       @"hobbys": @[@"smoking", @"drink", @"perm"],
                       @"headerUrl": @"https://www.baidu.com/aa/bb/头像.jpg"
        },
        @"car": @{@"name": @"jeep"},
        @"familys": @{
            @"mother": @{@"full_name": @{@"first": @"xia", @"second": @"yu"}, @"age": @34, @"birthday": @"1971-08-23"},
            @"son": @{@"full_name": @{@"first": @"zhang", @"second": @"yu"}, @"age": @4, @"birthday": @"2018-08-23"},
            @"girl": @{@"full_name": @{@"first": @"zhang", @"second": @"xia"}, @"age": @3, @"birthday": @"2019-08-23"}
        },
        @"tokenInfo": @{@"token": @"232de23evefwf232fewfwe", @"deadline": @23243432143}
    };
    DRUserInfo *info = [DRUserInfo dr_modelWithDictionary:dic];
    NSLog(@"info: %@", info);
    
    NSDictionary *userInfoDic = [info dr_modelToJSONObject];
    
    DRUserInfo *info2 = [DRUserInfo dr_modelWithDictionary:userInfoDic];
    NSLog(@"info2: %@", info2);
    
    
    DRUserInfo *info3 = [info2 dr_copy];
    NSLog(@"info3: %@", info3);
}




@end
