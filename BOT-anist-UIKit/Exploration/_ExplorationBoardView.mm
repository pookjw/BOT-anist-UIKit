//
//  _ExplorationBoardView.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/26/24.
//

#import "_ExplorationBoardView.h"
#import <TargetConditionals.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "Exploration.h"

__attribute__((objc_direct_members))
@interface _ExplorationBoardView ()
#if !TARGET_OS_VISION
@property (retain, readonly, nonatomic) UIVisualEffectView *blurView;
@property (retain, readonly, nonatomic) UIVisualEffectView *vibrancyView;
#endif
@property (retain, readonly, nonatomic) UIStackView *stackView;

// _UICircleProgressView *
@property (retain, readonly, nonatomic) __kindof UIView *circleProgressView;
@property (retain, readonly, nonatomic) UIButton *resetButton;
@property (retain, readonly, nonatomic) UIButton *exitButton;

@property (retain, readonly, nonatomic) NSUUID *sessionUUID;
@end

@implementation _ExplorationBoardView
#if !TARGET_OS_VISION
@synthesize blurView = _blurView;
@synthesize vibrancyView = _vibrancyView;
#endif
@synthesize stackView = _stackView;
@synthesize circleProgressView = _circleProgressView;
@synthesize resetButton = _resetButton;
@synthesize exitButton = _exitButton;

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithSessionUUID:(NSUUID *)sessionUUID {
    if (self = [super initWithFrame:CGRectNull]) {
        _sessionUUID = [sessionUUID retain];
        
#if !TARGET_OS_VISION
        UIVisualEffectView *blurView = self.blurView;
        blurView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:blurView];
        [NSLayoutConstraint activateConstraints:@[
            [blurView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [blurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [blurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        UIVisualEffectView *vibrancyView = self.vibrancyView;
        vibrancyView.translatesAutoresizingMaskIntoConstraints = NO;
        [blurView.contentView addSubview:vibrancyView];
        [NSLayoutConstraint activateConstraints:@[
            [vibrancyView.topAnchor constraintEqualToAnchor:blurView.contentView.topAnchor],
            [vibrancyView.leadingAnchor constraintEqualToAnchor:blurView.contentView.leadingAnchor],
            [vibrancyView.trailingAnchor constraintEqualToAnchor:blurView.contentView.trailingAnchor],
            [vibrancyView.bottomAnchor constraintEqualToAnchor:blurView.contentView.bottomAnchor]
        ]];
#endif
        
        UIStackView *stackView = self.stackView;
        __kindof UIView *circleProgressView = self.circleProgressView;
        
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
#if !TARGET_OS_VISION
        [vibrancyView.contentView addSubview:stackView];
        
        [NSLayoutConstraint activateConstraints:@[
            [stackView.topAnchor constraintEqualToAnchor:vibrancyView.contentView.topAnchor constant:20.],
            [stackView.leadingAnchor constraintEqualToAnchor:vibrancyView.contentView.leadingAnchor constant:20.],
            [stackView.trailingAnchor constraintEqualToAnchor:vibrancyView.contentView.trailingAnchor constant:-20.],
            [stackView.bottomAnchor constraintEqualToAnchor:vibrancyView.contentView.bottomAnchor constant:-20.],
//            [circleProgressView.widthAnchor constraintEqualToConstant:200.],
            [circleProgressView.heightAnchor constraintEqualToConstant:200.]
        ]];
#else
        [self addSubview:stackView];
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [NSLayoutConstraint activateConstraints:@[
            [stackView.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
            [stackView.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
            [stackView.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
            [stackView.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
//            [circleProgressView.widthAnchor constraintEqualToConstant:200.],
            [circleProgressView.heightAnchor constraintEqualToConstant:200.],
//            [circleProgressView.widthAnchor constraintEqualToAnchor:circleProgressView.heightAnchor]
        ]];
        
        reinterpret_cast<void (*)(id, SEL, UIBlurEffectStyle)>(objc_msgSend)(self, sel_registerName("sws_enablePlatter:"), UIBlurEffectStyleSystemMaterial);
#endif
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(didReceiveDidChangePlantsFoundNotification:)
                                                   name:ExplorationDidChangePlantsFoundNotificationName
                                                 object:nil];
    }
    
    return self;
}

- (void)dealloc {
#if !TARGET_OS_VISION
    [_blurView release];
    [_vibrancyView release];
#endif
    [_stackView release];
    [_circleProgressView release];
    [_resetButton release];
    [_exitButton release];
    [_sessionUUID release];
    [super dealloc];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(200., 300.);
}

- (void)didReceiveDidChangePlantsFoundNotification:(NSNotification *)notification {
    NSUUID *sessionUUID = notification.userInfo[ExplorationSessionKey];
    
    if (![sessionUUID isEqual:self.sessionUUID]) return;
    
    NSNumber *plantsFound = notification.userInfo[ExplorationPlantsFoundKey];
    
    reinterpret_cast<void (*)(id, SEL, double, BOOL, id)>(objc_msgSend)(self.circleProgressView, sel_registerName("setProgress:animated:completion:"), static_cast<double>(plantsFound.integerValue) / 3.0, YES, nil);
}

#if !TARGET_OS_VISION
- (UIVisualEffectView *)blurView {
    if (auto blurView = _blurView) return blurView;
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark]];
    
    blurView.layer.cornerRadius = 20.;
    blurView.layer.cornerCurve = kCACornerCurveContinuous;
    blurView.layer.masksToBounds = YES;
    
    _blurView = [blurView retain];
    return [blurView autorelease];
}

- (UIVisualEffectView *)vibrancyView {
    if (auto vibrancyView = _vibrancyView) return vibrancyView;
    
    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark] style:UIVibrancyEffectStyleLabel]];
    
    _vibrancyView = [vibrancyView retain];
    return [vibrancyView autorelease];
}
#endif

- (UIStackView *)stackView {
    if (auto stackView = _stackView) return stackView;
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.circleProgressView,
        self.resetButton,
        self.exitButton
    ]];
    
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFillProportionally;
    stackView.alignment = UIStackViewAlignmentFill;
    
    _stackView = [stackView retain];
    return [stackView autorelease];
}

