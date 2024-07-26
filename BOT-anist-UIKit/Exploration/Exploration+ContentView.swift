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
        @FocusState private var isFocused: Bool
        
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
            .platformModifier(viewModel: viewModel)
            .focusable()
            .focused($isFocused)
            .platformTouchControls(viewModel: viewModel)
            .installTouchControls(viewModel: viewModel)
            .task {
                try! await viewModel.load(robotData: robotData)
                isFocused = true
            }
        }
    }
}

extension View {
    fileprivate func platformModifier(viewModel: Exploration.ContentViewModel) -> some View {
        Group {
#if os(visionOS)
            GeometryReader3D { geometry in
                self
                    .scaleEffect(geometry.size.width / 900.0)
                    .volumeBaseplateVisibility(.visible)
                    .onChange(of: geometry.size.width) { _, newValue in
                        viewModel.speedScale = Float(newValue / 900.0)
                    }
            }
#else
            self
#endif
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
        return Group {
            if let characterParent = viewModel.robotCharacter?.characterParent {
                self
                    .simultaneousGesture(
                        DragGesture()
                            .targetedToEntity(characterParent)
                            .onChanged { value in
                                viewModel.handleGestureChanged(value)
                            }
                            .onEnded { value in
                                viewModel.handleGestureEnded(value)
                            }
                    )
            } else {
                self
            }
        }
#endif
    }
    
    fileprivate func installTouchControls(viewModel: Exploration.ContentViewModel) -> some View {
        return onKeyPress(keys: viewModel.boundKeys, phases: .down) { press in
            viewModel.handleKeyPress(press)
            return .handled
        }
        .onKeyPress(keys: viewModel.boundKeys, phases: .up) { press in
            viewModel.handleKeyPress(press)
            return .handled
        }
        .onKeyPress(keys: viewModel.boundKeys, phases: .repeat) { press in
            viewModel.handleKeyPress(press)
            return .handled
        }
    }
}
