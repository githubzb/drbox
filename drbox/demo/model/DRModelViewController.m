//
//  DRModelViewController.m
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRModelViewController.h"
#import "DRUserInfo.h"
#import "Drbox.h"

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
        @"tokenInfo": @{@"token": @"232de23evefwf232fewfwe", @"deadline": @23243432143},
        @"point1": @"{100.23, 232.34}",
        @"point2": @"{200.23, 100.34}"
    };
    DRUserInfo *info = [DRUserInfo dr_modelWithDictionary:dic];
    NSLog(@"info: %@", info);
    
    NSDictionary *userInfoDic = [info dr_modelToJSONObject];
    
    DRUserInfo *info2 = [DRUserInfo dr_modelWithDictionary:userInfoDic];
    NSLog(@"info2: %@", info2);
    
    
    DRUserInfo *info3 = [info2 dr_copy];
    NSLog(@"info3: %@", info3);
    
    
    NSError *error;
    NSData *data = [NSKeyedArchiver dr_archivedDataWithRootObject:info3 requiringSecureCoding:YES error:&error];
    if (error) {
        NSLog(@"----归档失败：%@", error);
        return;
    }
    NSLog(@"%@", [data dr_utf8String]);
    DRUserInfo *info4 = [NSKeyedUnarchiver dr_unarchivedObjectOfClass:DRUserInfo.class
                                                             fromData:data
                                                                error:&error];
    if (error) {
        NSLog(@"解档失败：%@", error);
        return;
    }
    NSLog(@"接档数据：%@", info4);
    
    NSArray *peopleList = @[
        @{@"first": @"xia", @"second": @"yu", @"age": @34, @"birthday": @"1971-08-23"},
        @{@"first": @"xia", @"second": @"yu", @"age": @34, @"birthday": @"1971-08-23"}
    ];
    NSArray *peopleModels = [NSArray dr_modelArrayWithClass:DRPeople.class array:peopleList];
    NSLog(@"peopleModels: %@", peopleModels);
    
}




@end
