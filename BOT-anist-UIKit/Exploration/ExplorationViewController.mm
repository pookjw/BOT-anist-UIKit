//
//  ExplorationViewController.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

#import "ExplorationViewController.h"
#import "ExplorationBoardViewController.h"
#import "BOT_anist_UIKit-Swift.h"

__attribute__((objc_direct_members))
@interface ExplorationViewController ()
@property (retain, readonly, nonatomic) __kindof UIViewController *hostingController;
@property (retain, readonly, nonatomic) ExplorationBoardViewController *boardViewController;
@property (retain, readonly, nonatomic) UIBarButtonItem *dismissBarButtonItem;
@property (assign, readonly, nonatomic) RobotData robotData;
@property (retain, readonly, nonatomic) NSUUID *sessionUUID;
@end

@implementation ExplorationViewController
@synthesize hostingController = _hostingController;
@synthesize boardViewController = _boardViewController;
@synthesize dismissBarButtonItem = _dismissBarButtonItem;
@synthesize sessionUUID = _sessionUUID;

- (instancetype)initWithRobotData:(const RobotData)robotData {
    if (self = [super init]) {
        _robotData = robotData;
        _sessionUUID = [NSUUID new];
    }
    
    return self;
}

- (void)dealloc {
    [_hostingController release];
    [_boardViewController release];
    [_dismissBarButtonItem release];
    [_sessionUUID release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = self.view;
    
    //
    
    __kindof UIViewController *hostingController = self.hostingController;
    [self addChildViewController:hostingController];
    __kindof UIView *previewHostingView = hostingController.view;
    previewHostingView.frame = view.bounds;
    previewHostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:previewHostingView];
    [hostingController didMoveToParentViewController:self];
    
    //
    
    ExplorationBoardViewController *boardViewController = self.boardViewController;
    [self addChildViewController:boardViewController];
    __kindof UIView *boardView = boardViewController.view;
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:boardView];
    [NSLayoutConstraint activateConstraints:@[
        [boardView.topAnchor constraintEqualToAnchor:view.layoutMarginsGuide.topAnchor],
        [boardView.trailingAnchor constraintEqualToAnchor:view.layoutMarginsGuide.trailingAnchor]
    ]];
    [boardViewController didMoveToParentViewController:self];
    
    //
    
    UINavigationItem *navigaitonItem = self.navigationItem;
    navigaitonItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    navigaitonItem.rightBarButtonItem = self.dismissBarButtonItem;
}

- (__kindof UIViewController *)hostingController {
    if (auto hostingController = _hostingController) return hostingController;
    
    __kindof UIViewController *hostingController = BOT_anist_UIKit::makeExplorationHostingController(_robotData, self.sessionUUID);
    
    _hostingController = [hostingController retain];
    return [hostingController autorelease];
}

- (ExplorationBoardViewController *)boardViewController {
    if (auto boardViewController = _boardViewController) return boardViewController;
    
    ExplorationBoardViewController *boardViewController = [[ExplorationBoardViewController alloc] initWithSessionUUID:self.sessionUUID];
    
    _boardViewController = [boardViewController retain];
    return [boardViewController autorelease];
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
