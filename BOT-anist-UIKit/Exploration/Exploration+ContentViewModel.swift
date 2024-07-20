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

extension Exploration {
    @MainActor
    @Observable
    final class ContentViewModel {
        let explorationRoot = Entity()
        let explorationCamera: PerspectiveCamera
        
#if !os(visionOS)
        private(set) var environmentResource: EnvironmentResource?
#endif
        
        init() {
            let explorationCamera = PerspectiveCamera()
            explorationCamera.transform.translation = SIMD3(x: 0.0, y: 0.2, z: 0.4)
            let cameraTilt = -0.5
            let rotationAngle = Angle2D(radians: cameraTilt)
            let rotation = Rotation3D(angle: rotationAngle, axis: .y)
            explorationCamera.setOrientation(simd_quatf(rotation), relativeTo: nil)
            self.explorationCamera = explorationCamera
        }
        
        func load() async throws {
#if !os(visionOS)
            environmentResource = try await makeEnvironmentResource()
#endif
            
            let explorationRoot = explorationRoot
            
            explorationRoot.scale = SIMD3<Float>(repeating: 0.7)
        }
        
        func handleUpdateEvent(_ event: SceneEvents.Update) {
            // TODO
        }
        
        func handleAnimationStopEvent(_ event: AnimationEvents.PlaybackTerminated) {
            // TODO
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
        }
        
        return environmentResource
    }
}
