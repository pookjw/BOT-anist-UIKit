//
//  Exploration.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

import UIKit
import SwiftUI

enum Exploration {}

@_expose(Cxx, "makeExplorationHostingController")
public func makeExplorationHostingController(robotData: RobotData) -> UIViewController {
    MainActor.assumeIsolated {
        let rootView = Exploration.ContentView(robotData: robotData)
        let hostingController = UIHostingController(rootView: rootView)
        return hostingController
    }
}
