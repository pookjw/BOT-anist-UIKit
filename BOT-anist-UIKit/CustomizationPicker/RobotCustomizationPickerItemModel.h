//
//  RobotCustomizationPickerItemModel.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

#import <Foundation/Foundation.h>
#import "RobotCustomizationPickerSectionModel.h"
#import "RobotData.hpp"
#include <variant>
#include "swiftToCxx.h"

NS_ASSUME_NONNULL_BEGIN

typedef std::variant<swift::Int, RobotData::Face, RobotData::Material, RobotData::MaterialColor, RobotData::LightColor> RobotCustomizationPickerItemModelVariant;

__attribute__((objc_direct_members))
@interface RobotCustomizationPickerItemModel : NSObject
@property (assign, readonly, nonatomic) RobotCustomizationPickerItemModelVariant variant;
@property (retain, readonly, nonatomic) RobotCustomizationPickerSectionModel *sectionModel;
@property (assign, readonly, nonatomic) RobotData::Part selectedPart;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithVariant:(RobotCustomizationPickerItemModelVariant)variant sectionModel:(RobotCustomizationPickerSectionModel *)sectionModel selectedPart:(RobotData::Part)selectedPart;
@end

NS_ASSUME_NONNULL_END
