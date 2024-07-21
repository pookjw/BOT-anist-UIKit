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
            .platformTouchControls(viewModel: viewModel)
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
                    let translation = value.translation
                    let movementVector = SIMD3<Float>(x: Float(translation.width), y: 0.0, z: Float(translation.height))
                    
                    viewModel.movementVector = movementVector
                    
                    // TODO: Animation
                }
                .onEnded { value in
                    // TODO: Animation
                    viewModel.movementVector = .zero
                }
        )
        #else
        fatalError()
        #endif
    }
}
