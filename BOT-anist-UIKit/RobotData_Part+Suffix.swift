//
//  RobotData_Part+Suffix.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

extension RobotData.Part {
    var suffix: String {
        switch self {
        case .Head:
            return "H"
        case .Body:
            return "B"
        case .Backpack:
            return "BP"
        @unknown default:
            fatalError()
        }
    }
}
