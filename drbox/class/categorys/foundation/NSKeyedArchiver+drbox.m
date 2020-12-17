//
//  NSKeyedArchiver+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/13.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSKeyedArchiver+drbox.h"

@implementation NSKeyedArchiver (drbox)

+ (NSData *)dr_archivedDataWithRootObject:(id)rootObject
                    requiringSecureCoding:(BOOL)requiringSecureCoding
                                    error:(NSError *__autoreleasing  _Nullable *)error{
    NSData *data = nil;
    if (@available(iOS 11.0, *)) {
        data = [self archivedDataWithRootObject:rootObject
                          requiringSecureCoding:requiringSecureCoding
                                          error:error];
    } else {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            data = [self archivedDataWithRootObject:rootObject];
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            if (error) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:4866
                                         userInfo:exception.userInfo];
            }
        }
    }
    return data;
}

+ (BOOL)dr_archiveRootObject:(id)rootObject
                      toFile:(NSString *)path
       requiringSecureCoding:(BOOL)requiringSecureCoding
                       error:(NSError *__autoreleasing  _Nullable *)error{
    BOOL res = NO;
    if (@available(iOS 11.0, *)) {
        NSData *data = [self archivedDataWithRootObject:rootObject
                                  requiringSecureCoding:requiringSecureCoding
                                                  error:error];
        if (data.length) {
            res = [data writeToFile:path
                            options:NSDataWritingAtomic
                              error:error];
        }
    } else {
        @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            res = [self archiveRootObject:rootObject toFile:path];
#pragma clang diagnostic pop
        } @catch (NSException *exception) {
            if (error) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:4866
                                         userInfo:exception.userInfo];
            }
        }
    }
    return res;
}

@end
