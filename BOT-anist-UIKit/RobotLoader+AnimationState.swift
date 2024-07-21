//
//  RobotLoader+AnimationState.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/21/24.
//

import RealityFoundation

extension RobotLoader {
    enum AnimationState: String, CaseIterable {
        case idle
        case walkLoop
        case walkEnd
//        case plant
        case celebrate
        case wave
        
        var fileSuffix: String {
            "_\(rawValue)_anim"
        }
        
        var loopingBehavior: LoopingBehavior {
            switch self {
            case .idle, .walkLoop, .celebrate:
                return .infinite
            case .walkEnd, .wave:
                return .finite(times: 1)
            }
        }
        
        var nextState: RobotLoader.AnimationState {
            switch self {
            case .idle:
                return .idle
            case .walkLoop:
                return .idle
            case .walkEnd:
                return .idle
            case .celebrate:
                return .idle
            case .wave:
                return .idle
            }
        }
    }
}

extension RobotLoader.AnimationState {
    enum LoopingBehavior {
        case infinite
        case finite(times: Int)
    }
}

extension RobotLoader {
    struct AnimationStateComponent: Component {
        let animationState: RobotLoader.AnimationState
    }
}
