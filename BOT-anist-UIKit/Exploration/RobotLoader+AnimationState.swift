//
//  RobotLoader+AnimationState.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/21/24.
//

extension RobotLoader {
    enum AnimationState: CaseIterable {
        case idle
        case walkLoop
        case walkEnd
        case plant
        case celebrate
        case wave
    }
}
