//
//  DRKVOViewController.m
//  drbox
//
//  Created by dr.box on 2020/11/23.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRKVOViewController.h"
#import "Drbox.h"

@interface DRXPeople : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end
@implementation DRXPeople
@end

@interface DRKVOViewController (){
    
    NSString *_str;
    
    NSInteger _index;
}

@property (nonatomic, strong) DRXPeople *people;

@end

@implementation DRKVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.people = [[DRXPeople alloc] init];
    
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
    
    DRKVOBlock(self, @"_str", ^(NSString *str){
        NSLog(@"成员变量_str改变了：%@", str);
    });
    
    [self willChangeValueForKey:@"_str"];
    _str = @"111";
    [self didChangeValueForKey:@"_str"];
    
    [self setValue:@"ddd" forKey:@"_str"];
    
    [self setValue:@(1) forKey:@"_index"];
    
    NSLog(@"_index: %ld", _index);
    _index = _index + 10;
    NSLog(@"_index: %@", [self valueForKey:@"_index"]);
    
}

- (void)printPeopleInfo{
    NSLog(@"姓名：%@, 年龄：%ld", self.people.name, self.people.age);
}

@end
