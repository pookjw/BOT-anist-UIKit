//
//  ExplorationBoardViewController.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/26/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ExplorationBoardViewController : UIViewController
- (instancetype)initWithSessionUUID:(NSUUID *)sessionUUID;
@end

NS_ASSUME_NONNULL_END
