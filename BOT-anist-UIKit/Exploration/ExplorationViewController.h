//
//  ExplorationViewController.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

#import <UIKit/UIKit.h>
#include "RobotData.hpp"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ExplorationViewController : UIViewController
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithRobotData:(const RobotData)robotData;
@end

NS_ASSUME_NONNULL_END
