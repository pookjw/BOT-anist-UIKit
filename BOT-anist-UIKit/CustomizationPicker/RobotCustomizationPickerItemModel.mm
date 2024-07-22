//
//  RobotCustomizationPickerItemModel.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

#import "RobotCustomizationPickerItemModel.h"

@implementation RobotCustomizationPickerItemModel

- (instancetype)initWithVariant:(RobotCustomizationPickerItemModelVariant)variant sectionModel:(RobotCustomizationPickerSectionModel *)sectionModel {
    if (self = [super init]) {
        _variant = variant;
        _sectionModel = [sectionModel retain];
    }
    
    return self;
}

- (void)dealloc {
    [_sectionModel release];
    [super dealloc];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        auto casted = static_cast<decltype(self)>(other);
        
        return _variant == casted->_variant &&
        [_sectionModel isEqual:casted->_sectionModel];
    }
}

- (NSUInteger)hash {
//    return std::hash<RobotCustomizationPickerItemModelVariant>{}(_variant) ^
//    _sectionModel.hash;
    return std::hash<RobotCustomizationPickerItemModelVariant>{}(_variant);
}

@end
