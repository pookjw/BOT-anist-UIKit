//
//  Exploration+RobotCharacter.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/21/24.
//

import RealityFoundation

extension Exploration {
    @MainActor
    final class RobotCharacter {
        let characterParent: Entity
        private let characterModel: Entity
        
        init(robotData: RobotData) async throws {
            let loader = RobotLoader.shared
            try await loader.load()
            
            //
            
            let characterParent = Entity()
            let characterModel = Entity()
            
            characterParent.addChild(characterModel)
            characterParent.scale = SIMD3<Float>(repeating: 0.065)
            
            //
            
            let collisionCapsuleRadius: Float = 0.2
            let collisionCapsuleHeight: Float = 2.0
            
//            characterParent.setPosition([0.0, collisionCapsuleHeight * 0.5 * 0.065, 0], relativeTo: nil)
//            characterModel.setPosition([0.0, collisionCapsuleHeight * -0.5, 0.0], relativeTo: characterParent)
            
            //
            
            let headEntity = try await loader.entity(forPart: .Head, robotData: robotData)
            let bodyEntity = try await loader.entity(forPart: .Body, robotData: robotData)
            let backpackEntity = try await loader.entity(forPart: .Backpack, robotData: robotData)
            
            characterModel.addChild(headEntity)
            characterModel.addChild(bodyEntity)
            characterModel.addChild(backpackEntity)
            
            //
            
            
            //
            
//            let skeleton = bodyEntity.findEntity(named: "rig_grp") as! ModelEntity
            
            //
            
            self.characterParent = characterParent
            self.characterModel = characterModel
        }
    }
}
