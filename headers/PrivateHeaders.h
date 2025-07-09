#import <UIKit/UIKit.h>

typedef struct { unsigned val[8]; } SCD_Struct_RB3;

@interface _UIRootWindow : UIWindow
@end

@interface UIRootSceneWindow : _UIRootWindow 
@property (nonatomic, readonly) UIView * _sceneContainerView;    
- (id)initWithDisplayConfiguration:(id)arg1;
@end

@interface FBSceneLayer : NSObject
@property (assign, nonatomic) double level; 
@end

@interface _UISceneLayerHostView : UIView
@property (nonatomic, readonly) FBSceneLayer *sceneLayer;  
@end

@interface _UIContextLayerHostView : _UISceneLayerHostView
@end

@interface _UITouchPassthroughView : UIView
@end

@interface LSResourceProxy : NSObject
@property (setter=_setLocalizedName:, nonatomic, copy) NSString *localizedName;
@end

@interface LSBundleProxy : LSResourceProxy
@end

@interface LSApplicationProxy : LSBundleProxy
@property (nonatomic, assign, readonly) NSString *bundleIdentifier;
@property (nonatomic, assign, readonly) NSString *localizedShortName;
@property (nonatomic, assign, readonly) NSString *primaryIconName;
@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *applicationType;
@property (nonatomic, readonly) NSArray *appTags;
@property (getter=isLaunchProhibited, nonatomic, readonly) BOOL launchProhibited;
@property (getter=isPlaceholder, nonatomic, readonly) BOOL placeholder;
@property (getter=isRemovedSystemApp, nonatomic, readonly) BOOL removedSystemApp;
@end

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (NSArray<LSApplicationProxy *> *)allInstalledApplications;
- (BOOL)openApplicationWithBundleID:(NSString *)bundleId;
@end

@interface BSCornerRadiusConfiguration : NSObject
- (id)initWithTopLeft:(CGFloat)tl bottomLeft:(CGFloat)bl bottomRight:(CGFloat)br topRight:(CGFloat)tr;
@end

@interface BSTransaction : NSObject
- (void)addChildTransaction:(id)transaction;
- (void)begin;
- (void)setCompletionBlock:(dispatch_block_t)block;
@end

@interface FBSceneSnapshot : NSObject 
@property (nonatomic, readonly) CGImageRef CGImage; 
@end

@protocol FBSceneDelegate 
@end

@class RBSProcessIdentity, UIMutableApplicationSceneSettings, UIMutableApplicationSceneClientSettings, _UIScenePresenter;

@interface FBApplicationProcessLaunchTransaction : BSTransaction
- (instancetype)initWithProcessIdentity:(RBSProcessIdentity *)identity executionContextProvider:(id)providerBlock;
- (void)_begin;
@end

@interface FBProcess : NSObject
@property (nonatomic, readonly) int pid;  
@property (nonatomic, copy, readonly) NSString *bundleIdentifier;
- (id)name;
@end

@interface FBSDisplayConfiguration : NSObject
- (id)initWithCADisplay:(id)arg1 isMainDisplay:(BOOL)arg2;
@end

@interface FBSSceneIdentity : NSObject
+ (instancetype)identityForIdentifier:(NSString *)id;
@end

@interface FBSSceneIdentityToken : NSObject 
@end

@interface FBSSceneSettings : NSObject
@property (nonatomic, copy, readonly) FBSDisplayConfiguration *displayConfiguration;  
@property (getter=isForeground, nonatomic, readonly) BOOL foreground;   
@end

@interface FBSSceneSpecification : NSObject
+ (instancetype)specification;
@end

@interface FBSSceneParameters : NSObject
@property (nonatomic, copy) UIMutableApplicationSceneSettings *settings;
@property (nonatomic, copy) UIMutableApplicationSceneClientSettings *clientSettings;
+ (instancetype)parametersForSpecification:(FBSSceneSpecification *)spec;
@end

@interface FBSSceneClientSettings : NSObject
@property (nonatomic, copy, readonly) NSOrderedSet *layers;  
@end

@class UIScenePresentationManager;

@interface FBSSceneDefinition : NSObject
@end

@interface FBSceneLayerManager : NSObject
@property (nonatomic,readonly) NSOrderedSet * layers; 
-(id)_initWithScene:(id)arg1 ;
-(id)layerWithContextID:(unsigned)arg1 ;
@end

@interface FBSceneClientHandle : NSObject
@end

