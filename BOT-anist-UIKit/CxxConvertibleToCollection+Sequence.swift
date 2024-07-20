//
//  CxxConvertibleToCollection+Sequence.swift
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/19/24.
//

//import Cxx
//
//extension CxxConvertibleToCollection {
//    func allObjects(size: Int? = nil) -> [Element] {
//        if let size {
//            let result: [Element] = .init(unsafeUninitializedCapacity: size) { buffer, initializedCount in
//                forEach { element in
//                    (buffer.baseAddress! + initializedCount).initialize(to: element)
//                    
//                    initializedCount += 1
//                }
//            }
//            
//            return result
//        } else {
//            var result: [Element] = []
//            
//            forEach { element in
//                result.append(element)
//            }
//            
//            return result
//        }
//    }
//}
