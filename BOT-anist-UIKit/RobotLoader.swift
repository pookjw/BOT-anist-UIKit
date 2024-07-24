//
//  RobotLoader.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/19/24.
//

@preconcurrency import RealityFoundation
import BOTanistAssets

@globalActor
actor RobotLoader {
    static let shared = RobotLoader()
    
    private var robotParts: [RobotPartResult] = []
    private var robotMaterials: [RobotMaterialResult] = []
    
    private var isLoaded = false
    private let isLoadedStream: AsyncStream<Bool>
    private let isLoadedContinuation: AsyncStream<Bool>.Continuation
    private var isLoading = false
    
    private init() {
        let (isLoadedStream, isLoadedContinuation) = AsyncStream<Bool>.makeStream()
        self.isLoadedStream = isLoadedStream
        self.isLoadedContinuation = isLoadedContinuation
    }
    
    func load() async throws {
        guard !isLoaded else { return }
        
        if isLoading {
            for await value in isLoadedStream {
                if value {
                    return
                }
                
                if isLoading {
                    continue
                }
                
                break
            }
        }
        
        isLoading = true
        
        do {
            let robotParts = try await robotParts()
            let robotMaterials = try await robotMaterials()
            
            self.robotParts = robotParts
            self.robotMaterials = robotMaterials
            
            isLoaded = true
            isLoading = false
            isLoadedContinuation.yield(false)
        } catch {
            isLoading = false
            throw error
        }
    }
    
    @MainActor
    func entity(forPart part: RobotData.Part, robotData: RobotData) async throws -> Entity {
        
        let entity = await self.entity(forPart: part, index: robotData.getSelectedIndexByPart(part))
        entity.components.set(InputTargetComponent())
        
        //
        
        let selectedIndex = robotData.getSelectedIndexByPart(part)
        let material = robotData.getMaterialByPart(part)
        
        let shaderGraphMaterial = await self.shaderGraphMaterial(forMaterial: material, part: part, index: selectedIndex)
        
        //
        
        try entity.forEachDescendant(withComponent: ModelComponent.self) { child, component in
            var modelComponent = component
            
            try modelComponent.materials = modelComponent
                .materials
                .map {
                    guard let oldMaterial = $0 as? ShaderGraphMaterial else {
                        return $0
                    }
                    
                    var newMaterial: ShaderGraphMaterial
                    if oldMaterial.name!.contains("_\(part.suffix)") {
                        newMaterial = shaderGraphMaterial
                    } else {
                        newMaterial = oldMaterial
                    }
                    
                    if newMaterial.parameterNames.contains("mat_switch") {
                        let materialColor = robotData.getMaterialColorByPart(part)
                        let colorIndex = materialColor.index(byMaterial: material)
                        
                        try newMaterial.setParameter(name: "mat_switch", value: MaterialParameters.Value.int(Int32(colorIndex)))
                    }
                    
                    if newMaterial.parameterNames.contains("light_switch") {
                        let lightColor = robotData.getLightColorByPart(part)
                        let colorIndex = lightColor.index
                        
                        try newMaterial.setParameter(name: "light_switch", value: MaterialParameters.Value.int(Int32(colorIndex)))
                    }
                    
                    if part == .Head {
                        if newMaterial.parameterNames.contains("face_switch") {
                            let face = robotData.getFace()
                            let faceIndex = face.index
                            
                            try newMaterial.setParameter(name: "face_switch", value: MaterialParameters.Value.int(Int32(faceIndex)))
                        }
                    }
                    
                    return newMaterial
                }
            
            child.components.set(modelComponent)
            
            return true
        }
        
        //
        
        if part == .Backpack {
            let bodyIndex = robotData.getSelectedIndexByPart(.Body)
            
            RobotData.getIndicesByPart(part).forEach { index in
                let isEnabled = bodyIndex == index
                entity.findEntity(named: "strap_B\(index)")!.isEnabled = isEnabled
            }
        }
        
        return entity
    }
    
    private func entity(forPart part: RobotData.Part, index: Int) async -> Entity {
        await robotParts
            .first { $0.part == part && $0.index == index }!
            .entity
            .clone(recursive: true)
    }
    
    private func shaderGraphMaterial(forMaterial material: RobotData.Material, part: RobotData.Part, index: Int) -> ShaderGraphMaterial {
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
            RobotData.getAllParts().forEach { robotPart in
                RobotData.getIndicesByPart(robotPart).forEach { index in
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
                        let entity = await scene.findEntity(named: entityName)!
                        
                        if robotPart == .Body {
                            var libComponent = AnimationLibraryComponent()
                            let animationDirectory = "Assets/Robot/animations/\(entityName)/"
                            
                            for animationState in RobotLoader.AnimationState.allCases {
                                let name = "\(animationDirectory)\(entityName)\(animationState.fileSuffix)"
                                let rootEntity = try await Entity(named: name, in: BOTanistAssetsBundle)
                                
                                let animationEntity = await rootEntity.findEntity(named: "rig_grp")!
                                let animation = await animationEntity.availableAnimations.first!
                                libComponent[animationState.rawValue] = animation
                            }
                            
                            await entity.components.set(libComponent)
                            await entity.components.set(AnimationStateComponent(animationState: .idle))
                        }
                        
                        return RobotPartResult(part: robotPart, entity: entity, index: index)
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
            RobotData.getAllMaterials().forEach { material in
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
                    
                    RobotData.getAllParts().forEach { part in
                        let suffix: String = part.suffix
                        
                        RobotData.getIndicesByPart(part).forEach { index in
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
