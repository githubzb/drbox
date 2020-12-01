//
//  DRKVOViewController.m
//  drbox
//
//  Created by dr.box on 2020/11/23.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRKVOViewController.h"
#import "Drbox.h"

@interface DRPeople : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end
@implementation DRPeople
@end

@interface DRKVOViewController ()

@property (nonatomic, strong) DRPeople *people;

@end

@implementation DRKVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.people = [[DRPeople alloc] init];
    
    DRKVOBlock(self, @"people.name", ^(NSString *name){
        NSLog(@"名字改变了:%@", name);
    });
    DRKVOBlock(self, @"people.age", ^(NSString *name){
        NSLog(@"年龄改变了:%@", name);
    });
    DRKVOAction(self, @"people.name", self, printPeopleInfo);
    DRKVOAction(self, @"people.age", self, printPeopleInfo);
    
    self.people.name = @"zhang san";
    self.people.age = 30;
}

- (void)printPeopleInfo{
    NSLog(@"姓名：%@, 年龄：%ld", self.people.name, self.people.age);
}

@end