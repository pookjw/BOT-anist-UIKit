//
//  Exploration+ContentViewModel.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/21/24.
//

import Observation
import CoreGraphics
import RealityFoundation
import UniformTypeIdentifiers
import Spatial
import BOTanistAssets
import SwiftUI

extension Exploration {
    @MainActor
    @Observable
    final class ContentViewModel {
        let explorationRoot = Entity()
        let explorationCamera: PerspectiveCamera
        
        @ObservationIgnored
        private(set) var currentGrowAnimations: [PlantComponent.PlantTypeKey: AnimationPlaybackController] = [:]
        
        @ObservationIgnored
        private var movementVector = SIMD3<Float>.zero
        
        @ObservationIgnored
        private var speedScale: Float = 1.0
        
        @ObservationIgnored
        private var plantsFound = 0
        
        @ObservationIgnored
        private var isCelebrating = false
        
#if !os(visionOS)
        private(set) var environmentResource: EnvironmentResource?
#endif
        
        @ObservationIgnored
        private var robotCharacter: RobotCharacter?
        
        init() {
            let explorationCamera = PerspectiveCamera()
            explorationCamera.transform.translation = SIMD3(x: 0.0, y: 0.2, z: 0.4)
            let cameraTilt = -0.5
            let rotationAngle = Angle2D(radians: cameraTilt)
            let rotation = Rotation3D(angle: rotationAngle, axis: .x)
            explorationCamera.setOrientation(simd_quatf(rotation), relativeTo: nil)
            self.explorationCamera = explorationCamera
        }
        
        func load(robotData: RobotData) async throws {
#if !os(visionOS) && !targetEnvironment(simulator)
            environmentResource = try await makeEnvironmentResource()
#endif
            
            try await PlantAnimationProvider.shared.load()
            
            let explorationRoot = explorationRoot
            
            for child in explorationRoot.children {
                explorationRoot.removeChild(child)
            }
            
            //
            
            explorationRoot.scale = SIMD3<Float>(repeating: 0.7)
            
            let map = try await makeExplorationEnvironment()
            explorationRoot.addChild(map)
            
            //
            
            let robotCharacter = try await RobotCharacter(robotData: robotData)
            
            explorationRoot.addChild(robotCharacter.characterParent)
            
            self.robotCharacter = robotCharacter
        }
        
        func handleUpdateEvent(_ event: SceneEvents.Update) {
            // TODO: Animation
            
            let deltaTime = Float(event.deltaTime)
            
            if movementVector != .zero {
                handleNonZeroMovement(deltaTime: deltaTime)
            } else {
                handleZeroMovement(deltaTime: deltaTime)
            }
        }
        
        func handleAnimationStopEvent(_ event: AnimationEvents.PlaybackTerminated) {
            if plantsFound == PlantComponent.PlantTypeKey.allCases.count && !isCelebrating {
                guard !currentGrowAnimations.values.contains(where: { $0.isPlaying }) else {
                    return
                }
                
                isCelebrating = true
                
                var blendEntities: [Entity: PlantComponent.PlantTypeKey] = [:]
                
                explorationRoot.forEachDescendant(withComponent: PlantComponent.self) { plantEntity, plantComponent in
                    plantEntity.forEachDescendant(withComponent: BlendShapeWeightsComponent.self) { blendEntity, blendComponent in
                        blendEntities[blendEntity] = plantComponent.plantType
                        return true
                    }
                    return true
                }
                
                Task { [blendEntities] in
                    for (blendEntity, plantType) in blendEntities {
                        let celebateAnimation = await PlantAnimationProvider.shared.celebrateAnimation(for: plantType)
                        blendEntity.playAnimation(celebateAnimation.repeat())
                    }
                }
            }
        }
        
        func handleGestureChanged(_ value: DragGesture.Value) {
            guard let robotCharacter else { return }
            
            let translation = value.translation
            let movementVector = SIMD3<Float>(x: Float(translation.width), y: 0.0, z: Float(translation.height))
            
            self.movementVector = movementVector
            
            if robotCharacter.bodyEntity.components[RobotLoader.AnimationStateComponent.self]!.animationState == .idle {
                robotCharacter.playAnimation(.walkLoop)
            }
        }
        
        func handleGestureEnded(_ value: DragGesture.Value) {
            movementVector = .zero
            
            if let robotCharacter,
               robotCharacter.animationState != .celebrate {
                robotCharacter.playAnimation(.walkEnd)
            }
        }
        
