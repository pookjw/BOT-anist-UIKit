//
//  Exploration+ContentView.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

import SwiftUI
import RealityKit

// TODO: ARView로 해보기

extension Exploration {
    struct ContentView: View {
        private let robotData: RobotData
        @State private var viewModel = ContentViewModel()
        @State private var subscriptions: [EventSubscription] = []
        
        init(robotData: RobotData) {
            self.robotData = robotData
        }
        
        var body: some View {
            RealityView(
                make: { content in
                    let updateEvent = content.subscribe(to: SceneEvents.Update.self) { event in
                        viewModel.handleUpdateEvent(event)
                    }
                    
                    let animationStopEvent = content.subscribe(to: AnimationEvents.PlaybackTerminated.self) { event in
                        viewModel.handleAnimationStopEvent(event)
                    }
                    
                    subscriptions.append(contentsOf: [updateEvent, animationStopEvent])
                    
                    content.add(viewModel.explorationRoot)
                    content.add(viewModel.explorationCamera)
                },
                update: { content in
#if !os(visionOS)
                    if let environmentResource = viewModel.environmentResource {
                        content.environment = .skybox(environmentResource)
                    } else {
                        content.environment = .default
                    }
#endif
                }
            )
            .ignoresSafeArea()
            .focusable()
            .platformTouchControls(viewModel: viewModel)
            .installTouchControls(viewModel: viewModel)
            .task {
                try! await viewModel.load(robotData: robotData)
            }
        }
    }
}

extension View {
    fileprivate func platformTouchControls(viewModel: Exploration.ContentViewModel) -> some View {
        #if !os(visionOS)
        return simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    viewModel.handleGestureChanged(value)
                }
                .onEnded { value in
                    viewModel.handleGestureEnded(value)
                }
        )
        #else
        fatalError()
        #endif
    }
    
    fileprivate func installTouchControls(viewModel: Exploration.ContentViewModel) -> some View {
        return onKeyPress(keys: boundKeys, phases: .down) { press in
            viewModel.handleKeyPress(press)
            return .handled
        }
        .onKeyPress(keys: boundKeys, phases: .up) { press in
            viewModel.handleKeyPress(press)
            return .handled
        }
        .onKeyPress(keys: boundKeys, phases: .repeat) { press in
            viewModel.handleKeyPress(press)
            return .handled
        }
    }
}

fileprivate let keyBindings: [KeyEquivalent: SIMD3<Float>] = [
    // Standard Left-hand WASD
    KeyEquivalent("w"): SIMD3<Float>(x: 0.0, y: 0.0, z: -100.0),
    KeyEquivalent("a"): SIMD3<Float>(x: -100.0, y: 0.0, z: 0.0),
    KeyEquivalent("s"): SIMD3<Float>(x: 0.0, y: 0.0, z: 100.0),
    KeyEquivalent("d"): SIMD3<Float>(x: 100.0, y: 0.0, z: 0.0),
    
    // Right-Hand IJKL
    KeyEquivalent("i"): SIMD3<Float>(x: 0.0, y: 0.0, z: -100.0),
    KeyEquivalent("j"): SIMD3<Float>(x: -100.0, y: 0.0, z: 0.0),
    KeyEquivalent("k"): SIMD3<Float>(x: 0.0, y: 0.0, z: 100.0),
    KeyEquivalent("l"): SIMD3<Float>(x: 100.0, y: 0.0, z: 0.0),
    
    // Arrows
    KeyEquivalent.upArrow: SIMD3<Float>(x: 0.0, y: 0.0, z: -100.0),
    KeyEquivalent.leftArrow: SIMD3<Float>(x: -100.0, y: 0.0, z: 0.0),
    KeyEquivalent.downArrow: SIMD3<Float>(x: 0.0, y: 0.0, z: 100.0),
    KeyEquivalent.rightArrow: SIMD3<Float>(x: 100.0, y: 0.0, z: 0.0),
    
    // Numpad
    KeyEquivalent("8"): SIMD3<Float>(x: 0.0, y: 0.0, z: -100.0),
    KeyEquivalent("4"): SIMD3<Float>(x: -100.0, y: 0.0, z: 0.0),
    KeyEquivalent("2"): SIMD3<Float>(x: 0.0, y: 0.0, z: 100.0),
    KeyEquivalent("6"): SIMD3<Float>(x: 100.0, y: 0.0, z: 0.0),
]

fileprivate let boundKeys: Set<KeyEquivalent> = {
    return Set(keyBindings.keys)
}()