@interface FBScene : NSObject
@property (nonatomic, copy, readonly) NSString *identifier; 
@property (nonatomic, readonly) FBProcess *clientProcess;                              
@property (assign, nonatomic) id<FBSceneDelegate> delegate;                             
@property (nonatomic, copy, readonly) NSString *workspaceIdentifier;                     
@property (nonatomic, copy, readonly) FBSSceneDefinition *definition;                    
@property (nonatomic, copy, readonly) FBSSceneIdentity *identity; 
@property (nonatomic, copy, readonly) FBSSceneIdentityToken *identityToken;              
@property (nonatomic, readonly) FBSSceneSettings *settings;                             
@property (nonatomic, readonly) FBSSceneClientSettings *clientSettings;                 
@property (nonatomic, readonly) long long contentState;                                  
@property (nonatomic, readonly) FBSceneLayerManager *layerManager;                      
@property (getter=isValid, nonatomic, readonly) BOOL valid; 
@property (getter=isActive, nonatomic, readonly) BOOL active;                             
@property (nonatomic, readonly) FBSceneClientHandle *clientHandle;                      
@property (nonatomic, copy, readonly) FBSSceneSpecification *specification; 
@property (nonatomic, copy, readonly) FBSSceneParameters *parameters; 
- (FBProcess *)clientProcess;
- (UIScenePresentationManager *)uiPresentationManager;
- (void)updateSettings:(UIMutableApplicationSceneSettings *)settings withTransitionContext:(id)context completion:(id)completion;
- (void)updateSettingsWithBlock:(id)arg1;
- (id)createSnapshot;
- (id)display;
- (void)activateWithTransitionContext:(id)arg1;
@end

@interface UIApplicationSceneSettings : NSObject
- (id)displayConfiguration;
- (BOOL)isForeground;
- (CGRect)frame;
- (UIInterfaceOrientation)interfaceOrientation;
- (UIMutableApplicationSceneSettings *)mutableCopy;
@end

@interface FBSSceneSettingsDiff : NSObject
- (UIMutableApplicationSceneSettings *)settingsByApplyingToMutableCopyOfSettings:(UIApplicationSceneSettings *)settings;
@end

@interface FBDisplayManager : NSObject
+ (instancetype)sharedInstance;
- (id)mainConfiguration;
@end

@interface FBProcessExecutionContext : NSObject
@end

@interface FBMutableProcessExecutionContext : FBProcessExecutionContext
@property (nonatomic,copy) RBSProcessIdentity * identity; 
@property (nonatomic,copy) NSArray * arguments; 
@property (nonatomic,copy) NSDictionary * environment; 
@property (nonatomic,retain) NSURL * standardOutputURL; 
@property (nonatomic,retain) NSURL * standardErrorURL; 
@property (assign,nonatomic) BOOL waitForDebugger; 
@property (assign,nonatomic) BOOL disableASLR; 
@property (assign,nonatomic) BOOL checkForLeaks; 
@property (assign,nonatomic) long long launchIntent; 
@property (nonatomic,copy) NSString * overrideExecutablePath; 
@property (nonatomic,copy) id completion; 
-(id)copyWithZone:(NSZone*)arg1 ;
@end

@interface FBProcessManager : NSObject
+ (instancetype)sharedInstance;
- (FBProcessExecutionContext *)launchProcessWithContext:(FBMutableProcessExecutionContext *)context;
- (void)registerProcessForAuditToken:(SCD_Struct_RB3)token;
- (id)allApplicationProcesses;
- (id)processesForBundleIdentifier:(id)bundleId;
@end

@interface RBSProcessIdentity : NSObject
+ (instancetype)identityForEmbeddedApplicationIdentifier:(NSString *)identifier;
@end

@interface RBSProcessPredicate
+ (instancetype)predicateMatchingIdentity:(RBSProcessIdentity *)identity;
@end

@interface RBSProcessHandle
@property (nonatomic, readonly) int pid; 
+ (instancetype)handleForPredicate:(RBSProcessPredicate *)predicate error:(NSError **)error;
- (SCD_Struct_RB3)auditToken;
@end

@interface UIApplicationSceneSpecification : FBSSceneSpecification
@end

@interface FBSMutableSceneSettings : NSObject
@property (assign, nonatomic) long long interfaceOrientation; 
- (void)setBackgrounded:(BOOL)backgrounded;
@property (assign, nonatomic) double level; 
- (void)setForeground:(BOOL)foreground;
@end

@interface BSSettings : NSObject
@end

@interface UIMutableApplicationSceneSettings : FBSMutableSceneSettings
@property (nonatomic, assign, readwrite) BOOL canShowAlerts;
@property (nonatomic, assign) BOOL deviceOrientationEventsEnabled;
@property (nonatomic, assign, readwrite) NSInteger interruptionPolicy;
@property (nonatomic, strong, readwrite) NSString *persistenceIdentifier;
@property (nonatomic, assign, readwrite) UIEdgeInsets peripheryInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets safeAreaInsetsPortrait, safeAreaInsetsPortraitUpsideDown, safeAreaInsetsLandscapeLeft, safeAreaInsetsLandscapeRight;
@property (nonatomic, strong, readwrite) BSCornerRadiusConfiguration *cornerRadiusConfiguration;
@property (assign, nonatomic) UIDeviceOrientation deviceOrientation;
@property (assign, nonatomic) unsigned long long deactivationReasons; 

