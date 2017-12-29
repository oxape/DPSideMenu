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
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, assign) BOOL showMenu;
@property (nonatomic, assign) BOOL menuVisible;

@property (nonatomic, strong) UIGestureRecognizer *recognizer;

@property (nonatomic, assign) CFTimeInterval pausedTime;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat percent;

@end

@implementation DopSideMenu

- (instancetype)init
{
    self = [super init];
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
    
    self.animationDuration = 0.25;
}

- (void)loadView
{
//    [super loadView];//父类方法默认提供一个UIView给视图控制器,自己提供则不要调用父类方法
    self.view = [[DopSideMenuView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    if (self.menuViewController) {
        [self addChildViewController:self.menuViewController];
        self.menuViewController.view.frame = self.menuViewContainer.frame;
        self.menuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.menuViewController.view];
        [self.menuViewController didMoveToParentViewController:self];
    }
    if (self.contentViewController) {
        [self addChildViewController:self.contentViewController];
        self.contentViewController.view.frame = self.contentViewContainer.frame;
        self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentViewContainer addSubview:self.contentViewController.view];
        [self.contentViewController didMoveToParentViewController:self];
    }
    
    [self.view setNeedsUpdateConstraints];
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
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
        [contentViewController.view addGestureRecognizer:recognizer];
        self.recognizer = recognizer;
        if(!self.showMenu) {
            self.recognizer.enabled = NO;
        }
        return;
    }
    [self hideViewController:_contentViewController];
    _contentViewController = contentViewController;
    
    [self addChildViewController:contentViewController];
    self.contentViewController.view.frame = self.contentViewContainer.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    [contentViewController.view addGestureRecognizer:recognizer];
    self.recognizer = recognizer;
    if(!self.showMenu) {
        self.recognizer.enabled = NO;
    }
}

#pragma mark - Action Method

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:self.view];
    NSLog(@"state = %ld", recognizer.state);
    if(recognizer.state == UIGestureRecognizerStateBegan){
        self.showMenu = NO;
        self.menuVisible = NO;
        CFTimeInterval pausedTime = [self.view.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        //只在这里使用过self.pausedTime，暂时没有其他用处
        self.pausedTime = pausedTime;
        self.view.layer.speed = 0.0;
        self.view.layer.timeOffset = 0;
        self.beginPoint = [recognizer locationOfTouch:0 inView:self.view]; // the location of a particular touch];
        [UIView animateWithDuration:self.animationDuration animations:^{
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
        }];
        
        [UIView commitAnimations];
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        CGFloat offset = 0;
        
        point = [recognizer locationOfTouch:0 inView:self.view];
        offset = self.beginPoint.x-point.x;
        CGFloat persent = (self.beginPoint.x-point.x)/(ABS(self.beginPoint.x));
        
        persent = ABS(persent);
        if (persent > 1) {
            persent = 1;
        }
        persent = persent;
        self.view.layer.timeOffset = 0 + persent*self.animationDuration;
        self.percent = persent;
    }else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed){
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
        displayLink.paused = NO;
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)displayLinkTick:(CADisplayLink *)link {
    //0.5作为门限
    if (self.percent > 0.5) {
        self.percent += link.duration/self.animationDuration;
    } else {
        self.percent -= link.duration/self.animationDuration;
    }
    if(self.percent < 0) {
        //这里为操作取消的处理
        self.percent = 0;
        //为了避免闪屏,暂时不会闪屏先注释
//        UIView *snapshot = [self.view snapshotViewAfterScreenUpdates:NO];
//        [self.view addSubview:snapshot];
//        [snapshot performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1/60];
        [link invalidate];
        self.view.layer.speed = 1;
        [self showMenuViewControllerAnimated:NO];
    } else if (self.percent > 1) {
        self.percent = 1;
        [link invalidate];
        self.view.layer.speed = 1;
        self.recognizer.enabled = NO;
    }
    self.view.layer.timeOffset = self.percent * self.animationDuration;
}

#pragma mark - Public Method

- (void)showMenuViewControllerAnimated:(BOOL)animated
{
    self.showMenu = YES;
    if (animated) {
        [UIView animateWithDuration:self.animationDuration animations:^{
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.menuVisible = YES;
            self.recognizer.enabled = YES;
        }];
    } else {
        self.menuVisible = YES;
        self.recognizer.enabled = YES;
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
}

- (void)hideMenuViewControllerAnimated:(BOOL)animated
{
    self.showMenu = NO;
    self.menuVisible = NO;
    self.recognizer.enabled = NO;
    if (animated) {
        [UIView animateWithDuration:self.animationDuration animations:^{
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Lazy init
- (NSMutableArray *)constraints
{
    if (!_constraints) {
        _constraints = [[NSMutableArray alloc] init];
    }
    
    return _constraints;
}



@end
