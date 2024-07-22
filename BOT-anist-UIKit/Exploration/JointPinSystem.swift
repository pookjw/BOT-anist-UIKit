//
//  JointPinSystem.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/23/24.
//

import RealityFoundation

struct JointPinSystem: System {
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let skeletonQuery = EntityQuery(where: .has(JointPinComponent.self))
        
        for case let skeleton as ModelEntity in context.entities(matching: skeletonQuery, updatingSystemWhen: .rendering) {
            let jointPinComponent = skeleton.components[JointPinComponent.self]!
            let transforms = skeleton.jointTransforms
            
            pinEntity(
                indices: jointPinComponent.headJointIndices,
                skeleton: skeleton,
                transforms: transforms,
                offset: jointPinComponent.headOffset,
                staticEntity: jointPinComponent.headEntity,
                shouldRotate: jointPinComponent.bodyEntity.name == "body1"
            )
            
            pinEntity(
                indices: jointPinComponent.backpackJointIndices,
                skeleton: skeleton,
                transforms: transforms,
                offset: jointPinComponent.backpackOffset,
                staticEntity: jointPinComponent.backpackEntity,
                shouldRotate: false
            )
        }
    }
    
    @MainActor
    @inline(__always)
    private func pinEntity(
        indices: [Int],
        skeleton: ModelEntity,
        transforms: [Transform],
        offset: simd_float4x4,
        staticEntity: Entity,
        shouldRotate: Bool
    ) {
        var transform = indices.reduce(matrix_identity_float4x4) { partialResult, index in
            transforms[index].matrix * partialResult
        }
        
        if shouldRotate {
            let unrotate = simd_quatf(angle: -(Float.pi / 2.0), axis: [0.0, 0.0, 1.0])
            let unrotateMatrix = Transform(matrix: matrix_float4x4(unrotate)).matrix
            transform *= unrotateMatrix
        }
        
        staticEntity.setTransformMatrix(transform * offset, relativeTo: skeleton)
    }
}
