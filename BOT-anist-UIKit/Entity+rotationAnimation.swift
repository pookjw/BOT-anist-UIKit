//
//  Entity+rotationAnimation.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/27/24.
//

#if os(visionOS)

import SwiftUI
import RealityFoundation

extension Entity {
    func rotattionAnimation(toFace face: SquareAzimuth, duration: TimeInterval) throws -> AnimationResource {
        let quat = simd_quatf(face.orientation)
        let fromTransform = transform
        let toTransform = Transform(
            scale: fromTransform.scale,
            rotation: quat,
            translation: fromTransform.translation
        )
        
        let rotateAnim = FromToByAnimation(
            name: "rotation",
            from: fromTransform,
            to: toTransform,
            duration: duration,
            bindTarget: .transform
        )
        
        return try AnimationResource.generate(with: rotateAnim)
    }
}

#endif
