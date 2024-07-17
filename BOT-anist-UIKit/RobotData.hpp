//
//  RobotData.hpp
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

#ifndef Robot_hpp
#define Robot_hpp

#include <stdio.h>
#include <unordered_map>
#include <array>

class RobotData {
public:
    enum Part {
        HeadPart, BodyPart, BackpackPart
    };
    
    enum Material {
        MetalMaterial, RainbowMaterial, PlasticMaterial, MeshMaterial
    };
    
    enum MaterialColor {
        MetalPinkMaterialColor, MetalOrangeMaterialColor, MetalGreenMaterialColor, MetalBlueMaterialColor,
        BeigeMaterialColor, RainbowRedMaterialColor, RoseMaterialColor, BlackMaterialColor,
        PlasticBlueMaterialColor, PlasticPinkMaterialColor, PlasticOrangeMaterialColor, PlasticGreenMaterialColor,
        MeshGrayMaterialColor, MeshOrangeMaterialColor, MeshYellowMaterialColor
    };
    
    enum LightColor {
        RedLightColor, YellowLightColor, GreenLightColor, BlueLightColor, PurpleLightColor, WhiteLightColor, PurpleBlueLightColor, RainbowLightColor
    };
    
    static std::array<MaterialColor, 4> getMaterialColorsByMaterial(Material material);
    
    RobotData();
    
    void setMaterialByPart(Material material, Part part);
    Material getMaterialByPart(Part part);
    
    void setMaterialColorByPart(MaterialColor materialColor, Part part);
    MaterialColor getMaterialColorByPart(Part part);
    
    void setLightColorByPart(LightColor lightColor, Part part);
    LightColor getLightColorByPart(Part part);
private:
    std::unordered_map<Part, Material> materials;
    std::unordered_map<Part, MaterialColor> materialColor;
    std::unordered_map<Part, LightColor> lightColor;
};

#endif /* Robot_hpp */
