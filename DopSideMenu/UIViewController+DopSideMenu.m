//
//  UIViewController+DopSideMenu.m
//  DopSideMenu
//
//  Created by oxape on 16/8/28.
//  Copyright © 2016年 oxape. All rights reserved.
//

#import "UIViewController+DopSideMenu.h"

@implementation UIViewController (DopSideMenu)

- (DopSideMenu *)sideMenuViewController
{
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[DopSideMenu class]]) {
            return (DopSideMenu *)iter;
        } else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }
    return nil;
}

@end
