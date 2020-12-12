//
//  AppDelegate.m
//  drbox
//
//  Created by dr.box on 2020/7/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <objc/runtime.h>
#import "DRClassInfo.h"

@interface AppDelegate (){
    
    SEL _sel;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    window.backgroundColor = [UIColor whiteColor];
    ViewController *vc = [[ViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
    
    DRClassInfo *info = [DRClassInfo infoWithClass:self.class];
    for (DRClassIvarInfo *ivar in [info.ivarInfos allValues]) {
        if ([ivar.name isEqualToString:@"_sel"]) {
            object_setIvar(self, ivar.ivar, @"aaa:");
        }
    }
    
    NSLog(@"---:%@", NSStringFromSelector(_sel));
    
    return YES;
}

@end
