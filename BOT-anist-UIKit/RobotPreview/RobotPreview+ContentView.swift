//
//  RobotPreview+ContentView.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

import SwiftUI
import RealityKit

extension RobotPreview {
    struct ContentView: View {
        @State private var viewModel = ContentViewModel()
        private let robotData: RobotData
        
        init(robotData: RobotData) {
            self.robotData = robotData
        }
        
        var body: some View {
            RealityView { content in
                content.add(viewModel.creationRoot)
                content.add(viewModel.robotCamera)
            }
            .simultaneousGesture(dragGesture)
            .task(id: robotData) {
                do {
                    try await viewModel.load(robotData: robotData)
                } catch is CancellationError {
                    
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
        
        private var dragGesture: some Gesture {
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    viewModel.onDragGestureChanged(value)
                }
                .onEnded { value in
                    viewModel.onDragGestureEnded(value)
                }
        }
    }
}
