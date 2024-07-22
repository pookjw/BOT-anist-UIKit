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

NS_ASSUME_NONNULL_BEGIN

typedef UICollectionViewDiffableDataSource<RobotCustomizationPickerSectionModel *, RobotCustomizationPickerItemModel *> RobotCustomizationPickerViewModelDataSource;

__attribute__((objc_direct_members))
@interface RobotCustomizationPickerViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(RobotCustomizationPickerViewModelDataSource *)dataSource;
- (void)updateDataSourceWithSelectedPart:(RobotData::Part)part selectedMaterial:(RobotData::Material)material;
@end

NS_ASSUME_NONNULL_END
