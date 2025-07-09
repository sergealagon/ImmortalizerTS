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

#import "ExternalAppSceneView.h"
#include <notify.h>

@interface ExternalAppSceneView() {
    int _notifyToken;
}
@property (nonatomic, strong) FBScene *scene;
@property (nonatomic) UIMutableApplicationSceneSettings *settings;
@property (nonatomic) UIRootWindowScenePresentationBinder *windowSceneBinder;
@property (nonatomic) _UIScenePresentationView *uiScenePresentationView;
@property (nonatomic) NSString *appName;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIView *titleBar;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) UIButton *rotateButton;
@property(nonatomic) UIView *resizer;
@property (nonatomic) CGFloat currentRotationAngle;
@end

@implementation ExternalAppSceneView
- (instancetype)initExternalWindowWithScene:(FBScene *)scene withAppName:(NSString *)appName withSettings:(UIMutableApplicationSceneSettings *)settings {
    self = [super initWithFrame:CGRectZero]; 
    if (self) { 
        self.scene = scene;
        self.appName = appName;
        self.settings = settings;
        self.currentRotationAngle = 0;

        [self presentSceneExternally];
    }
    return self;
}

- (void)presentSceneExternally {
    self.windowSceneBinder = [[UIRootWindowScenePresentationBinder alloc] initWithPriority:0 displayConfiguration:self.settings.displayConfiguration];
    [self.windowSceneBinder addScene:self.scene];

    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat windowWidth = MIN(250, screenBounds.size.width * 0.8);
    CGFloat windowHeight = MIN(200, screenBounds.size.height * 0.7);
    CGFloat windowX = (screenBounds.size.width - windowWidth) / 2;
    CGFloat windowY = (screenBounds.size.height - windowHeight) / 2;

    /* hiearchy: UIRootSceneWindow -> UIView (_sceneContainerView) (mainScreen bounds) -> UIView _UIScenePresentationView -> _UISceneLayerHostContainerView*/
    UIRootSceneWindow *rootWindow = [self.windowSceneBinder valueForKey:@"_rootSceneWindow"];
    rootWindow.backgroundColor = [UIColor clearColor];

    self.uiScenePresentationView = rootWindow._sceneContainerView.subviews[0]; //_UIScenePresentationView

    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(windowX, windowY, windowWidth, windowHeight + 44)];
    self.containerView.backgroundColor = [UIColor grayColor];

    UILabel *sceneLabel = [[UILabel alloc] init];
    sceneLabel.text = @"If you're seeing this, the app is single scene. Unsupported. Or, terminated.";
    sceneLabel.textColor = [UIColor whiteColor];
    sceneLabel.textAlignment = NSTextAlignmentCenter;
    sceneLabel.font = [UIFont systemFontOfSize:12];
    sceneLabel.numberOfLines = 0; // Allow unlimited lines
    sceneLabel.lineBreakMode = NSLineBreakByWordWrapping; // Wrap by words
    sceneLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:sceneLabel];
    [NSLayoutConstraint activateConstraints:@[
        [sceneLabel.centerXAnchor constraintEqualToAnchor:self.containerView.centerXAnchor],
        [sceneLabel.centerYAnchor constraintEqualToAnchor:self.containerView.centerYAnchor],
        [sceneLabel.widthAnchor constraintLessThanOrEqualToConstant:220], // Set a maximum width
        [sceneLabel.heightAnchor constraintGreaterThanOrEqualToConstant:0] // Ensure height is at least 0
    ]];

    self.containerView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.containerView.layer.borderWidth = 1.0;
    self.containerView.layer.cornerRadius = 12;
    self.containerView.clipsToBounds = YES;
    [rootWindow._sceneContainerView addSubview:self.containerView];
    [self.uiScenePresentationView removeFromSuperview];
    [self.containerView addSubview: self.uiScenePresentationView];

    self.settings.frame = CGRectMake(0, 44, windowWidth, windowHeight);

    UIApplicationSceneTransitionContext *transitionContext = [UIApplicationSceneTransitionContext new];
    [self.scene updateSettings:self.settings withTransitionContext:transitionContext completion:nil];

    self.titleBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.bounds.size.width, 44)];
    self.titleBar.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.9];
    self.titleBar.tag = 9999; // Tag to identify our title bar
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.containerView.bounds.size.width - 32, 44)];
    self.titleLabel.text = self.appName;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleBar addSubview:self.titleLabel];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.titleBar.bounds.size.width - 40, 8, 28, 28)];
    self.closeButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0];
    self.closeButton.layer.cornerRadius = 14;
    [self.closeButton setTitle:@"×" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.closeButton.self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.closeButton addTarget:self action:@selector(closeWindow:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleBar addSubview:self.closeButton];

    self.rotateButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 8, 28, 28)];
    self.rotateButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0];
    self.rotateButton.layer.cornerRadius = 14;
    [self.rotateButton setTitle:@"⟲" forState:UIControlStateNormal];
    [self.rotateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rotateButton.self.titleLabel.font = [UIFont boldSystemFontOfSize:23];
    [self.rotateButton addTarget:self action:@selector(rotateWindow:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleBar addSubview:self.rotateButton];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleWindowPan:)];
    [self.titleBar addGestureRecognizer:panGesture];
    
    self.resizer = [[UIView alloc] initWithFrame:CGRectMake(self.containerView.bounds.size.width - 25, self.containerView.bounds.size.height - 25, 55, 55)];
    self.resizer.backgroundColor = [UIColor whiteColor]; // Change color for visibility
    self.resizer.alpha = 0.5;
    self.resizer.userInteractionEnabled = YES;

    CGFloat resizerAngle = 45.0 * (M_PI / 180.0);
    self.resizer.transform = CGAffineTransformRotate(self.resizer.transform, resizerAngle);

    UIPanGestureRecognizer *resizePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizePan:)];
    [self.resizer addGestureRecognizer:resizePanGesture];

    [self.containerView addSubview:self.titleBar];
    [self.containerView addSubview:self.resizer];

    notify_register_dispatch("com.apple.springboard.lockstate", &_notifyToken,dispatch_get_main_queue(), ^(int token) {
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        if(state == 1) {
            [self closeWindow:nil];
        } 
    });
  
}

