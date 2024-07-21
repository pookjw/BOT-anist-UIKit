//
//  Exploration+RobotCharacter.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/21/24.
//

import RealityFoundation
import Combine

extension Exploration {
    @MainActor
    final class RobotCharacter {
        let characterParent: Entity
        private let characterModel: Entity
        private let headEntity: Entity
        let bodyEntity: Entity
        private let backpackEntity: Entity
        
        
        var isRotatingToFaceFront = false // TODO
        private var animationControllers: [RobotLoader.AnimationState: AnimationPlaybackController] = [:]
        
        private var idleTimer: Float = 0.0
        
        private var cancellables = Set<AnyCancellable>()
        
        init(robotData: RobotData) async throws {
            let loader = RobotLoader.shared
            try await loader.load()
            
            //
            
            let characterParent = Entity()
            let characterModel = Entity()
            
            characterParent.addChild(characterModel)
            characterParent.scale = SIMD3<Float>(repeating: 0.065)
            
            //
            
            // TODO: Collision
            
            let collisionCapsuleRadius: Float = 0.2
            let collisionCapsuleHeight: Float = 2.0
            
            characterParent
                .components
                .set(
                    CharacterControllerComponent(
                        radius: collisionCapsuleRadius,
                        height: collisionCapsuleHeight,
                        slopeLimit: 0.0,
                        stepLimit: 0.0
                    )
                )
            
            characterParent.setPosition([0.0, collisionCapsuleHeight * 0.5 * 0.065, 0], relativeTo: nil)
            characterModel.setPosition([0.0, collisionCapsuleHeight * -0.5, 0.0], relativeTo: characterParent)
            
            //
            
            let headEntity = try await loader.entity(forPart: .Head, robotData: robotData)
            let bodyEntity = try await loader.entity(forPart: .Body, robotData: robotData)
            let backpackEntity = try await loader.entity(forPart: .Backpack, robotData: robotData)
            
            characterModel.addChild(headEntity)
            characterModel.addChild(bodyEntity)
            characterModel.addChild(backpackEntity)
            
            //
            
            
            //
            
            
            // TODO: Skeleton : WWDC에 하는 방법 있음
//            let skeleton = bodyEntity.findEntity(named: "rig_grp") as! ModelEntity
            
            //
            
            self.characterParent = characterParent
            self.characterModel = characterModel
            self.headEntity = headEntity
            self.bodyEntity = bodyEntity
            self.backpackEntity = backpackEntity
        }
        
        func playAnimation(_ animationState: RobotLoader.AnimationState) {
            let libComponent = bodyEntity.components[AnimationLibraryComponent.self]!
            let animation = libComponent[animationState.rawValue]!
            let rigGroup = bodyEntity.findEntity(named: "rig_grp")!
            
            switch animationState.loopingBehavior {
            case .infinite:
                if !isRotatingToFaceFront {
                    let playbackController = rigGroup
                        .playAnimation(
                            animation.repeat(),
                            separateAnimatedValue: true,
                            startsPaused: false
                        )
                    
                    animationControllers[animationState] = playbackController
                }
            case .finite(let times):
                let playbackController = rigGroup
                    .playAnimation(
                        animation.repeat(count: times),
                        separateAnimatedValue: true,
                        startsPaused: false
                    )
                
                animationControllers[animationState] = playbackController
                
                rigGroup
                    .scene!
                    .publisher(for: AnimationEvents.PlaybackCompleted.self, on: rigGroup)
                    .sink { [unowned self] _ in
                        let currentState = bodyEntity.components[RobotLoader.AnimationStateComponent.self]!.animationState
                        
                        if currentState != currentState.nextState {
                            playAnimation(animationState.nextState)
                        } else {
                            if currentState != .idle {
                                idleTimer = 0.0
                            }
                        }
                    }
                    .store(in: &cancellables)
            }
            
            bodyEntity.components.set(RobotLoader.AnimationStateComponent(animationState: animationState))
            
        }
    }
}
