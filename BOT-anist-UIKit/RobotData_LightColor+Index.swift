//
//  RobotData_LightColor+Index.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

extension RobotData.LightColor {
    var index: Int {
        switch self {
        case .Red:
            return 0
        case .Yellow:
            return 1
        case .Green:
            return 2
        case .Blue:
            return 3
        case .Purple:
            return 4
        case .White:
            return 5
        case .PurpleBlue:
            return 6
        case .Rainbow:
            return 7
        @unknown default:
            fatalError()
        }
    }
}
