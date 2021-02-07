//
//  DRDeallocTest.m
//  drbox
//
//  Created by DHY on 2021/2/7.
//  Copyright © 2021 @zb.drbox. All rights reserved.
//

#import "DRDeallocTest.h"

@implementation DRDeallocTest

- (void)dealloc
{
    NSLog(@"-----DRDeallocTest：%p", self);
}

@end
