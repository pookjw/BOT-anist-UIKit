//
//  RobotPreviewViewController.m
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import "RobotPreviewViewController.h"
#include "RobotData.hpp"
#import "BOT_anist_UIKit-Swift.h"

@interface RobotPreviewViewController ()
@property (retain, readonly, nonatomic) __kindof UIViewController *previewHostingController;
@end

@implementation RobotPreviewViewController
@synthesize previewHostingController = _previewHostingController;

- (void)dealloc {
    [_previewHostingController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = self.view;
    
    __kindof UIViewController *previewHostingController = self.previewHostingController;
    [self addChildViewController:previewHostingController];
    __kindof UIView *previewHostingView = previewHostingController.view;
    previewHostingView.frame = view.bounds;
    previewHostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:previewHostingView];
    [previewHostingController didMoveToParentViewController:self];
}

- (__kindof UIViewController *)previewHostingController {
    if (auto previewHostingController = _previewHostingController) return previewHostingController;
    
    __kindof UIViewController *previewHostingController = BOT_anist_UIKit::makeRobotPreviewHostingController({});
    
    _previewHostingController = [previewHostingController retain];
    return previewHostingController;
}

@end
