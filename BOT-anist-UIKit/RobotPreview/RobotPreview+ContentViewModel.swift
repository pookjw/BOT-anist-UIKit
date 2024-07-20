//
//  RobotPreview+ContentViewModel.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

@preconcurrency import RealityFoundation
import Observation

extension RobotPreview {
    @Observable
    @MainActor
    final class ContentViewModel {
        private(set) var creationRoot: Entity?
        
        func load(robotData: RobotData) async throws {
            let loader = RobotLoader.shared
            
            try await loader.load()
            
            let creationRoot = Entity()
            
#if os(macOS) || os(iOS)
            creationRoot.scale = SIMD3<Float>(repeating: 0.027)
            creationRoot.position = SIMD3<Float>(x: -0, y: -0.022, z: -0.05)
#else
            creationRoot.scale = SIMD3<Float>(repeating: 0.23)
            creationRoot.position = SIMD3<Float>(x: -0.02, y: -0.175, z: -0.05)
#endif
            
            //
            
            try await withThrowingDiscardingTaskGroup { taskGroup in
                RobotData.allParts().forEach { part in
                    taskGroup.addTask { @MainActor in
                        let entity = await loader.entity(forPart: part, index: robotData.getSelectedIndexByPart(part))
                        entity.components.set(InputTargetComponent())
                        creationRoot.addChild(entity)
                        
                        //
                        
                        let selectedIndex = robotData.getSelectedIndexByPart(part)
                        let material = robotData.getMaterialByPart(part)
                        
                        var shaderGraphMaterial = await loader.shaderGraphMaterial(forMaterial: material, part: part, index: selectedIndex)
                        
                        if shaderGraphMaterial.parameterNames.contains("mat_switch") {
                            let materialColor = robotData.getMaterialColorByPart(part)
                            let colorIndex = materialColor.index(byMaterial: material)
                            
                            try shaderGraphMaterial.setParameter(name: "mat_switch", value: MaterialParameters.Value.int(Int32(colorIndex)))
                        }
                        
                        if shaderGraphMaterial.parameterNames.contains("light_switch") {
                            let lightColor = robotData.getLightColorByPart(part)
                            let colorIndex = lightColor.index
                            
                            try shaderGraphMaterial.setParameter(name: "light_switch", value: MaterialParameters.Value.int(Int32(colorIndex)))
                        }
                        
                        if part == .Head {
                            if shaderGraphMaterial.parameterNames.contains("face_switch") {
                                let face = robotData.getFace()
                                let faceIndex = face.index
                                
                                try shaderGraphMaterial.setParameter(name: "face_switch", value: MaterialParameters.Value.int(Int32(faceIndex)))
                            }
                        }
                        
                        entity.forEachDescendant(withComponent: ModelComponent.self) { child, component in
                            var modelComponent = component
                            
                            modelComponent.materials = modelComponent
                                .materials
                                .map {
                                    guard let oldMaterial = $0 as? ShaderGraphMaterial else {
                                        return $0
                                    }
                                    
                                    if oldMaterial.name!.contains("_\(part.suffix)") {
                                        return shaderGraphMaterial
                                    } else {
                                        return $0
                                    }
                                }
                            
                            entity.components.set(modelComponent)
                        }
                    }
                }
            }
            
            self.creationRoot = creationRoot
        }
    }
}