- (__kindof UIView *)circleProgressView {
    if (auto circleProgressView = _circleProgressView) return circleProgressView;
    
    __kindof UIView *circleProgressView = [objc_lookUpClass("_UICircleProgressView") new];
    
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(circleProgressView, sel_registerName("setShowProgressTray:"), YES);
    
    reinterpret_cast<void (*)(id, SEL, double, BOOL, id)>(objc_msgSend)(circleProgressView, sel_registerName("setProgress:animated:completion:"), 1.0, NO, nil);
    reinterpret_cast<void (*)(id, SEL, double, BOOL, id)>(objc_msgSend)(circleProgressView, sel_registerName("setProgress:animated:completion:"), 0.0, NO, nil);
    
    _circleProgressView = [circleProgressView retain];
    return [circleProgressView autorelease];
}

- (UIButton *)resetButton {
    if (auto resetButton = _resetButton) return resetButton;
    
    UIAction *primaryAction = [UIAction actionWithTitle:@"Reset" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [NSNotificationCenter.defaultCenter postNotificationName:ExplorationRequestedResetNotificiationName
                                                          object:nil
                                                        userInfo:@{ExplorationSessionKey: self.sessionUUID}];
    }];
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectNull primaryAction:primaryAction];
    
    _resetButton = [resetButton retain];
    return [resetButton autorelease];
}

- (UIButton *)exitButton {
    if (auto exitButton = _exitButton) return exitButton;
    
    __weak auto weakSelf = self;
    
    UIAction *primaryAction = [UIAction actionWithTitle:@"Exit" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf exitExploration];
    }];
    
    UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectNull primaryAction:primaryAction];
    
    _exitButton = [exitButton retain];
    return [exitButton autorelease];
}

- (void)exitExploration __attribute__((objc_direct)) {
#if !TARGET_OS_VISION
    __kindof UIViewController *_viewControllerForAncestor = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_viewControllerForAncestor"));
    [_viewControllerForAncestor dismissViewControllerAnimated:YES completion:nil];
#else
    [UIApplication.sharedApplication requestSceneSessionDestruction:self.window.windowScene.session
                                                            options:nil
                                                       errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
#endif
}

@end
