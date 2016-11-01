//
//  DopSideMenuView.m
//  DopSideMenu
//
//  Created by oxape on 16/8/28.
//  Copyright © 2016年 oxape. All rights reserved.
//

#import "DopSideMenuView.h"

@implementation DopSideMenuView

- (void)setNeedsLayout
{
    [super setNeedsLayout];
    NSLog(@"setNeedsLayout");
}

- (void)layoutIfNeeded
{
    [super layoutIfNeeded];
    NSLog(@"layoutIfNeeded");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
}

- (void)setNeedsUpdateConstraints
{
    [super setNeedsUpdateConstraints];
    NSLog(@"setNeedsUpdateConstraints");
}

- (void)updateConstraintsIfNeeded
{
    [super updateConstraintsIfNeeded];
    NSLog(@"updateConstraintsIfNeeded");
}

- (void)updateConstraints
{
    [super updateConstraints];
    NSLog(@"updateConstraints");
}


@end
