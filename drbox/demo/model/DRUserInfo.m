//
//  DRUserInfo.m
//  drbox
//
//  Created by DHY on 2020/12/5.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRUserInfo.h"

@implementation Car
@end

@implementation DRBaseInfo
@end

@implementation DRUserInfo

- (NSString *)description
{
    return [NSString stringWithFormat:@"{name: %@, age: %ld}", self.name, _age];
}

@end