- (id)displayConfiguration;
- (CGRect)frame;
- (NSMutableSet *)ignoreOcclusionReasons;
- (void)setDisplayConfiguration:(id)c;
- (void)setForeground:(BOOL)f;
- (void)setFrame:(CGRect)frame;
- (void)setLevel:(NSInteger)level;
- (void)setStatusBarDisabled:(BOOL)disabled;
- (void)setInterfaceOrientation:(NSInteger)o;
- (BSSettings *)otherSettings;
@end

@interface FBSMutableSceneParameters : FBSSceneParameters
@end

@interface FBSSceneClientIdentity : NSObject
+ (instancetype)identityForBundleID:(NSString *)bundleID;
+ (instancetype)identityForProcessIdentity:(RBSProcessIdentity *)identity;
+ (instancetype)localIdentity;
@end

@interface FBSMutableSceneDefinition : NSObject
@property (nonatomic, copy) FBSSceneClientIdentity *clientIdentity;
@property (nonatomic, copy) FBSSceneIdentity *identity;
@property (nonatomic, copy) FBSSceneSpecification *specification;
+ (instancetype)definition;
@end

@interface FBSceneWorkspace : NSObject {
    NSMutableDictionary *_allScenesByID;
}
- (id)allScenes;
@end

@interface FBSceneManager : NSObject {
    FBSceneWorkspace *_workspace;
}
+ (instancetype)sharedInstance;
- (FBScene *)createSceneWithDefinition:(id)def initialParameters:(id)params;
- (id)createSceneWithDefinition:(id)arg1;
- (id)sceneWithIdentifier:(id)arg1;
- (void)enumerateScenesWithBlock:(id)arg1;
- (void)destroyScene:(id)arg1 withTransitionContext:(id)arg2;
- (id)createSceneFromRemnant:(id)arg1 withSettings:(id)arg2 transitionContext:(id)arg3;
- (id)scenesPassingTest:(id)arg1;
- (id)newSceneIdentityTokenForIdentity:(id)arg1;
@end

@interface UIImage (internal)
+ (instancetype)_applicationIconImageForBundleIdentifier:(NSString *)bundleID format:(NSInteger)format scale:(CGFloat)scale;
@end

@interface UIApplicationSceneTransitionContext : NSObject
@end

@interface UIMutableApplicationSceneClientSettings : NSObject
@property (nonatomic, assign) NSInteger interfaceOrientation;
@property (nonatomic, assign) NSInteger statusBarStyle;
@end

@interface UIScenePresentationBinder : NSObject
- (void)addScene:(id)scene;
@end

@interface UIScenePresentationManager : NSObject
- (instancetype)_initWithScene:(FBScene *)scene;
- (_UIScenePresenter *)createPresenterWithIdentifier:(NSString *)identifier;
@end

@class UIScenePresentationManager;
@class FBScene;

@interface _UIScenePresenterOwner : NSObject
- (instancetype)initWithScenePresentationManager:(UIScenePresentationManager *)manager context:(FBScene *)scene;
@end

@interface UIScenePresentationContext : NSObject
- (UIScenePresentationContext *)_initWithDefaultValues;
@end

@interface _UISceneLayerHostContainerView : UIView
@end

@interface UIMutableScenePresentationContext : UIScenePresentationContext
@property (nonatomic, assign) NSUInteger appearanceStyle;
@end

@interface _UIScenePresentationView : UIView
@property (nonatomic, retain) _UISceneLayerHostContainerView *hostContainerView;  
@end

@interface _UIScenePresenter : NSObject
@property (nonatomic, assign, readonly) _UIScenePresentationView *presentationView;
@property (nonatomic, assign, readonly) FBScene *scene;
- (instancetype)initWithOwner:(_UIScenePresenterOwner *)manager identifier:(NSString *)scene sortContext:(NSNumber *)context;
- (void)modifyPresentationContext:(void(^)(UIMutableScenePresentationContext *context))block;
- (void)activate;
- (void)deactivate;
- (void)invalidate;
@end

@interface UIRootWindowScenePresentationBinder : UIScenePresentationBinder {
    UIRootSceneWindow *_rootSceneWindow;
}
- (void)invalidate;
- (instancetype)initWithPriority:(int)pro displayConfiguration:(id)c;
@end

@interface UIApplication()
- (void)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

@interface FBSWorkspace : NSObject
- (NSArray *)scenes;
@end

@interface UIScreen(private)
- (CGRect)_referenceBounds;
- (id)displayConfiguration;
@end