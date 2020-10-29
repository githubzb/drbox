//
//  NSKeyedUnarchiver+drbox.m
//  drbox
//
//  Created by dr.box on 2020/8/13.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSKeyedUnarchiver+drbox.h"


@implementation NSKeyedUnarchiver (drbox)

+ (id)dr_unarchivedObjectOfClass:(Class)cls
                        fromData:(NSData *)data
                           error:(NSError * _Nullable __autoreleasing *)error{
    id obj = nil;
    if (@available(iOS 11.0, *)) {
        obj = [self unarchivedObjectOfClass:cls
                                   fromData:data
                                      error:error];
    }else{
        @try {
            obj = [self unarchiveObjectWithData:data];
        } @catch (NSException *exception) {
            if (error) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:4866
                                         userInfo:exception.userInfo];
            }
        }
    }
    return obj;
}

+ (id)dr_unarchiveObjectOfClass:(Class)cls
                   withFilePath:(NSString *)path
                          error:(NSError * _Nullable __autoreleasing *)error{
    id obj = nil;
    if (@available(iOS 11.0, *)) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            if (error) {
                NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"文件不存在 for path"};
                *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:0
                                         userInfo:userInfo];
            }
            return nil;
        }
        NSData *data = [NSData dataWithContentsOfFile:path];
        obj = [self unarchivedObjectOfClass:cls
                                   fromData:data
                                      error:error];
    }else{
        @try {
            obj = [self unarchiveObjectWithFile:path];
        } @catch (NSException *exception) {
            if (error) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:4866
                                         userInfo:exception.userInfo];
            }
        }
    }
    return obj;
}

@end
