//
//  NSURL+drbox.m
//  drbox
//
//  Created by DHY on 2021/1/11.
//  Copyright © 2021 @zb.drbox. All rights reserved.
//

#import "NSURL+drbox.h"
#import "NSString+drbox.h"

@implementation NSURL (drbox)

- (NSDictionary<NSString *,NSString *> *)dr_parameters{
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [components.percentEncodedQueryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dic setValue:obj.value forKey:obj.name];
    }];
    return [dic copy];
}

- (NSDictionary<NSString *,NSString *> *)dr_parametersForURLDecoding{
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dic setValue:obj.value forKey:obj.name];
    }];
    return [dic copy];
}

@end
