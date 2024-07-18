//
//  RobotPreview.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/18/24.
//

import UIKit
import SwiftUI

public enum RobotPreview {}

@_expose(Cxx, "makeRobotPreviewHostingController")
public func makeRobotPreviewHostingController(robotData: RobotData) -> UIViewController {
    MainActor.assumeIsolated {
        let rootView = RobotPreview.ContentView(robotData: robotData)
        let hostingController = UIHostingController(rootView: rootView)
        return hostingController
    }
}
