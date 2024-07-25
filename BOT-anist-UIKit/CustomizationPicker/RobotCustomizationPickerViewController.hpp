//
//  RobotCustomizationPickerViewController.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import <UIKit/UIKit.h>
#import "RobotData.hpp"

NS_ASSUME_NONNULL_BEGIN

@class RobotCustomizationPickerViewController;
@protocol RobotCustomizationPickerViewControllerDelegate <NSObject>
- (void)robotCustomizationPickerViewController:(RobotCustomizationPickerViewController *)viewController didChangeRobotData:(RobotData)robotData;
@end

__attribute__((objc_direct_members))
@interface RobotCustomizationPickerViewController : UIViewController
@property (weak, nonatomic) id<RobotCustomizationPickerViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
