//
//  RobotData.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

#import "RobotData.hpp"

std::array<RobotData::MaterialColor, 4> RobotData::getMaterialColorsByMaterial(RobotData::Material material) {
    switch (material) {
        case MetalMaterial:
            return {
                MetalPinkMaterialColor,
                MetalOrangeMaterialColor,
                MetalGreenMaterialColor,
                MetalBlueMaterialColor
            };
        case RainbowMaterial:
            return {
                BeigeMaterialColor,
                RainbowRedMaterialColor,
                RoseMaterialColor,
                BlackMaterialColor
            };
        case PlasticMaterial:
            return {
                PlasticBlueMaterialColor,
                PlasticPinkMaterialColor,
                PlasticOrangeMaterialColor,
                PlasticGreenMaterialColor
            };
        case MeshMaterial:
            return {
                MeshGrayMaterialColor,
                MeshOrangeMaterialColor,
                MeshYellowMaterialColor,
                BlackMaterialColor
            };
        default:
            abort();
    }
}

RobotData::RobotData() {
    materials = {
        {HeadPart, PlasticMaterial},
        {BodyPart, PlasticMaterial},
        {BackpackPart, PlasticMaterial}
    };
    
    materialColor = {
        {HeadPart, PlasticBlueMaterialColor},
        {BodyPart, PlasticBlueMaterialColor},
        {BackpackPart, PlasticBlueMaterialColor}
    };
    
    lightColor = {
        {HeadPart, WhiteLightColor},
        {BodyPart, WhiteLightColor},
        {BackpackPart, WhiteLightColor}
    };
}
