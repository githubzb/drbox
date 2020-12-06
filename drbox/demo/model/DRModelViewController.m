//
//  DRModelViewController.m
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRModelViewController.h"
#import "Drbox.h"
#import "DRUserInfo.h"
#import "DRClassInfo.h"
#import "NSObject+DRModel.h"
#import <objc/message.h>

@interface DRModelViewController (){
    
    CGRect _rect;
}

@property (nonatomic, readonly) NSString *name;

@end

@implementation DRModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DRUserInfo *info = [DRUserInfo modelWithDictionary:@{@"name": @"zangsan", @"age": @30, @"headerUrl": @"https://www.baidu.com", @"car": @{@"name": @"jeep"}}];
//    NSLog(@"info: %@", info);
    
}




@end
