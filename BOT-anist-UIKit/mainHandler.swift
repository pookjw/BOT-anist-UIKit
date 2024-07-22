//
//  mainHandler.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/22/24.
//

import BOTanistAssets

@_expose(Cxx, "mainHandler")
public func mainHandler() {
    MainActor.assumeIsolated {
        // TODO: JointPinComponent, JointPinSystem
        PlantComponent.registerComponent()
    }
}
