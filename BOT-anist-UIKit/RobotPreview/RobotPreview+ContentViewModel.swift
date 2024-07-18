//
//  RobotPreview+ContentViewModel.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

import RealityKit
import Observation
import BOTanistAssets

extension RobotPreview {
    @Observable
    @MainActor
    final class ContentViewModel {
        private(set) var robotParts: [RobotPartResult] = []
        private(set) var robotMaterials: [RobotMaterialResult] = []
        
        func load() async throws {
            let robotParts = try await robotParts()
            let robotMaterials = try await robotMaterials()
            
            self.robotParts = robotParts
            self.robotMaterials = robotMaterials
        }
    }
}

extension RobotPreview.ContentViewModel {
    struct RobotPartResult: Sendable {
        let part: RobotData.Part
        let entity: Entity
        let index: Int
    }
    
    private func robotParts() async throws -> [RobotPartResult] {
        try await withThrowingTaskGroup(of: RobotPartResult.self, returning: [RobotPartResult].self) { taskGroup in
            RobotData.allParts().forEach { robotPart in
                for index in 1...3 {
                    taskGroup.addTask {
                        let entityName: String
                        let sceneName: String
                        
                        switch robotPart {
                        case .Head:
                            entityName = "head\(index)"
                            sceneName = "scenes/head\(index)"
                        case .Body:
                            entityName = "body\(index)"
                            sceneName = "scenes/body\(index)"
                        case .Backpack:
                            entityName = "backpack\(index)"
                            sceneName = "scenes/backpack\(index)"
                        @unknown default:
                            fatalError()
                        }
                        
                        let scene = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
                        let entity = await scene.findEntity(named: entityName)
                        
                        if robotPart == .Head {
                            // TODO: Animation
//                            var libComponent = AnimationLibraryComponent()
//                            let animation
                        }
                        
                        return RobotPartResult(part: robotPart, entity: entity!, index: index)
                    }
                }
            }
            
            //
            
            var results: [RobotPartResult] = []
            
            for try await value in taskGroup {
                results.append(value)
            }
            
            return results
        }
    }
}

extension RobotPreview.ContentViewModel {
    struct RobotMaterialResult: @unchecked Sendable {
        let robotMaterial: RobotData.Material
        let materialsByPart: [RobotData.Part: [ShaderGraphMaterial]]
    }
    
    private func robotMaterials() async throws -> [RobotMaterialResult] {
        try await withThrowingTaskGroup(of: RobotMaterialResult.self, returning: [RobotMaterialResult].self) { taskGroup in
            RobotData.allMaterials().forEach { material in
                taskGroup.addTask { @MainActor in
                    let sceneName: String
                    
                    switch material {
                    case .Metal:
                        sceneName = "Materials/M_metal"
                    case .Rainbow:
                        sceneName = "Materials/M_rainbow"
                    case .Plastic:
                        sceneName = "Materials/M_plastic"
                    case .Mesh:
                        sceneName = "Materials/M_mesh"
                    @unknown default:
                        fatalError()
                    }
                    
                    let scene = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
                    var materialsByPart: [RobotData.Part: [ShaderGraphMaterial]] = [:]
                    
                    RobotData.allParts().forEach { part in
                        let suffix: String
                        
                        switch part {
                        case .Head:
                            suffix = "H"
                        case .Body:
                            suffix = "B"
                        case .Backpack:
                            suffix = "BP"
                        @unknown default:
                            fatalError()
                        }
                        
                        for index in 1...3 {
                            let entityName = "\(suffix)\(index)"
                            let entity = scene.findEntity(named: entityName)!
                            let modelComponent = entity.components[ModelComponent.self]!
                            let material = modelComponent.materials.first as! ShaderGraphMaterial
                            
                            var materials: [ShaderGraphMaterial] = materialsByPart[part] ?? []
                            materials.append(material)
                            materialsByPart[part] = materials
                        }
                    }
                    
                    return RobotMaterialResult(robotMaterial: material, materialsByPart: materialsByPart)
                }
            }
            
            //
            
            var results: [RobotMaterialResult] = []
            
            for try await value in taskGroup {
                results.append(value)
            }
            
            return results
        }
    }
}
