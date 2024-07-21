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
#import <objc/runtime.h>

UIKIT_EXTERN NSNotificationName const UIPresentationControllerDismissalTransitionDidEndNotification;

__attribute__((objc_direct_members))
@interface RobotPreviewViewController () <UIAdaptivePresentationControllerDelegate>
@property (class, assign, readonly, nonatomic) void *isOwnNavigationControllerKey;
@property (retain, nonatomic) __kindof UIViewController *hostingController;
@property (retain, readonly, nonatomic) UIBarButtonItem *explorationBarButtonItem;
@end

@implementation RobotPreviewViewController
@synthesize explorationBarButtonItem = _explorationBarButtonItem;

+ (void *)isOwnNavigationControllerKey {
    static void *isOwnNavigationControllerKey = &isOwnNavigationControllerKey;
    return isOwnNavigationControllerKey;
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
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(foo:)
                                               name:UIPresentationControllerDismissalTransitionDidEndNotification
                                             object:nil];
}

- (void)foo:(NSNotification *)notification {
    __kindof UIViewController *viewController = notification.object;
    
    if (objc_getAssociatedObject(viewController, RobotPreviewViewController.isOwnNavigationControllerKey) == nil) return;
    
    [self attachHostingController];
}

- (__kindof UIViewController *)attachHostingController __attribute__((objc_direct)) {
    if (auto hostingController = self.hostingController) return hostingController;
    
    __kindof UIViewController *hostingController = BOT_anist_UIKit::makeRobotPreviewHostingController({});
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

- (UIBarButtonItem *)explorationBarButtonItem {
    if (auto explorationBarButtonItem = _explorationBarButtonItem) return explorationBarButtonItem;
    
    UIBarButtonItem *explorationBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"play.fill"] style:UIBarButtonItemStylePlain target:self action:@selector(didTriggerExplorationBarButtonItem:)];
    
    _explorationBarButtonItem = [explorationBarButtonItem retain];
    return [explorationBarButtonItem autorelease];
}

- (void)didTriggerExplorationBarButtonItem:(UIBarButtonItem *)sender {
    [self datachHostingController];
    
    ExplorationViewController *explorationViewController = [[ExplorationViewController alloc] initWithRobotData:{}];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:explorationViewController];
    [explorationViewController release];
    
    objc_setAssociatedObject(navigationController, RobotPreviewViewController.isOwnNavigationControllerKey, [NSNull null], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    navigationController.presentationController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
    [navigationController release];
}

@end
