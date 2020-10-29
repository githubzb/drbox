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
                                    error:(NSError *__autoreleasing  _Nullable *)error{
    NSData *data = nil;
    if (@available(iOS 11.0, *)) {
        data = [self archivedDataWithRootObject:rootObject
                          requiringSecureCoding:YES
                                          error:error];
    } else {
        @try {
            data = [self archivedDataWithRootObject:rootObject];
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
                       error:(NSError *__autoreleasing  _Nullable *)error{
    BOOL res = NO;
    if (@available(iOS 11.0, *)) {
        NSData *data = [self archivedDataWithRootObject:rootObject
                                  requiringSecureCoding:YES
                                                  error:error];
        if (data.length) {
            res = [data writeToFile:path
                            options:NSDataWritingAtomic
                              error:error];
        }
    } else {
        @try {
            res = [self archiveRootObject:rootObject toFile:path];
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
