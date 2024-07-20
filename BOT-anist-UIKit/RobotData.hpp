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
#include "swiftToCxx.h"

class RobotData {
public:
    enum class Part {
        Head, Body, Backpack
    };
    
    static std::array<Part, 3> allParts();
    
    enum class Material {
        Metal, Rainbow, Plastic, Mesh
    };
    
    static std::array<Material, 4> allMaterials();
    
    enum class Face {
        Square,
        Circle,
        Heart
    };
    
    enum class MaterialColor {
        MetalPink,
        MetalOrange,
        MetalGreen,
        MetalBlue,
        Beige,
        RainbowRed,
        Rose,
        Black,
        PlasticBlue,
        PlasticPink,
        PlasticOrange,
        PlasticGreen,
        MeshGray,
        MeshOrange,
        MeshYellow
    };
    
    static std::array<MaterialColor, 15> allMaterialColors();
    
    enum class LightColor {
        Red,
        Yellow,
        Green,
        Blue,
        Purple,
        White,
        PurpleBlue,
        Rainbow
    };
    
    static std::array<LightColor, 8> allLightColors();
    
    //
    
    static std::array<MaterialColor, 4> getMaterialColorsByMaterial(Material material);
    
    RobotData();
    
    void setFace(Face face);
    Face getFace() const;
    
    void setSelectedIndexByPart(Part part, swift::Int selectedIndex);
    swift::Int getSelectedIndexByPart(Part part) const;
    
    void setMaterialByPart(Material material, Part part);
    Material getMaterialByPart(Part part) const;
    
    void setMaterialColorByPart(MaterialColor materialColor, Part part);
    MaterialColor getMaterialColorByPart(Part part) const;
    
    void setLightColorByPart(LightColor lightColor, Part part);
    LightColor getLightColorByPart(Part part) const;
private:
    Face face;
    std::unordered_map<Part, swift::Int> selectedIndicesByPart;
    std::unordered_map<Part, Material> materialsByPart;
    std::unordered_map<Part, MaterialColor> materialColorsByPart;
    std::unordered_map<Part, LightColor> lightColorsByPart;
};

#endif /* Robot_hpp */
