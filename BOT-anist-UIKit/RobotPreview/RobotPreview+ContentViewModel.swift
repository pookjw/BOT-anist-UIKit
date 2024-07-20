//
//  RobotPreview+ContentViewModel.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

@preconcurrency import RealityFoundation
import Observation
import SwiftUI
import Spatial
import _RealityKit_SwiftUI

extension RobotPreview {
    @Observable
    @MainActor
    final class ContentViewModel {
        let robotCamera: PerspectiveCamera
        let creationRoot = Entity()
        
        @ObservationIgnored
        private var robotCreationOrientation: Rotation3D?
        
        init() {
            let robotCamera = PerspectiveCamera()
            robotCamera.transform.translation = SIMD3(x: 0, y: 0.1, z: 0.3)
            
            self.robotCamera = robotCamera
        }
        
        func load(robotData: RobotData) async throws {
            let loader = RobotLoader.shared
            
            try await loader.load()
            
            let creationRoot = creationRoot
            
            let children = creationRoot.children
            for child in children {
                creationRoot.removeChild(child)
            }
            
#if os(macOS) || os(iOS)
            creationRoot.scale = SIMD3<Float>(repeating: 0.15)
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
                        
                        //
                        
                        let selectedIndex = robotData.getSelectedIndexByPart(part)
                        let material = robotData.getMaterialByPart(part)
                        
                        let shaderGraphMaterial = await loader.shaderGraphMaterial(forMaterial: material, part: part, index: selectedIndex)
                        
                        //
                        
                        try entity.forEachDescendant(withComponent: ModelComponent.self) { child, component in
                            var modelComponent = component
                            
                            try modelComponent.materials = modelComponent
                                .materials
                                .map {
                                    guard let oldMaterial = $0 as? ShaderGraphMaterial else {
                                        return $0
                                    }
                                    
                                    var newMaterial: ShaderGraphMaterial
                                    if oldMaterial.name!.contains("_\(part.suffix)") {
                                        newMaterial = shaderGraphMaterial
                                    } else {
                                        newMaterial = oldMaterial
                                    }
                                    
                                    if newMaterial.parameterNames.contains("mat_switch") {
                                        let materialColor = robotData.getMaterialColorByPart(part)
                                        let colorIndex = materialColor.index(byMaterial: material)
                                        
                                        try newMaterial.setParameter(name: "mat_switch", value: MaterialParameters.Value.int(Int32(colorIndex)))
                                    }
                                    
                                    if newMaterial.parameterNames.contains("light_switch") {
                                        let lightColor = robotData.getLightColorByPart(part)
                                        let colorIndex = lightColor.index
                                        
                                        try newMaterial.setParameter(name: "light_switch", value: MaterialParameters.Value.int(Int32(colorIndex)))
                                    }
                                    
                                    if part == .Head {
                                        if newMaterial.parameterNames.contains("face_switch") {
                                            let face = robotData.getFace()
                                            let faceIndex = face.index
                                            
                                            try newMaterial.setParameter(name: "face_switch", value: MaterialParameters.Value.int(Int32(faceIndex)))
                                        }
                                    }
                                    
                                    return newMaterial
                                }
                            
                            child.components.set(modelComponent)
                        }
                        
                        //
                        
                        if part == .Backpack {
                            let bodyIndex = robotData.getSelectedIndexByPart(.Body)
                            
                            for index in 1...3 {
                                let isEnabled = bodyIndex == index
                                entity.findEntity(named: "strap_B\(index)")!.isEnabled = isEnabled
                            }
                        }
                        
                        //
                        
                        creationRoot.addChild(entity)
                    }
                }
            }
        }
        
        func onDragGestureChanged(_ value: EntityTargetValue<DragGesture.Value>) {
            var robotCreationOrientation: Rotation3D
            if let _robotCreationOrientation: Rotation3D = self.robotCreationOrientation {
                robotCreationOrientation = _robotCreationOrientation
            } else {
                robotCreationOrientation = Rotation3D(creationRoot.orientation(relativeTo: nil))
                self.robotCreationOrientation = robotCreationOrientation
            }
            
            let yRotation = value.gestureValue.translation.width / 100.0
            let rotationAngle = Angle2D(radians: yRotation)
            let rotation = Rotation3D(angle: rotationAngle, axis: .y)
            
            robotCreationOrientation.rotate(by: rotation)
            creationRoot.setOrientation(simd_quatf(robotCreationOrientation), relativeTo: nil)
        }
        
        func onDragGestureEnded(_ value: EntityTargetValue<DragGesture.Value>) {
            robotCreationOrientation = nil
        }
    }
}
