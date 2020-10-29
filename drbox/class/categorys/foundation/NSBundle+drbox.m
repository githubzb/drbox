//
//  NSBundle+drbox.m
//  drbox
//
//  Created by dr.box on 2020/9/19.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "NSBundle+drbox.h"

@implementation NSBundle (drbox)

+ (NSString *)dr_appVersion{
    return [[[self mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)dr_bundleIdentifier{
    return [self mainBundle].bundleIdentifier;
}

+ (NSString *)dr_bundleName{
    return [[[self mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (NSArray<NSString *> *)dr_supportedInterfaceOrientations{
    
    return [[[self mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
}

+ (UIInterfaceOrientation)dr_convertOrientationWithString:(NSString *)str{
    if (!str) return UIInterfaceOrientationUnknown;
    NSNumber *num = [@{@"UIInterfaceOrientationUnknown":@(UIInterfaceOrientationUnknown),
                      @"UIInterfaceOrientationPortrait":@(UIInterfaceOrientationPortrait),
                      @"UIInterfaceOrientationPortraitUpsideDown":@(UIInterfaceOrientationPortraitUpsideDown),
                      @"UIInterfaceOrientationLandscapeLeft":@(UIInterfaceOrientationLandscapeLeft),
                      @"UIInterfaceOrientationLandscapeRight":@(UIInterfaceOrientationLandscapeRight)} objectForKey:str];
    if (!num) return UIInterfaceOrientationUnknown;
    return [num integerValue];
}

@end
