//
//  ExplorationViewController.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

#import "ExplorationViewController.h"
#import "BOT_anist_UIKit-Swift.h"

__attribute__((objc_direct_members))
@interface ExplorationViewController ()
@property (retain, readonly, nonatomic) __kindof UIViewController *hostingController;
@property (retain, readonly, nonatomic) UIBarButtonItem *dismissBarButtonItem;
@property (assign, readonly, nonatomic) RobotData robotData;
@end

@implementation ExplorationViewController
@synthesize hostingController = _hostingController;
@synthesize dismissBarButtonItem = _dismissBarButtonItem;

- (instancetype)initWithRobotData:(const RobotData)robotData {
    if (self = [super init]) {
        _robotData = robotData;
    }
    
    return self;
}

- (void)dealloc {
    [_hostingController release];
    [_dismissBarButtonItem release];
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
    
    UINavigationItem *navigaitonItem = self.navigationItem;
    navigaitonItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    navigaitonItem.rightBarButtonItem = self.dismissBarButtonItem;
}

- (__kindof UIViewController *)hostingController {
    if (auto hostingController = _hostingController) return hostingController;
    
    __kindof UIViewController *hostingController = BOT_anist_UIKit::makeExplorationHostingController(_robotData);
    
    _hostingController = [hostingController retain];
    return [hostingController autorelease];
}

- (UIBarButtonItem *)dismissBarButtonItem {
    if (auto dismissBarButtonItem = _dismissBarButtonItem) return dismissBarButtonItem;
    
    UIBarButtonItem *dismissBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didTriggerDismissBarButtonItem:)];
    
    _dismissBarButtonItem = [dismissBarButtonItem retain];
    return [dismissBarButtonItem autorelease];
}

- (void)didTriggerDismissBarButtonItem:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
