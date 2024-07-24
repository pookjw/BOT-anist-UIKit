//
//  PlantAnimationProvider.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/24/24.
//

import RealityFoundation
import BOTanistAssets

@globalActor
actor PlantAnimationProvider {
    static let shared = PlantAnimationProvider()
    
    private var isLoaded = false
    private let isLoadedStream: AsyncStream<Bool>
    private let isLoadedContinuation: AsyncStream<Bool>.Continuation
    private var isLoading = false
    private var results: [PlantAnimationResult] = []
    
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
        
        isLoaded = true
        
        do {
            let results = try await withThrowingTaskGroup(of: PlantAnimationResult.self, returning: [PlantAnimationResult].self) { taskGroup in
                for plantType in PlantComponent.PlantTypeKey.allCases {
                    taskGroup.addTask {
                        let growAnimation = try await self.growAnimationResource(for: plantType)
                        let celebrateAnimation = try await self.celebrateAnimationResource(for: plantType)
                        return PlantAnimationResult(growAnimation: growAnimation, celebrateAnimation: celebrateAnimation, plantType: plantType)
                    }
                }
                
                var results: [PlantAnimationResult] = []
                for try await result in taskGroup {
                    results.append(result)
                }
                
                return results
            }
            
            self.results = results
            isLoaded = true
            isLoading = false
            isLoadedContinuation.yield(true)
        } catch {
            isLoading = false
            throw error
        }
    }
    
    func growAnimation(for plantType: PlantComponent.PlantTypeKey) -> AnimationResource {
        assert(isLoaded)
        
        return results
            .first { $0.plantType == plantType }!
            .growAnimation
    }
    
    func celebrateAnimation(for plantType: PlantComponent.PlantTypeKey) -> AnimationResource {
        assert(isLoaded)
        
        return results
            .first { $0.plantType == plantType }!
            .celebrateAnimation
    }
}

extension PlantAnimationProvider {
    private func growAnimationResource(for plantType: PlantComponent.PlantTypeKey) async throws -> AnimationResource {
        let sceneName = "Assets/plants/animations/\(plantType.rawValue)_grow_anim"
        let rootEntity = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
        
        let result = await MainActor.run {
            var result: AnimationResource?
            
            rootEntity.forEachDescendant(withComponent: BlendShapeWeightsComponent.self) { child, component in
                result = child.availableAnimations.first
                return false
            }
            
            return result
        }
        
        return result!
    }
    
    private func celebrateAnimationResource(for plantType: PlantComponent.PlantTypeKey) async throws -> AnimationResource {
        let sceneName = "Assets/plants/animations/\(plantType.rawValue)_celebrate_anim"
        let rootEntity = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
        
        let result = await MainActor.run {
            var result: AnimationResource?
            
            rootEntity.forEachDescendant(withComponent: BlendShapeWeightsComponent.self) { child, component in
                result = child.availableAnimations.first
                return false
            }
            
            return result
        }
        
        return result!
    }
}

extension PlantAnimationProvider {
    fileprivate struct PlantAnimationResult {
        let growAnimation: AnimationResource
        let celebrateAnimation: AnimationResource
        let plantType: PlantComponent.PlantTypeKey
    }
}
