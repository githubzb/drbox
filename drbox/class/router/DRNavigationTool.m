//
//  DRNavigationTool.m
//  drbox
//
//  Created by DHY on 2020/12/21.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRNavigationTool.h"

static inline UIViewController * DRVisibleViewController(UIViewController *vc) {
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbar = (UITabBarController *)vc;
        NSInteger selectIndex = tabbar.selectedIndex;
        if (tabbar.viewControllers.count > selectIndex && selectIndex >= 0) {
            UIViewController *selectedViewController = tabbar.viewControllers[selectIndex];
            return DRVisibleViewController(selectedViewController);
        }
        if (tabbar.presentedViewController) {
            return DRVisibleViewController(tabbar.presentedViewController);
        }
        return tabbar;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return DRVisibleViewController(nav.topViewController);
    }
    if (vc.presentedViewController) {
        return DRVisibleViewController(vc.presentedViewController);
    }
    return vc;
}


@implementation DRNavigationTool

+ (UIViewController *)currentVisibleViewController{
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    return DRVisibleViewController(root);
}

+ (void)openViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIViewController *visibleVc = [self currentVisibleViewController];
    if (visibleVc.navigationController) {
        [visibleVc.navigationController pushViewController:viewController animated:animated];
    }else{
        [visibleVc presentViewController:viewController animated:animated completion:nil];
    }
}

@end
