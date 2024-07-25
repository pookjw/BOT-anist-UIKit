//
//  RobotPreviewViewController.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import <UIKit/UIKit.h>
#import "RobotData.hpp"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface RobotPreviewViewController : UIViewController
- (instancetype)initWithRobotData:(RobotData)robotData;
- (void)updateRobotData:(RobotData)robotData;
@end

NS_ASSUME_NONNULL_END
