//
//  FirstContentViewController.m
//  DopSideMenu
//
//  Created by oxape on 16/8/29.
//  Copyright © 2016年 oxape. All rights reserved.
//

#import "FirstContentViewController.h"
#import "UIViewController+DopSideMenu.h"

@interface FirstContentViewController ()

@end

@implementation FirstContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showMenu {
    [self.sideMenuViewController showMenuViewControllerAnimated:YES];
}

- (IBAction)hideMenu {
    [self.sideMenuViewController hideMenuViewControllerAnimated:YES];
}

@end