- (void)rotateWindow:(UIButton *)sender {
    if (self.currentRotationAngle == 0) {
        self.currentRotationAngle = 90;
    } else if (self.currentRotationAngle == 90) {
        self.currentRotationAngle = -90;
    } else {
        self.currentRotationAngle = 0;
    }

    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(self.currentRotationAngle * M_PI / 180.0);
    
    [UIView animateWithDuration:0.3 animations:^{
        UIRootSceneWindow *rootWindow = [self.windowSceneBinder valueForKey:@"_rootSceneWindow"];
        rootWindow.transform = rotationTransform;
    }];
}

- (void)handleResizePan:(UIPanGestureRecognizer *)gesture {
    self.resizer.transform = CGAffineTransformIdentity; //reset transform temporarily
    CGPoint translation = [gesture translationInView:self.resizer];
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGRect newFrame = self.containerView.frame;
        newFrame.size.width += translation.x;
        newFrame.size.height += translation.y;

        newFrame.size.width = MAX(newFrame.size.width, 200); 
        newFrame.size.height = MAX(newFrame.size.height, 200); 

        self.containerView.frame = newFrame;

        self.resizer.frame = CGRectMake(newFrame.size.width - 25, newFrame.size.height - 25, 55, 55); 
        [gesture setTranslation:CGPointZero inView:self.resizer]; 

        self.titleBar.frame = CGRectMake(0, 0, newFrame.size.width, 44);
        self.titleLabel.frame = CGRectMake(16, 0, self.titleBar.bounds.size.width - 32, 44);
        self.closeButton.frame = CGRectMake(self.titleBar.bounds.size.width - 40, 8, 28, 28);

        UIApplicationSceneTransitionContext *transitionContext = [UIApplicationSceneTransitionContext new];
        self.settings.frame = CGRectMake(0, 44, newFrame.size.width, newFrame.size.height - 44);

        [self.scene updateSettings:self.settings withTransitionContext:transitionContext completion:nil];

    }
    CGFloat resizerAngle = 45.0 * (M_PI / 180.0);
    self.resizer.transform = CGAffineTransformRotate(CGAffineTransformIdentity, resizerAngle);
}

- (void)handleWindowPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        /* cant find a way to reset hierarchy */
    }
    static CGPoint lastPanPoint;
    CGPoint translation = [gesture translationInView:self.containerView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastPanPoint = self.containerView.center;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint newCenter = CGPointMake(lastPanPoint.x + translation.x, 
                                         lastPanPoint.y + translation.y);
        
        self.containerView.center = newCenter;
    }
}

- (void)closeWindow:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        NSString *bundleId = [self getBundleIdBySceneIdentifier:self.scene.identifier];
        [self.delegate removePresentedSceneByBundleId:bundleId];
        self.uiScenePresentationView.alpha = 0;
        self.uiScenePresentationView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [self.windowSceneBinder invalidate];
    } completion:^(BOOL finished) {
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes anyObject];

        if(UIInterfaceOrientationIsLandscape(windowScene.interfaceOrientation)) {
            self.settings.frame = CGRectMake(0, 0, self.superview.frame.size.height, self.superview.frame.size.width);
        } else {
            self.settings.frame = CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);
        }
        UIApplicationSceneTransitionContext *transitionContext = [UIApplicationSceneTransitionContext new];
        [self.scene updateSettings:self.settings withTransitionContext:transitionContext completion:nil];
        notify_cancel(_notifyToken);
        [self removeFromSuperview];

    }];
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
@end