//
//  Entity+forEachDescendant.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/19/24.
//

import RealityFoundation

extension Entity {
    // 자기 자신은 포함하지 않음 - children만
    @discardableResult
    func forEachDescendant<T: Component>(
        withComponent componentClass: T.Type = T.self,
        _ closure: (_ child: Entity, _ component: T) throws -> Bool
    ) rethrows -> Bool {
        for child in children {
            if let component = child.components[componentClass] {
                let willContinue = try closure(child, component)
                
                if !willContinue {
                    return false
                }
            }
            
            let willContinue = try child.forEachDescendant(withComponent: componentClass, closure)
            if !willContinue {
                return false
            }
        }
        
        return true
    }
}
