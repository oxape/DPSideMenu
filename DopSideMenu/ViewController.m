//
//  ViewController.m
//  DopSideMenu
//
//  Created by oxape on 16/8/28.
//  Copyright © 2016年 oxape. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
