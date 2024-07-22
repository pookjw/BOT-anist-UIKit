//
//  JointPinComponent.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/23/24.
//

import RealityFoundation

struct JointPinComponent: Component {
    let headEntity: Entity
    let headJointIndices: [Int]
    let backpackEntity: Entity
    let backpackJointIndices: [Int]
    let bodyEntity: Entity
    let headOffset: simd_float4x4
    let backpackOffset: simd_float4x4
}
