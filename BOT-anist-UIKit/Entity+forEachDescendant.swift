//
//  Entity+forEachDescendant.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/19/24.
//

import RealityFoundation

extension Entity {
    // 자기 자신은 포함하지 않음 - children만
    func forEachDescendant<T: Component>(
        withComponent componentClass: T.Type = T.self,
        _ closure: (_ child: Entity, _ component: T) throws -> Void
    ) rethrows {
        for child in children {
            if let component = child.components[componentClass] {
                try closure(child, component)
            }
            
            try child.forEachDescendant(withComponent: componentClass, closure)
        }
    }
}
