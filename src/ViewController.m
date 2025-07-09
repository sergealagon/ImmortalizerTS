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

#import "ViewController.h"
#import "AppSceneCell.h"
#import "CustomToastView.h"

@interface ViewController ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<LSApplicationProxy *> *selectedApps;
@property (nonatomic, strong) NSMutableDictionary<NSString *, FBScene *> *scenesByBundleId;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIMutableApplicationSceneSettings *> *scenesSettingsByBundleId;
@property (nonatomic, strong) AppSceneView *currentSceneView;
@property (nonatomic, strong) UIRootSceneWindow *rootWindow;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.selectedApps = [[NSMutableArray alloc] init];
    self.scenesByBundleId = [NSMutableDictionary dictionary];
    self.scenesSettingsByBundleId = [NSMutableDictionary dictionary];
    self.activePresentedScenesByBundleId = [[NSMutableArray alloc] init];
    [self setupNavigationBar];
    [self setupCollectionView];
}

- (void)setupNavigationBar {
    self.title = @"Immortalizer";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                 target:self 
                                 action:@selector(addButtonTapped)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(150, 180);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.collectionView registerClass:[AppSceneCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:self.collectionView];

    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleCollectionItemLongPress:)];
    [self.collectionView addGestureRecognizer:longPressGesture];

    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

- (void)addButtonTapped {
    AppSelectionViewController *selectionVC = [[AppSelectionViewController alloc] init];
    selectionVC.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:selectionVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedApps.count;
}

- (void)addPresentedSceneByBundleId:(NSString *)bundleId {
    [self.activePresentedScenesByBundleId addObject:bundleId];
}

- (void)removePresentedSceneByBundleId:(NSString *)bundleId {
    [self.activePresentedScenesByBundleId removeObject:bundleId];
}

/* adding an appscenecell from selectionviewcontroller */
- (void)didSelectApp:(LSApplicationProxy *)app {
    
    /* Check if the app is already selected */
    if ([self.selectedApps containsObject:app]) {
        NSUInteger index = [self.selectedApps indexOfObject:app];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        AppSceneCell *cell = (AppSceneCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self highlightAndShakeCell:cell];
        return;
    }

    /* in case some bored people try to immortalize self lol */
    if ([app.bundleIdentifier containsString:[[NSBundle mainBundle] bundleIdentifier]]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Nice Try!"
                                                                        message:@"Bro, why would you even dare to try that?!"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ooops!" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        }];

        [alertController addAction:okAction];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [self initializeNewSceneForBundleId:app firstLaunch:YES];
    [self.selectedApps addObject:app];
    [self.collectionView reloadData];
    
}

/* Adds AppSceneCell */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AppSceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    LSApplicationProxy *app = self.selectedApps[indexPath.item];
    [cell configureAppSceneCellDetails:app];

    /* close */ 
    __weak typeof(self) weakSelf = self;
    cell.deleteBlock = ^(AppSceneCell *cellToDelete) {
        NSIndexPath *indexPath = [weakSelf.collectionView indexPathForCell:cellToDelete];
        if (indexPath) {
            [weakSelf removeImmortalizedApp:app];
            [weakSelf removePresentedSceneByBundleId:app.bundleIdentifier];
        }
    };
    
    return cell;
}

-(void)removeImmortalizedApp:(LSApplicationProxy *)app {
    NSUInteger index = [self.selectedApps indexOfObject:app];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.selectedApps removeObjectAtIndex:indexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    NSString *bundleId = app.bundleIdentifier;

    /* multi scene check, needs to be terminated as it will still continue to run */
    FBSceneLayerManager *layermanager = self.scenesByBundleId[bundleId].layerManager;
    FBSceneLayer *scenelayer = (layermanager.layers.count > 0) ? [layermanager.layers objectAtIndex:0] : nil;
    if (scenelayer && scenelayer.level != 10) { 
        int pid = self.scenesByBundleId[bundleId].clientProcess.pid;
        [self killAppWithPid:pid withCompletion:nil];
    }

    NSString *sceneToDestroy = [self getSceneIdentifierByBundleId:bundleId];
    [[FBSceneManager sharedInstance] destroyScene:sceneToDestroy withTransitionContext:nil];
}

/* tapping an appscenecell (this should open a viewcontroller that shows the scene of the app) */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LSApplicationProxy *selectedApp = self.selectedApps[indexPath.item];
    [self openScene:selectedApp];
}

- (void)handleCollectionItemLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        
        if (indexPath) {
            LSApplicationProxy *selectedApp = self.selectedApps[indexPath.item];
            [self openSceneExternally:selectedApp];
        }
    }
}

