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
            
            for child in creationRoot.children {
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
                    taskGroup.addTask {
                        let partEntity = try await loader.entity(forPart: part, robotData: robotData)
                        await creationRoot.addChild(partEntity)
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
