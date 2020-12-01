//
//  DRSandboxTool.m
//  drbox
//
//  Created by dr.box on 2020/11/8.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRSandboxTool.h"

@implementation DRSandboxTool

+ (NSString *)homePath{
    // 或者用这个 NSHomeDirectoryForUser(NSUserName()))
    return NSHomeDirectory();
}

+ (NSString *)documentsPath{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)libraryPath{
    return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)cachesPath{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)tmpPath{
    return NSTemporaryDirectory();
}

+ (NSString *)notifySoundsPath{
    NSString *path = DRSandboxTool.libraryPath;
    path = [path stringByAppendingPathComponent:@"Sounds"];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
#if DEBUG
            NSLog(@"创建Sounds目录时出错: %@", error);
#endif
            return nil;
        }
    }else{
        if (!isDir) {
            // 已存在名为：Sounds的文件，先删掉Sounds文件，再创建文件夹
            NSError *error;
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
#if DEBUG
            NSLog(@"已存在名为Sounds的文件，并不是目录，但试图删除时出错: %@", error);
#endif
                return nil;
            }
            if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:&error]) {
    #if DEBUG
                NSLog(@"创建Sounds目录时出错: %@", error);
    #endif
                return nil;
            }
        }
    }
    return path;
}

+ (NSString *)widgetSharePathWithGroupIdentifier:(NSString *)identifier{
    NSURL *url = [self widgetShareURLWithGroupIdentifier:identifier];
    if (!url) return nil;
    return url.absoluteString;
}

+ (NSURL *)widgetShareURLWithGroupIdentifier:(NSString *)identifier{
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:identifier];
}

+ (NSUserDefaults *)widgetShareUserDefaultsWithGroupIdentifier:(NSString *)identifier{
    return [[NSUserDefaults alloc] initWithSuiteName:identifier];
}

@end
