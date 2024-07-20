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
    
    private var robotParts: [RobotPartResult] = []
    private var robotMaterials: [RobotMaterialResult] = []
    
    private(set) var isLoaded = false
    let isLoadedStream: AsyncStream<Bool>
    private let isLoadedContinuation: AsyncStream<Bool>.Continuation
    private var isLoading = false
    
    private init() {
        let (isLoadedStream, isLoadedContinuation) = AsyncStream<Bool>.makeStream()
        self.isLoadedStream = isLoadedStream
        self.isLoadedContinuation = isLoadedContinuation
    }
    
    func load() async throws {
        guard !isLoaded else { return }
        
        guard !isLoading else {
            for await _ in isLoadedStream {
                break
            }
            
            return
        }
        
        isLoading = true
        
        let robotParts = try await robotParts()
        let robotMaterials = try await robotMaterials()
        
        self.robotParts = robotParts
        self.robotMaterials = robotMaterials
        
        isLoaded = true
        isLoadedContinuation.yield(true)
        isLoading = false
    }
    
    func entity(forPart part: RobotData.Part, index: Int) async -> Entity {
        await robotParts
            .first { $0.part == part && $0.index == index }!
            .entity
            .clone(recursive: true)
    }
    
    func shaderGraphMaterial(forMaterial material: RobotData.Material, part: RobotData.Part, index: Int) -> ShaderGraphMaterial {
        robotMaterials
            .first { $0.robotMaterial == material }!
            .materialsByPart[part]![index - 1]
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

extension RobotLoader {
    private func robotParts() async throws -> [RobotPartResult] {
        try await withThrowingTaskGroup(of: RobotPartResult.self, returning: [RobotPartResult].self) { taskGroup in
            RobotData.allParts().forEach { robotPart in
                for index in 1...3 {
                    taskGroup.addTask {
                        let entityName: String
                        let sceneName: String
                        
                        switch robotPart {
                        case .Head:
                            entityName = "head\(index)"
                            sceneName = "scenes/head\(index)"
                        case .Body:
                            entityName = "body\(index)"
                            sceneName = "scenes/body\(index)"
                        case .Backpack:
                            entityName = "backpack\(index)"
                            sceneName = "scenes/backpack\(index)"
                        @unknown default:
                            fatalError()
                        }
                        
                        let scene = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
                        let entity = await scene.findEntity(named: entityName)
                        
                        if robotPart == .Body {
                            var libComponent = AnimationLibraryComponent()
                            let animationDirectory = "Assets/Robot/animations/\(entityName)"
                            
                            // TODO: Animation
//                            for animationType in AnimationState<<#Value: AnimatableData#>>.allCases {
//                                
//                            }
                        }
                        
                        return RobotPartResult(part: robotPart, entity: entity!, index: index)
                    }
                }
            }
            
            //
            
            var results: [RobotPartResult] = []
            
            for try await value in taskGroup {
                results.append(value)
            }
            
            return results
        }
    }
    
    private func robotMaterials() async throws -> [RobotMaterialResult] {
        try await withThrowingTaskGroup(of: RobotMaterialResult.self, returning: [RobotMaterialResult].self) { taskGroup in
            RobotData.allMaterials().forEach { material in
                taskGroup.addTask { @MainActor in
                    let sceneName: String
                    
                    switch material {
                    case .Metal:
                        sceneName = "Materials/M_metal"
                    case .Rainbow:
                        sceneName = "Materials/M_rainbow"
                    case .Plastic:
                        sceneName = "Materials/M_plastic"
                    case .Mesh:
                        sceneName = "Materials/M_mesh"
                    @unknown default:
                        fatalError()
                    }
                    
                    let scene = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
                    var materialsByPart: [RobotData.Part: [ShaderGraphMaterial]] = [:]
                    
                    RobotData.allParts().forEach { part in
                        let suffix: String = part.suffix
                        
                        for index in 1...3 {
                            let entityName = "\(suffix)\(index)"
                            let entity = scene.findEntity(named: entityName)!
                            let modelComponent = entity.components[ModelComponent.self]!
                            let material = modelComponent.materials.first as! ShaderGraphMaterial
                            
                            var materials: [ShaderGraphMaterial] = materialsByPart[part] ?? []
                            materials.append(material)
                            materialsByPart[part] = materials
                        }
                    }
                    
                    return RobotMaterialResult(robotMaterial: material, materialsByPart: materialsByPart)
                }
            }
            
            //
            
            var results: [RobotMaterialResult] = []
            
            for try await value in taskGroup {
                results.append(value)
            }
            
            return results
        }
    }
}
