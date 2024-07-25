//
//  RobotCustomizationPickerViewModel.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import <UIKit/UIKit.h>
#import "RobotCustomizationPickerSectionModel.h"
#import "RobotCustomizationPickerItemModel.h"
#import "RobotData.hpp"
#include "swiftToCxx.h"

NS_ASSUME_NONNULL_BEGIN

typedef UICollectionViewDiffableDataSource<RobotCustomizationPickerSectionModel *, RobotCustomizationPickerItemModel *> RobotCustomizationPickerViewModelDataSource;

NSNotificationName const RobotCustomizationPickerViewModelRobotDataDidChangeNotificationName = @"RobotCustomizationPickerViewModelRobotDataDidChangeNotificationName";
NSString * const RobotCustomizationPickerViewModelRobotDataKey = @"robotData";

__attribute__((objc_direct_members))
@interface RobotCustomizationPickerViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(RobotCustomizationPickerViewModelDataSource *)dataSource;
- (void)updateDataSourceWithSelectedPart:(RobotData::Part)part;
- (void)handleSelectedIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
