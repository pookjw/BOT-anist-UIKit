//
//  RobotData_MaterialColor+Index.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/20/24.
//

extension RobotData.MaterialColor {
    func index(byMaterial material: RobotData.Material) -> Int {
        switch material {
        case .Metal:
            switch self {
            case .MetalPink:
                return 0
            case .MetalOrange:
                return 1
            case .MetalGreen:
                return 2
            case .MetalBlue:
                return 3
            default:
                fatalError()
            }
        case .Rainbow:
            switch self {
            case .Beige:
                return 0
            case .RainbowRed:
                return 1
            case .Rose:
                return 2
            case .Black:
                return 3
            default:
                fatalError()
            }
        case .Plastic:
            switch self {
            case .PlasticBlue:
                return 0
            case .PlasticPink:
                return 1
            case .PlasticOrange:
                return 2
            case .PlasticGreen:
                return 3
            default:
                fatalError()
            }
        case .Mesh:
            switch self {
            case .MeshGray:
                return 0
            case .MeshOrange:
                return 1
            case .MeshYellow:
                return 2
            case .Black:
                return 3
            default:
                fatalError()
            }
        @unknown default:
            fatalError()
        }
    }
}
