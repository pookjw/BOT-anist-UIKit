//
//  RobotCustomizationPickerItemModel.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

#import "RobotCustomizationPickerItemModel.h"

@implementation RobotCustomizationPickerItemModel

- (instancetype)initWithVariant:(RobotCustomizationPickerItemModelVariant)variant sectionModel:(RobotCustomizationPickerSectionModel *)sectionModel selectedPart:(RobotData::Part)selectedPart {
    if (self = [super init]) {
        _variant = variant;
        _sectionModel = [sectionModel retain];
        _selectedPart = selectedPart;
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
        [_sectionModel isEqual:casted->_sectionModel] &&
        _selectedPart == casted->_selectedPart;
    }
}

- (NSUInteger)hash {
//    return std::hash<RobotCustomizationPickerItemModelVariant>{}(_variant) ^
//    _sectionModel.hash;
    return std::hash<RobotCustomizationPickerItemModelVariant>{}(_variant) ^ std::hash<RobotData::Part>{}(_selectedPart);
}

@end
