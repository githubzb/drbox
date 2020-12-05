//
//  DRUserInfo.m
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRUserInfo.h"

@implementation DRUserInfo

- (NSString *)description
{
    return [NSString stringWithFormat:@"{name: %@, age: %ld}", _name, _age];
}

@end
