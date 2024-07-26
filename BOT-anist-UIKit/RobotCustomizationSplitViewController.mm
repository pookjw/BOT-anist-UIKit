//
//  RobotCustomizationSplitViewController.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import "RobotCustomizationSplitViewController.h"
#import "RobotCustomizationPickerViewController.hpp"
#import "RobotPreviewViewController.h"
#import "RobotData.hpp"
#import <objc/message.h>
#import <objc/runtime.h>
#import <TargetConditionals.h>

__attribute__((objc_direct_members))
@interface RobotCustomizationSplitViewController () <UISplitViewControllerDelegate, RobotCustomizationPickerViewControllerDelegate>
@property (retain, nonatomic, readonly) RobotCustomizationPickerViewController *pickerViewController;
@property (retain, nonatomic, readonly) RobotPreviewViewController *previewViewController;
@property (assign, nonatomic) RobotData robotData;
@end

@implementation RobotCustomizationSplitViewController
@synthesize pickerViewController = _pickerViewController;
@synthesize previewViewController = _previewViewController;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithStyle:UISplitViewControllerStyleDoubleColumn]) {
        [self _ba_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _ba_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    [_pickerViewController release];
    [_previewViewController release];
    [super dealloc];
}

- (void)_ba_commonInit __attribute__((objc_direct)) {
    _robotData = {};
    
    self.delegate = self;
    
#if !TARGET_OS_VISION
    self.displayModeButtonVisibility = UISplitViewControllerDisplayModeButtonVisibilityNever;
    self.presentsWithGesture = NO;
#endif
    
    self.maximumPrimaryColumnWidth = CGFLOAT_MAX;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeOneBesideSecondary;
    self.preferredPrimaryColumnWidthFraction = 0.5;
    
    [self setViewController:self.pickerViewController forColumn:UISplitViewControllerColumnPrimary];
    [self setViewController:self.previewViewController forColumn:UISplitViewControllerColumnSecondary];
}

- (RobotCustomizationPickerViewController *)pickerViewController {
    if (auto pickerViewController = _pickerViewController) return pickerViewController;
    
    RobotCustomizationPickerViewController *pickerViewController = [RobotCustomizationPickerViewController new];
    pickerViewController.delegate = self;
    
    _pickerViewController = [pickerViewController retain];
    return [pickerViewController autorelease];
}

- (RobotPreviewViewController *)previewViewController {
    if (auto previewViewController = _previewViewController) return previewViewController;
    
    RobotPreviewViewController *previewViewController = [RobotPreviewViewController new];
    
    _previewViewController = [previewViewController retain];
    return [previewViewController autorelease];
}

- (void)robotCustomizationPickerViewController:(RobotCustomizationPickerViewController *)viewController didChangeRobotData:(RobotData)robotData {
    self.robotData = robotData;
    [self.previewViewController updateRobotData:robotData];
}

@end
