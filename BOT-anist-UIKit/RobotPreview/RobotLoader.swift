//
//  RobotLoader.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/19/24.
//

import RealityKit
import BOTanistAssets

@globalActor
actor RobotLoader {
    static let shared = RobotLoader()
    
    private(set) var robotParts: [RobotPartResult] = []
    private(set) var robotMaterials: [RobotMaterialResult] = []
    
    private(set) var isLoaded = false
    let isLoadedStream: AsyncStream<Bool>
    private let isLoadedContinuation: AsyncStream<Bool>.Continuation
    
    private init() {
        let (isLoadedStream, isLoadedContinuation) = AsyncStream<Bool>.makeStream()
        self.isLoadedStream = isLoadedStream
        self.isLoadedContinuation = isLoadedContinuation
    }
    
    func load() async throws {
        
    }
}

extension RobotLoader {
    struct RobotPartResult: Sendable {
        let part: RobotData.Part
        let entity: Entity
        let index: Int
    }
    
    struct RobotMaterialResult: @unchecked Sendable {
        let robotMaterial: RobotData.Material
        let materialsByPart: [RobotData.Part: [ShaderGraphMaterial]]
    }
}
