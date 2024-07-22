//
//  RobotData.hpp
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

#ifndef Robot_hpp
#define Robot_hpp

#import <Foundation/Foundation.h>
#include <unordered_map>
#include <array>
#include <vector>
#include <ranges>
#include "swiftToCxx.h"

class RobotData {
public:
    enum class Part {
        Head, Body, Backpack
    };
    
    constexpr static std::array<Part, 3> getAllParts() {
        return {
            Part::Head,
            Part::Body,
            Part::Backpack
        };
    };
    
    constexpr static std::vector<swift::Int> getIndicesByPart(Part part) {
        // {1, 2, 3}
        return std::views::iota(1, 4) |
        std::ranges::to<std::vector<swift::Int>>();
    }
    
    enum class Material {
        Metal, Rainbow, Plastic, Mesh
    };
    
    constexpr static std::array<Material, 4> getAllMaterials() {
        return {
            Material::Metal,
            Material::Rainbow,
            Material::Plastic,
            Material::Mesh
        };
    };
    
    enum class Face {
        Square,
        Circle,
        Heart
    };
    
    constexpr static std::array<Face, 3> getAllFaces() {
        return {
            Face::Square,
            Face::Circle,
            Face::Heart
        };
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
    
    constexpr static std::array<MaterialColor, 15> getAllMaterialColors() {
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
    };
    
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
    
    constexpr static std::array<LightColor, 8> getAllLightColors() {
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
    
    //
    
    constexpr static std::array<MaterialColor, 4> getMaterialColorsByMaterial(Material material) {
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
    };
    
    //
    
    RobotData();
    
    bool operator==(const RobotData &other) const;
    bool operator!=(const RobotData &other) const;
    
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
