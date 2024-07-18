//
//  RobotData.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

#import "RobotData.hpp"

std::array<RobotData::Part, 3> RobotData::allParts() {
    return {
        Part::Head, Part::Body, Part::Backpack
    };
}

std::array<RobotData::Material, 4> RobotData::allMaterials() {
    return {
        Material::Metal, Material::Rainbow, Material::Plastic, Material::Mesh
    };
}

std::array<RobotData::MaterialColor, 15> RobotData::allMaterialColors() {
    return {
        MaterialColor::MetalPink,
        MaterialColor::MetalOrange,
        MaterialColor::MetalGreen,
        MaterialColor::MetalBlue,
        MaterialColor::Beige,
        MaterialColor::RainbowRed,
        MaterialColor::Rose,
        MaterialColor::Black,
        MaterialColor::PlasticBlue,
        MaterialColor::PlasticPink,
        MaterialColor::PlasticOrange,
        MaterialColor::PlasticGreen,
        MaterialColor::MeshGray,
        MaterialColor::MeshOrange,
        MaterialColor::MeshYellow
    };
}

std::array<RobotData::LightColor, 8> RobotData::allLightColors() {
    return {
        LightColor::Red,
        LightColor::Yellow,
        LightColor::Green,
        LightColor::Blue,
        LightColor::Purple,
        LightColor::White,
        LightColor::PurpleBlue,
        LightColor::Rainbow
    };
}

std::array<RobotData::MaterialColor, 4> RobotData::getMaterialColorsByMaterial(RobotData::Material material) {
    switch (material) {
        case Material::Metal:
            return {
                MaterialColor::MetalPink,
                MaterialColor::MetalOrange,
                MaterialColor::MetalGreen,
                MaterialColor::MetalBlue
            };
        case Material::Rainbow:
            return {
                MaterialColor::Beige,
                MaterialColor::RainbowRed,
                MaterialColor::Rose,
                MaterialColor::Black
            };
        case Material::Plastic:
            return {
                MaterialColor::PlasticBlue,
                MaterialColor::PlasticPink,
                MaterialColor::PlasticOrange,
                MaterialColor::PlasticGreen
            };
        case Material::Mesh:
            return {
                MaterialColor::MeshGray,
                MaterialColor::MeshOrange,
                MaterialColor::MeshYellow,
                MaterialColor::Black
            };
        default:
            abort();
    }
}

RobotData::RobotData() {
    materials = {
        {Part::Head, Material::Plastic},
        {Part::Body, Material::Plastic},
        {Part::Backpack, Material::Plastic}
    };
    
    materialColor = {
        {Part::Head, MaterialColor::PlasticBlue},
        {Part::Body, MaterialColor::PlasticBlue},
        {Part::Backpack, MaterialColor::PlasticBlue}
    };
    
    lightColor = {
        {Part::Head, LightColor::White},
        {Part::Body, LightColor::White},
        {Part::Backpack, LightColor::White}
    };
}
