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

__attribute__((objc_direct_members))
@interface RobotPreviewViewController ()
@property (retain, readonly, nonatomic) __kindof UIViewController *hostingController;
@property (retain, readonly, nonatomic) UIBarButtonItem *explorationBarButtonItem;
@end

@implementation RobotPreviewViewController
@synthesize hostingController = _hostingController;
@synthesize explorationBarButtonItem = _explorationBarButtonItem;

- (void)dealloc {
    [_hostingController release];
    [_explorationBarButtonItem release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = self.view;
    
    __kindof UIViewController *hostingController = self.hostingController;
    [self addChildViewController:hostingController];
    __kindof UIView *previewHostingView = hostingController.view;
    previewHostingView.frame = view.bounds;
    previewHostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:previewHostingView];
    [hostingController didMoveToParentViewController:self];
    
    UINavigationItem *navigationItem = self.navigationItem;
    navigationItem.rightBarButtonItem = self.explorationBarButtonItem;
}

- (__kindof UIViewController *)hostingController {
    if (auto hostingController = _hostingController) return hostingController;
    
    __kindof UIViewController *hostingController = BOT_anist_UIKit::makeRobotPreviewHostingController({});
    
    _hostingController = [hostingController retain];
    return hostingController;
}

- (UIBarButtonItem *)explorationBarButtonItem {
    if (auto explorationBarButtonItem = _explorationBarButtonItem) return explorationBarButtonItem;
    
    UIBarButtonItem *explorationBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"play.fill"] style:UIBarButtonItemStylePlain target:self action:@selector(didTriggerExplorationBarButtonItem:)];
    
    _explorationBarButtonItem = [explorationBarButtonItem retain];
    return [explorationBarButtonItem autorelease];
}

- (void)didTriggerExplorationBarButtonItem:(UIBarButtonItem *)sender {
    ExplorationViewController *explorationViewController = [[ExplorationViewController alloc] initWithRobotData:{}];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:explorationViewController];
    [explorationViewController release];
    
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
    [navigationController release];
}

@end
