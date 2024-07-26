//
//  RobotPreviewViewController.m
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import "RobotPreviewViewController.h"
#include "RobotData.hpp"
#import "BOT_anist_UIKit-Swift.h"
#import "ExplorationViewController.h"
#import "MRUISize3D.h"
#import "ExplorationSceneDelegate.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import <TargetConditionals.h>

UIKIT_EXTERN NSNotificationName const UIPresentationControllerDismissalTransitionDidEndNotification;

__attribute__((objc_direct_members))
@interface RobotPreviewViewController () <UIAdaptivePresentationControllerDelegate>
@property (class, assign, readonly, nonatomic) void *isOwnNavigationControllerKey;
@property (retain, nonatomic) __kindof UIViewController *hostingController;
@property (retain, readonly, nonatomic) UIBarButtonItem *explorationBarButtonItem;
@property (assign, nonatomic) RobotData robotData;
@end

@implementation RobotPreviewViewController
@synthesize explorationBarButtonItem = _explorationBarButtonItem;

+ (void *)isOwnNavigationControllerKey {
    static void *isOwnNavigationControllerKey = &isOwnNavigationControllerKey;
    return isOwnNavigationControllerKey;
}

- (instancetype)initWithRobotData:(RobotData)robotData {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _robotData = robotData;
    }
    
    return self;
}

- (void)dealloc {
    [_hostingController release];
    [_explorationBarButtonItem release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationItem *navigationItem = self.navigationItem;
    navigationItem.rightBarButtonItem = self.explorationBarButtonItem;
    
    [self attachHostingController];
    
#if !TARGET_OS_VISION
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receivedDismissalTransitionDidEndNotification:)
                                               name:UIPresentationControllerDismissalTransitionDidEndNotification
                                             object:nil];
#endif
}

- (void)updateRobotData:(RobotData)robotData {
    self.robotData = robotData;
    
    if (_hostingController != nil) {
        BOT_anist_UIKit::updateRobotPreviewHostingController(self.hostingController, robotData);
    }
}

#if !TARGET_OS_VISION
- (void)receivedDismissalTransitionDidEndNotification:(NSNotification *)notification {
    __kindof UIViewController *viewController = notification.object;
    
    if (objc_getAssociatedObject(viewController, RobotPreviewViewController.isOwnNavigationControllerKey) == nil) return;
    
    [self attachHostingController];
}
#endif

- (__kindof UIViewController *)attachHostingController __attribute__((objc_direct)) {
    if (auto hostingController = self.hostingController) return hostingController;
    
    __kindof UIViewController *hostingController = BOT_anist_UIKit::makeRobotPreviewHostingController(self.robotData);
    UIView *view = self.view;
    
    [self addChildViewController:hostingController];
    __kindof UIView *previewHostingView = hostingController.view;
    previewHostingView.frame = view.bounds;
    previewHostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:previewHostingView];
    [hostingController didMoveToParentViewController:self];
    
    self.hostingController = hostingController;
    return [hostingController autorelease];
}

#if !TARGET_OS_VISION
- (void)datachHostingController __attribute__((objc_direct)) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    __kindof UIViewController *hostingController = self.hostingController;
    
    if (hostingController == nil) {
        [pool release];
        return;
    }
    
    [hostingController willMoveToParentViewController:nil];
    [hostingController.view removeFromSuperview];
    [hostingController removeFromParentViewController];
    
    self.hostingController = nil;
    
    [pool release];
}
#endif

- (UIBarButtonItem *)explorationBarButtonItem {
    if (auto explorationBarButtonItem = _explorationBarButtonItem) return explorationBarButtonItem;
    
    UIBarButtonItem *explorationBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"play.fill"] style:UIBarButtonItemStylePlain target:self action:@selector(didTriggerExplorationBarButtonItem:)];
    
    _explorationBarButtonItem = [explorationBarButtonItem retain];
    return [explorationBarButtonItem autorelease];
}

- (void)didTriggerExplorationBarButtonItem:(UIBarButtonItem *)sender {
#if !TARGET_OS_VISION
    [self datachHostingController];
    
    ExplorationViewController *explorationViewController = [[ExplorationViewController alloc] initWithRobotData:self.robotData];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:explorationViewController];
    [explorationViewController release];
    
    objc_setAssociatedObject(navigationController, RobotPreviewViewController.isOwnNavigationControllerKey, [NSNull null], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    navigationController.presentationController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
    [navigationController release];
#else
    UISceneSessionActivationRequest *request = [UISceneSessionActivationRequest requestWithRole:UIWindowSceneSessionRoleVolumetricApplication];
    
    NSUUID *robotDataIdentifier = [NSUUID UUID];
    ExplorationSceneDelegate.robotDataByIdentifiers[robotDataIdentifier] = self.robotData.getNSData();
    
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:@"Exploration"];
    
    userActivity.userInfo = @{@"robotDataIdentifier": robotDataIdentifier};
    
    request.userActivity = userActivity;
    [userActivity release];
    
    __kindof UIWindowSceneActivationRequestOptions *options = [objc_lookUpClass("_UIVolumetricWindowSceneActivationRequestOptions") new];
    
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(options, sel_registerName("_setInternal:"), YES);
    
    //
    
    // 1 : automatic, 2 : dynamic
    reinterpret_cast<void (*)(id, SEL, NSInteger)>(objc_msgSend)(options, sel_registerName("_setPreferredDisplayZoomBehavior:"), 2);
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(options, sel_registerName("_setInternal:"), YES);
    
    // MRUILaunchPlacementParameters
    id mrui_placementParameters = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(options, sel_registerName("mrui_placementParameters"));
    // 0 : automatic, 1 : dynamic
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(mrui_placementParameters, sel_registerName("setPreferredScalingBehavior:"), 1);
    
    //
    
    NSValue *preferredLaunchSize3D = reinterpret_cast<id (*)(Class, SEL, MRUISize3D)>(objc_msgSend)(NSValue.class, sel_registerName("valueWithMRUISize3D:"), MRUISize3DMake(900., 500., 900.));
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(mrui_placementParameters, sel_registerName("setPreferredLaunchSize3D:"), preferredLaunchSize3D);
    
    //
    
    request.options = options;
    [options release];
    
    [UIApplication.sharedApplication activateSceneSessionForRequest:request errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
#endif
}

@end