- (void)openSceneExternally:(LSApplicationProxy *)app {
    NSString *bundleId = app.bundleIdentifier;
    FBScene *scene = self.scenesByBundleId[bundleId];
    if (scene && ![self.activePresentedScenesByBundleId containsObject:bundleId]) {
        [self addPresentedSceneByBundleId:bundleId];
        ExternalAppSceneView *externalSceneView = [[ExternalAppSceneView alloc] initExternalWindowWithScene:scene withAppName:app.localizedName withSettings:self.scenesSettingsByBundleId[bundleId]];
        externalSceneView.delegate = self;
        [self.parentViewController.parentViewController.view addSubview:externalSceneView];
    }
}

- (void)openScene:(LSApplicationProxy *)app {
    NSString *bundleId = app.bundleIdentifier;
    FBScene *scene = self.scenesByBundleId[bundleId];
    if (scene && ![self.activePresentedScenesByBundleId containsObject:bundleId]) {
        [self addPresentedSceneByBundleId:bundleId];
        AppSceneView *sceneView = [[AppSceneView alloc] initWithScene:self.scenesByBundleId[bundleId] withSettings:self.scenesSettingsByBundleId[bundleId]];
        sceneView.delegate = self;
        sceneView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.parentViewController.parentViewController.view addSubview:sceneView];

        [NSLayoutConstraint activateConstraints:@[
            [sceneView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [sceneView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [sceneView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [sceneView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
    }
}

- (void)highlightAndShakeCell:(AppSceneCell *)cell {
    cell.backgroundColor = [UIColor redColor];
    
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    shakeAnimation.values = @[
        [NSValue valueWithCGPoint:CGPointMake(cell.center.x - 10, cell.center.y)],
        [NSValue valueWithCGPoint:CGPointMake(cell.center.x + 10, cell.center.y)],
        [NSValue valueWithCGPoint:CGPointMake(cell.center.x - 10, cell.center.y)],
        [NSValue valueWithCGPoint:CGPointMake(cell.center.x + 10, cell.center.y)],
        [NSValue valueWithCGPoint:CGPointMake(cell.center.x, cell.center.y)]
    ];
    shakeAnimation.keyTimes = @[@0, @0.2, @0.4, @0.6, @1];
    shakeAnimation.duration = 0.5;
    
    [cell.layer addAnimation:shakeAnimation forKey:@"shake"];

    CABasicAnimation *colorPulseAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorPulseAnimation.fromValue = (id)[UIColor redColor].CGColor;
    colorPulseAnimation.toValue = (id)[UIColor systemGray6Color].CGColor;
    colorPulseAnimation.duration = 0.5; 
    colorPulseAnimation.autoreverses = YES; 
    colorPulseAnimation.repeatCount = HUGE_VALF;
    
    [cell.layer addAnimation:colorPulseAnimation forKey:@"colorPulse"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cell.backgroundColor = [UIColor systemGray6Color];
        [cell.layer removeAnimationForKey:@"shake"];
        [cell.layer removeAnimationForKey:@"colorPulse"];
    });
}

- (void)killAppWithPid:(int)pid withCompletion:(KillAppCompletion)completion {
    kill(pid, SIGTERM);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int status;
        BOOL isRunning = YES;

        while (isRunning) {
            isRunning = (kill(pid, 0) == 0);
            usleep(100000);
        }

        waitpid(pid, &status, 0);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
}

/* where magic happens */
- (void)initializeNewSceneForBundleId:(LSApplicationProxy *)app firstLaunch:(BOOL)firstLaunch{
    NSString *bundleId = app.bundleIdentifier;
    if (firstLaunch) [UIApplication.sharedApplication launchApplicationWithIdentifier:bundleId suspended:NO];

    RBSProcessIdentity *identity = [RBSProcessIdentity identityForEmbeddedApplicationIdentifier:bundleId];
    RBSProcessPredicate *predicate = [RBSProcessPredicate predicateMatchingIdentity:identity];
    FBProcessManager *manager = [FBProcessManager sharedInstance];
    FBApplicationProcessLaunchTransaction *transaction = [[FBApplicationProcessLaunchTransaction alloc] initWithProcessIdentity:identity executionContextProvider:^id(void) {
        FBMutableProcessExecutionContext *context = [FBMutableProcessExecutionContext new];
        context.identity = identity;
        context.environment = @{};
        context.launchIntent = 4;
        return [manager launchProcessWithContext:context];
    }];
    
    [transaction setCompletionBlock:^{
        RBSProcessHandle *processHandle = [RBSProcessHandle handleForPredicate:predicate error:nil];
        [manager registerProcessForAuditToken:processHandle.auditToken];

        FBSMutableSceneDefinition *definition = [FBSMutableSceneDefinition definition];
        NSString *sceneIdentifier = [self getSceneIdentifierByBundleId:bundleId];
        definition.identity = [FBSSceneIdentity identityForIdentifier:sceneIdentifier];
        definition.clientIdentity = [FBSSceneClientIdentity identityForProcessIdentity:identity];
        definition.specification = [UIApplicationSceneSpecification specification];
        
        UIMutableApplicationSceneSettings *settings = [UIMutableApplicationSceneSettings new];
        settings.canShowAlerts = YES;
        settings.displayConfiguration = [UIScreen mainScreen].displayConfiguration;
        settings.foreground = YES;
        settings.backgrounded = NO;

        UIInterfaceOrientation interfaceOrientation = 0;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                interfaceOrientation = scene.interfaceOrientation;
                break; 
            }
        }
        switch (interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                settings.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
                break;
            case UIInterfaceOrientationLandscapeRight:
                settings.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
                break;
            default:
                settings.frame = self.view.bounds;
                break;
        }

        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        UIEdgeInsets defaultInset = window.safeAreaInsets;
        settings.peripheryInsets = defaultInset;
        settings.safeAreaInsetsPortrait = defaultInset;

        settings.interfaceOrientation = interfaceOrientation;
        settings.level = 1;
        settings.persistenceIdentifier = NSUUID.UUID.UUIDString;

        FBSMutableSceneParameters *parameters = [FBSMutableSceneParameters parametersForSpecification:definition.specification];
        parameters.settings = settings;
        
        UIMutableApplicationSceneClientSettings *clientSettings = [UIMutableApplicationSceneClientSettings new];
        clientSettings.interfaceOrientation = UIInterfaceOrientationPortrait;
        clientSettings.statusBarStyle = 0;
        parameters.clientSettings = clientSettings;
        
        self.scenesByBundleId[bundleId] = [[FBSceneManager sharedInstance] createSceneWithDefinition:definition initialParameters:parameters];
        self.scenesSettingsByBundleId[bundleId] = settings;
        
        if (!firstLaunch) { /* confirmed that the app is multiscene */
            [self openScene:app];
            [self showToast:app.localizedName withDescription:@"Immortalized"];
            return;
        }
        
        /* multi-scene check */
        /* terrible approach but cannot find any alternatives other than a fixed delay to obtain scene layers. */
        FBSceneLayerManager *layermanager = self.scenesByBundleId[bundleId].layerManager;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            FBSceneLayer *scenelayer = (layermanager.layers.count > 0) ? [layermanager.layers objectAtIndex:0] : nil;
            if (scenelayer && scenelayer.level != 10) {
                /* normally, level is 0 in multi scene apps. we can't immortalize multiple scenes. only one created inside immortalizerts. */
                [UIApplication.sharedApplication launchApplicationWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] suspended:NO]; //go back to immortalizerTS
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ImmortalizerTS"
                                                                             message:@"It was detected that this app supports multi-scene. ImmortalizerTS can only immortalize one scene. The app needs to be terminated and relaunched inside here."
                                                                      preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Launch Here" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    int pid = self.scenesByBundleId[bundleId].clientProcess.pid;
                    [self killAppWithPid:pid withCompletion:^{
                        [self initializeNewSceneForBundleId:app firstLaunch:NO];
                    }];
                }];

                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self removeImmortalizedApp:app];
                }];

                [alertController addAction:okAction];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];

            } else {
                /* single scene, proceed */
                [self showToast:app.localizedName withDescription:@"Immortalized"];
            }
        });

    }];
    
    [transaction begin];
}

- (NSString *)getSceneIdentifierByBundleId:(NSString *)bundleId {
    return [NSString stringWithFormat:@"sceneID:%@-%@", bundleId, @"default"];
}

- (void)showToast:(NSString *)appName withDescription:(NSString *)description {
    self.rootWindow = [[UIRootSceneWindow alloc] initWithDisplayConfiguration:[UIScreen mainScreen].displayConfiguration];
    [self.rootWindow setFrame:UIScreen.mainScreen.bounds];
    self.rootWindow.backgroundColor = [UIColor clearColor];
    self.rootWindow.hidden = NO;
    self.rootWindow.windowLevel = UIWindowLevelAlert + 1;

    UIViewController *toastViewController = [[UIViewController alloc] init];
    self.rootWindow.rootViewController = toastViewController;

    CustomToastView *toast = [[CustomToastView alloc] initWithTitle:appName subtitle:description icon:[UIImage systemImageNamed:@"hourglass.bottomhalf.fill"] autoHide:3];
    [toast presentToastInViewController:toastViewController];

    /* what a lazy bastard */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rootWindow = nil;
    });
}
@end