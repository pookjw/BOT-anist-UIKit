//
//  ExplorationViewController.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

#import "ExplorationViewController.h"
#import "ExplorationBoardViewController.h"
#import "BOT_anist_UIKit-Swift.h"
#import "MRUISize3D.h"
#import <TargetConditionals.h>
#import <objc/message.h>
#import <objc/runtime.h>

__attribute__((objc_direct_members))
@interface ExplorationViewController ()
@property (retain, readonly, nonatomic) __kindof UIViewController *hostingController;
@property (retain, readonly, nonatomic) ExplorationBoardViewController *boardViewController;
#if TARGET_OS_VISION
@property (retain, readonly, nonatomic) id boardPlatterOrnament; // MRUIPlatterOrnament
#endif
@property (retain, readonly, nonatomic) UIBarButtonItem *dismissBarButtonItem;
@property (assign, readonly, nonatomic) RobotData robotData;
@property (retain, readonly, nonatomic) NSUUID *sessionUUID;
@end

@implementation ExplorationViewController
@synthesize hostingController = _hostingController;
@synthesize boardViewController = _boardViewController;
#if TARGET_OS_VISION
@synthesize boardPlatterOrnament = _boardPlatterOrnament;
#endif
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
#if TARGET_OS_VISION
    [_boardPlatterOrnament release];
#endif
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
    
#if !TARGET_OS_VISION
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
#else
    id mrui_ornamentsItem = reinterpret_cast<id (*) (id, SEL)>(objc_msgSend) (self, sel_registerName("mrui_ornamentsItem"));
    
    reinterpret_cast<void (*) (id, SEL, id)>(objc_msgSend)(mrui_ornamentsItem, NSSelectorFromString(@"setOrnaments:"), @[
        self.boardPlatterOrnament
    ]);
#endif
    
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

#if TARGET_OS_VISION
- (id)boardPlatterOrnament {
    if (id boardPlatterOrnament = _boardPlatterOrnament) return boardPlatterOrnament;
    
    id boardPlatterOrnament = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("MRUIPlatterOrnament") alloc], sel_registerName("initWithViewController:"), self.boardViewController);
    
//    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(boardPlatterOrnament, sel_registerName("setCanFollowUser:"), YES);
    
    reinterpret_cast<void (*)(id, SEL, CGSize)>(objc_msgSend)(boardPlatterOrnament, sel_registerName("setPreferredContentSize:"), self.boardViewController.view.intrinsicContentSize);
    
    CGFloat anchorPoint[4] = {0.5, 0.0, 0.0, 0.0};
    
    id position = reinterpret_cast<id (*)(id, SEL, double[4])>(objc_msgSend)([objc_lookUpClass("MRUIPlatterOrnamentRelativePosition") alloc], sel_registerName("initWithAnchorPoint:"), anchorPoint);
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(boardPlatterOrnament, sel_registerName("setPosition:"), position);
    [position release];
    
    _boardPlatterOrnament = [boardPlatterOrnament retain];
    return [boardPlatterOrnament autorelease];
}
#endif

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
