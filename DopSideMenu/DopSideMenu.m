//
//  DopSideMenu.m
//  DopSideMenu
//
//  Created by oxape on 16/8/28.
//  Copyright © 2016年 oxape. All rights reserved.
//

#import "DopSideMenu.h"
#import "DopSideMenuView.h"

@interface DopSideMenu ()

@property (nonatomic, strong) UIView *menuViewContainer;
@property (nonatomic, strong) UIView *contentViewContainer;
@property (nonatomic, strong) NSMutableArray *constraints;
@property (nonatomic, strong) NSLayoutConstraint *menuViewContainerConstaint;

@property (nonatomic, assign) BOOL showMenu;
@property (nonatomic, assign) BOOL menuVisible;
@property (nonatomic, assign) CFTimeInterval pausedTime;
@property (nonatomic, assign) CFTimeInterval beginTime;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat percent;

@end

@implementation DopSideMenu

- (instancetype)init
{
    self = [self init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder  //从storyboard初始化会调用这个方法，不会调用init
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _menuViewContainer = [[UIView alloc] init];
    _contentViewContainer = [[UIView alloc] init];
    _contentViewInShowMenuOffsetLeft = 60.f;
}

- (void)loadView
{
//    [super loadView];//父类方法我默认提供一个UIView给视图控制器,自己提供则不要调用父类方法
    self.view = [[DopSideMenuView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    [self addChildViewController:self.menuViewController];
    self.menuViewController.view.frame = self.menuViewContainer.frame;
    self.menuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.menuViewController.view];
    [self.menuViewController didMoveToParentViewController:self];
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.contentViewContainer.frame;
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)hideViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)setMenuViewController:(UIViewController *)menuViewController
{
    _menuViewController = menuViewController;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        UIPanGestureRecognizer *recongnizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
        [contentViewController.view addGestureRecognizer:recongnizer];
        return;
    }
    [self hideViewController:_contentViewController];
    _contentViewController = contentViewController;
    
    [self addChildViewController:contentViewController];
    self.contentViewController.view.frame = self.contentViewContainer.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    UIPanGestureRecognizer *recongnizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    [contentViewController.view addGestureRecognizer:recongnizer];
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:self.view];
    NSLog(@"state = %ld", recognizer.state);
    if(recognizer.state == UIGestureRecognizerStateBegan){
        self.showMenu = NO;
        self.menuVisible = NO;
        CFTimeInterval pausedTime = [self.view.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        NSLog(@"pausedTime = %.2f", pausedTime);
        self.view.layer.speed = 0.0;
        self.view.layer.timeOffset = 0;
        self.pausedTime = pausedTime;
        self.beginPoint = [recognizer locationOfTouch:0 inView:self.view]; // the location of a particular touch];
        [UIView  beginAnimations:@"move" context:nil];
        [UIView setAnimationDuration:3.0];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView animateWithDuration:3.0 animations:^{
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
//        }];
        
        [UIView commitAnimations];
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        CGFloat offset = 0;
        
        point = [recognizer locationOfTouch:0 inView:self.view];
        offset = self.beginPoint.x-point.x;
        CGFloat persent = (self.beginPoint.x-point.x)/(ABS(self.beginPoint.x));
        
        
//        if (persent > 0) {
//            persent = 0;
//        }
        persent = ABS(persent);
        if (persent > 1) {
            persent = 1;
        }
        NSLog(@"point.x = %.2f width = %.2f percent = %.2f", offset, self.beginPoint.x, persent);
        persent = persent*3;
        self.view.layer.timeOffset = 0 + persent;
        self.percent = persent;
    }else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed){
        CALayer *layer = self.view.layer;
        [layer removeAllAnimations];
        
        self.showMenu = YES;
        [self updateViewConstraints];
        [self.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
        self.showMenu = NO;
        [UIView  beginAnimations:@"move" context:nil];
        [UIView setAnimationDuration:3.0];
        //        [UIView setAnimationBeginsFromCurrentState:YES];
        //        [UIView animateWithDuration:3.0 animations:^{
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
        //        }];
        
        [UIView commitAnimations];
        layer.speed = 1.0;
        self.view.layer.timeOffset = 0;
        self.view.layer.timeOffset = self.percent;
        
        //以下三种方案
        //1
//        layer.timeOffset = persent;
//        [self stopAnimation:self.view];
//        [UIView  beginAnimations:@"move" context:nil];
//        [UIView setAnimationDuration:3.0];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        //        [UIView animateWithDuration:3.0 animations:^{
//        [self.view setNeedsUpdateConstraints];
//        [self.view layoutIfNeeded];
//        //        }];
//        
//        [UIView commitAnimations];
        //2
//        layer.timeOffset = 0.0;
//        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - self.pausedTime;
//        layer.beginTime = timeSincePause;
        //3
//        layer.timeOffset = 0.0;
//        layer.beginTime = 0.0;
//        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - self.pausedTime;
//        layer.beginTime = timeSincePause;
    }
}

-(void)pauseLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)stopAnimation:(UIView *)view
{
    [view.layer removeAllAnimations];
    for (UIView *subview in view.subviews) {
        [self stopAnimation:subview];
    }
}

- (void)updateViewConstraints
{
    NSLog(@"updateViewConstraints");
    [super updateViewConstraints];
    [self.view removeConstraints:self.constraints];
    
    [self.constraints removeAllObjects];
    self.menuViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_menuViewContainer]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_menuViewContainer)]];
    [self.constraints addObject:[NSLayoutConstraint constraintWithItem:self.menuViewContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:-self.contentViewInShowMenuOffsetLeft]];
    
    [self.constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentViewContainer]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentViewContainer)]];
    [self.constraints addObject:[NSLayoutConstraint constraintWithItem:self.contentViewContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    
    
    if (self.showMenu) {
        [self.constraints addObject:[NSLayoutConstraint constraintWithItem:self.menuViewContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        
        [self.constraints addObject:[NSLayoutConstraint constraintWithItem:self.contentViewContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.menuViewContainer attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    }else{
        [self.constraints addObject:[NSLayoutConstraint constraintWithItem:self.contentViewContainer attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        
        [self.constraints addObject:[NSLayoutConstraint constraintWithItem:self.menuViewContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:160]];
    }
    [self.view addConstraints:self.constraints];
}

- (void)showMenuViewController
{
    self.showMenu = YES;
    self.view.layer.speed = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.menuVisible = YES;
    }];
    self.view.layer.speed = 1;
    self.view.layer.beginTime = 0.25;
}

- (void)hideMenuViewController
{
    self.showMenu = NO;
    self.menuVisible = NO;
    self.view.layer.speed = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }];
    self.view.layer.speed = 1;
    self.view.layer.beginTime = 0.25;
}

- (NSMutableArray *)constraints
{
    if (!_constraints) {
        _constraints = [[NSMutableArray alloc] init];
    }
    
    return _constraints;
}

@end
