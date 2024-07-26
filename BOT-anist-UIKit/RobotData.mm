//
//  RobotData.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

#import "RobotData.hpp"
#include <algorithm>

RobotData::RobotData() {
    face = Face::Circle;
    
    selectedIndicesByPart = {
        {Part::Head, 2},
        {Part::Body, 2},
        {Part::Backpack, 1}
    };
    
    materialsByPart = {
        {Part::Head, Material::Plastic},
        {Part::Body, Material::Plastic},
        {Part::Backpack, Material::Plastic}
    };
    
    materialColorsByPart = {
        {Part::Head, MaterialColor::PlasticBlue},
        {Part::Body, MaterialColor::PlasticBlue},
        {Part::Backpack, MaterialColor::PlasticBlue}
    };
    
    lightColorsByPart = {
        {Part::Head, LightColor::White},
        {Part::Body, LightColor::White},
        {Part::Backpack, LightColor::White}
    };
}

const RobotData RobotData::getRobotDataFromNSData(NSData *data) {
    // https://x.com/_silgen_name/status/1816481593869103433
    const RobotData robotData = *reinterpret_cast<const RobotData *>(data.bytes);
    return robotData;
}

bool RobotData::operator==(const RobotData &other) const {
    return this->face == other.face &&
    this->selectedIndicesByPart == other.selectedIndicesByPart &&
    this->materialsByPart == other.materialsByPart &&
    this->materialColorsByPart == other.materialColorsByPart &&
    this->lightColorsByPart == other.lightColorsByPart;
}

bool RobotData::operator!=(const RobotData &other) const {
    return !(*this == other);
}

NSData * RobotData::getNSData() const {
    // https://x.com/_silgen_name/status/1816481593869103433
    RobotData *copyPtr = new RobotData(*this);
    
    NSData *data = [[NSData alloc] initWithBytesNoCopy:copyPtr length:sizeof(RobotData) deallocator:^(void * _Nonnull bytes, NSUInteger length) {
        delete reinterpret_cast<RobotData *>(bytes);
    }];
    
    return [data autorelease];
}

void RobotData::setFace(Face face) {
    this->face = face;
}

RobotData::Face RobotData::getFace() const {
    return face;
}

void RobotData::setSelectedIndexByPart(Part part, swift::Int selectedIndex) {
    auto indices = RobotData::getIndicesByPart(part);
    auto it = std::find(indices.cbegin(), indices.cend(), selectedIndex);
    assert(it != indices.end());
    
    selectedIndicesByPart[part] = selectedIndex;
}

swift::Int RobotData::getSelectedIndexByPart(Part part) const {
    return selectedIndicesByPart.at(part);
}

void RobotData::setMaterialByPart(Material material, Part part) {
    materialsByPart[part] = material;
}

RobotData::Material RobotData::getMaterialByPart(Part part) const {
    return materialsByPart.at(part);
}

void RobotData::setMaterialColorByPart(MaterialColor materialColor, Part part) {
    auto arr = getMaterialColorsByMaterial(getMaterialByPart(part));
    auto it = std::find(arr.cbegin(), arr.cend(), materialColor);
    assert(it != arr.end());
    
    materialColorsByPart[part] = materialColor;
}

RobotData::MaterialColor RobotData::getMaterialColorByPart(Part part) const {
    return materialColorsByPart.at(part);
}

void RobotData::setLightColorByPart(LightColor lightColor, Part part) {
    lightColorsByPart[part] = lightColor;
}

RobotData::LightColor RobotData::getLightColorByPart(Part part)  const{
    return lightColorsByPart.at(part);
}
