//
//  DopSideMenu.h
//  DopSideMenu
//
//  Created by oxape on 16/8/28.
//  Copyright © 2016年 oxape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DopSideMenu : UIViewController

@property (nonatomic, strong) UIViewController *menuViewController;
@property (nonatomic, strong) UIViewController *contentViewController;
@property (assign, readwrite, nonatomic) IBInspectable CGFloat contentViewInShowMenuOffsetLeft;


- (void)showMenuViewControllerAnimated:(BOOL)animated;
- (void)hideMenuViewControllerAnimated:(BOOL)animated;

@end
