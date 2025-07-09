/* 
    Copyright (C) 2025  Serge Alagon

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>. 
*/

#import "AppSceneView.h"

@interface AppSceneView()
@property (nonatomic, strong) FBScene *scene;
@property (nonatomic) _UIScenePresenter *presenter;
@property (nonatomic, strong) UIButton *minimizeButton;
@property (nonatomic) UIMutableApplicationSceneSettings *settings;
@end

@implementation AppSceneView
- (instancetype)initWithScene:(FBScene *)scene withSettings:(UIMutableApplicationSceneSettings *)settings {
    self = [super initWithFrame:CGRectZero]; 
    if (self) {
        self.scene = scene;
        self.settings = settings;

        [self setupView];
        [self setupMinimizeButton];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        [self fixRotation];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor purpleColor];

    UILabel *sceneLabel = [[UILabel alloc] init];
    sceneLabel.text = @"If you're seeing this, it's either\n-The app only supports a single scene, and you can use the app directly as it is already immortalized\n-Or, it was terminated.";
    sceneLabel.textColor = [UIColor whiteColor];
    sceneLabel.textAlignment = NSTextAlignmentCenter;
    sceneLabel.font = [UIFont systemFontOfSize:20];
    sceneLabel.numberOfLines = 0;
    sceneLabel.lineBreakMode = NSLineBreakByWordWrapping; // Wrap by words

    sceneLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self insertSubview:sceneLabel atIndex:0];

    [NSLayoutConstraint activateConstraints:@[
        [sceneLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [sceneLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [sceneLabel.widthAnchor constraintLessThanOrEqualToConstant:220], 
        [sceneLabel.heightAnchor constraintGreaterThanOrEqualToConstant:0] 
    ]];
    [self showMainScenePresenter];

}

- (void)showMainScenePresenter {
    UIApplicationSceneTransitionContext *transitionContext = [UIApplicationSceneTransitionContext new];
    [self.scene updateSettings:self.settings withTransitionContext:transitionContext completion:nil];

    self.presenter = [self.scene.uiPresentationManager createPresenterWithIdentifier:self.scene.identifier];
    [self.presenter activate];
    [self insertSubview:self.presenter.presentationView atIndex:1];
}

- (NSString *)getBundleIdBySceneIdentifier:(NSString *)sceneIdentifier {
    if ([sceneIdentifier hasPrefix:@"sceneID:"]) {
        NSString *bundleIdPart = [sceneIdentifier substringFromIndex:[@"sceneID:" length]];
        NSArray *components = [bundleIdPart componentsSeparatedByString:@"-"];
        if (components.count > 0) {
            return components[0];
        }
    }
    return nil;
}

- (void)minimizeView {
    NSString *bundleId = [self getBundleIdBySceneIdentifier:self.scene.identifier];
    [self.delegate removePresentedSceneByBundleId:bundleId];
    CGRect finalFrame = self.frame;
    finalFrame.origin.y += self.frame.size.height;
    self.settings.interfaceOrientation = UIInterfaceOrientationPortrait;

    [UIView animateWithDuration:0.4 animations:^{
        self.frame = finalFrame;
        if (self.presenter) {
            [self.presenter deactivate];
            [self.presenter invalidate];
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setupMinimizeButton {
    self.minimizeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    UIImage *minimizeIcon = [UIImage systemImageNamed:@"chevron.down.circle"];
    [self.minimizeButton setImage:minimizeIcon forState:UIControlStateNormal];
    [self.minimizeButton setTintColor:[UIColor cyanColor]];
    
    self.minimizeButton.backgroundColor = [UIColor darkGrayColor];
    self.minimizeButton.layer.cornerRadius = 20;
    self.minimizeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.minimizeButton addTarget:self 
                            action:@selector(minimizeView) 
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self insertSubview:self.minimizeButton atIndex:5];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.minimizeButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:20],
        [self.minimizeButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.minimizeButton.widthAnchor constraintEqualToConstant:40],
        [self.minimizeButton.heightAnchor constraintEqualToConstant:40]
    ]];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMinimizeButtonPan:)];
    [self.minimizeButton addGestureRecognizer:panGesture];
}

- (void)handleMinimizeButtonPan:(UIPanGestureRecognizer *)gesture {
    static CGPoint lastPanPoint;
    CGPoint translation = [gesture translationInView:self.minimizeButton.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastPanPoint = self.minimizeButton.center;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint newCenter = CGPointMake(lastPanPoint.x + translation.x, 
                                         lastPanPoint.y + translation.y);
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGFloat halfWidth = self.minimizeButton.bounds.size.width / 2;
        CGFloat halfHeight = self.minimizeButton.bounds.size.height / 2;
        
        newCenter.x = MAX(halfWidth, MIN(screenBounds.size.width - halfWidth, newCenter.x));
        newCenter.y = MAX(halfHeight, MIN(screenBounds.size.height - halfHeight, newCenter.y));
        
        self.minimizeButton.center = newCenter;
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self fixRotation];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)fixRotation {
    UIWindowScene *windowScene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes anyObject];
    self.settings.interfaceOrientation = windowScene.interfaceOrientation;

    UIApplicationSceneTransitionContext *transitionContext = [UIApplicationSceneTransitionContext new];
    [self.scene updateSettings:self.settings withTransitionContext:transitionContext completion:nil];
    self.presenter.presentationView.transform = CGAffineTransformMakeRotation(0.0); /* lock view rotation so no double rotation */
    self.presenter.presentationView.frame = CGRectMake(0,0, self.frame.size.width, self.frame.size.height);
}
@end
