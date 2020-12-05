//
//  DRTestViewController.m
//  drbox
//
//  Created by dr.box on 2020/11/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRTestViewController.h"
#import "Drbox.h"

@interface DRObj : NSObject

@property (nonatomic, copy) NSString *name;

@end
@implementation DRObj
@end

@interface DRTestViewController (){
    
}

@property (nonatomic, strong) NSMutableArray<DRObj *> *list;
@property (nonatomic, strong) NSMutableSet *myset;

@end

@implementation DRTestViewController

- (void)dealloc{
    NSLog(@"DRTestViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.list = [[NSMutableArray alloc] init];
    
    [self addObserver:self
           forKeyPath:@"list"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
    DRObj *obj1 = [[DRObj alloc] init];
    obj1.name = @"aaa";
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:0] forKey:@"list"];
    [self.list insertObject:obj1 atIndex:0];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:0] forKey:@"list"];

    
    DRObj *obj2 = [[DRObj alloc] init];
    obj2.name = @"bbb";
    [self.list insertObject:obj2 atIndex:1];
    
    
//    NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
//    [self.list addObserver:self
//        toObjectsAtIndexes:set
//                forKeyPath:@"name"
//                   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
//                   context:NULL];
//
//    obj1.name = @"222";
    
    
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context{
    NSLog(@"%@", object);
    NSLog(@"--:%@", change);
}

@end
