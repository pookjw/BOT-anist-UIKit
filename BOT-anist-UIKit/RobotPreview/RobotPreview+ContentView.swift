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
            Color.pink
                .ignoresSafeArea()
                .task {
                    try! await viewModel.load()
                }
        }
    }
}