        func handleKeyPress(_ press: KeyPress) {
            switch press.phase {
            case .down:
                guard let robotCharacter else {
                    return
                }
            case .up:
                break
            default:
                break
            }
        }
    }
}

extension Exploration.ContentViewModel {
#if !os(visionOS)
        private nonisolated func makeEnvironmentResource() async throws -> EnvironmentResource {
            let url = Bundle.main.url(forResource: "autumn_field_puresky_1k", withExtension: UTType.png.preferredFilenameExtension)!
            
            let urlCFString = CFStringCreateWithCString(kCFAllocatorDefault, url.absoluteString.cString(using: .utf8), CFStringBuiltInEncodings.UTF8.rawValue)
            let cfURL = CFURLCreateWithString(kCFAllocatorDefault, urlCFString, nil)!
            let dataProvider = CGDataProvider(url: cfURL)!
            
            let cgImage = CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
            
            return try await EnvironmentResource(equirectangular: cgImage)
        }
#endif
    
    private func makeExplorationEnvironment() async throws -> Entity {
        let environmentResource = try await Entity(named: "scenes/volume", in: BOTanistAssetsBundle)
        
        environmentResource.forEachDescendant(withComponent: BlendShapeWeightsComponent.self) { child, weightsComponent in
            let modelComponent = child.components[ModelComponent.self]!
            let meshResource = modelComponent.mesh
            let blendShapeWeightsMapping = BlendShapeWeightsMapping(meshResource: meshResource)
            var blendComponent = BlendShapeWeightsComponent(weightsMapping: blendShapeWeightsMapping)
            blendComponent.weightSet[0].weights = BlendShapeWeights([0, 1, 0, 0, 0, 0, 0])
            child.components.set(blendComponent)
            
            return true
        }
        
        return environmentResource
    }
}

extension Exploration.ContentViewModel {
    private func handleNonZeroMovement(deltaTime: Float) {
        guard let robotCharacter else {
            return
        }
        
        let currentAnimationSate = robotCharacter.bodyEntity.components[RobotLoader.AnimationStateComponent.self]!.animationState
        
        guard ![.celebrate, .wave].contains(currentAnimationSate) else {
            return
        }
        
        robotCharacter.idleTimer = 0.0
        
        let characterModel = robotCharacter.characterModel
        let characterParent = robotCharacter.characterParent
        let normalizedMovement = movementVector / max(100.0, length(movementVector))
        
        let speed: Float
        if currentAnimationSate == .walkEnd {
            speed = 0.001
        } else {
            speed = 0.165
        }
        
//        characterParent.position += normalizedMovement * speed * speedScale * deltaTime
        
        // CharacterControllerComponent이 있어야 작동함. collision을 자동으로 계산해줌
        characterParent.moveCharacter(
            by: normalizedMovement * speed * speedScale * deltaTime,
            deltaTime: deltaTime,
            relativeTo: nil,
            collisionHandler: { [self] collision in
                if var plantComponent = collision.hitEntity.components[PlantComponent.self] {
                    if !plantComponent.interactedWith {
                        plantComponent.interactedWith = true
                        collision.hitEntity.components.set(plantComponent)
                        
                        plantsFound += 1
                        
                        Task { [plantComponent] in
                            let growAnimation = await PlantAnimationProvider.shared.growAnimation(for: plantComponent.plantType)
                            collision.hitEntity.forEachDescendant(withComponent: BlendShapeWeightsComponent.self) { child, component in
                                let playbackController = child.playAnimation(growAnimation)
                                currentGrowAnimations[plantComponent.plantType] = playbackController
                                return true
                            }
                        }
                    }
                }
                
                if self.plantsFound == PlantComponent.PlantTypeKey.allCases.count && robotCharacter.animationState != .celebrate {
                    robotCharacter.playAnimation(.celebrate)
                }
            }
        )
        
        characterModel.look(
            at: characterModel.position(relativeTo: characterParent) - normalizedMovement,
            from: characterModel.position(relativeTo: characterParent),
            relativeTo: characterParent
        )
    }
    
    private func handleZeroMovement(deltaTime: Float) {
        guard let robotCharacter else {
            return
        }
        
        robotCharacter.idleTimer += deltaTime
        
        let idleTimeout: Float = 2.0
        
        // TODO
    }
}
