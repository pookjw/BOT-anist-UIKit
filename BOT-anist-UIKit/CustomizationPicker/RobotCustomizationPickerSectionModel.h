//
//  RobotCustomizationPickerSectionModel.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RobotCustomizationPickerSectionModelType) {
    RobotCustomizationPickerSectionModelTypePartIndex,
    RobotCustomizationPickerSectionModelTypeFace,
    RobotCustomizationPickerSectionModelTypeMaterial,
    RobotCustomizationPickerSectionModelTypeMaterialColor,
    RobotCustomizationPickerSectionModelTypeLightColor
};

__attribute__((objc_direct_members))
@interface RobotCustomizationPickerSectionModel : NSObject
@property (assign, nonatomic, readonly) RobotCustomizationPickerSectionModelType type;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(RobotCustomizationPickerSectionModelType)type;
@end

NS_ASSUME_NONNULL_END
