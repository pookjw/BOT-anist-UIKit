//
//  RobotData_Face+Index.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

extension RobotData.Face {
    var index: Int {
        switch self {
        case .Square:
            return 0
        case .Circle:
            return 1
        case .Heart:
            return 2
        @unknown default:
            fatalError()
        }
    }
}
