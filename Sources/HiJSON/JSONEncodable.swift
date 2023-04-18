//
//  File.swift
//  
//
//  Created by jinxiaolong on 2022/12/10.
//

import Foundation

public protocol JSONEncodable: Encodable {
    
}

public extension JSONEncodable {
    
    func encode(to encoder: Encoder) throws {
        var mirror: Mirror! = Mirror(reflecting: self)
        repeat {
            for (label, value) in mirror.children {
                guard var label = label, let value = value as? EncodablePropertyWrapper else {
                    continue
                }
                if label.hasPrefix("_") {
                    label.remove(at: label.startIndex)
                }
                
                try value.encode(to: encoder, label: label)
            }
            mirror = mirror.superclassMirror
        } while mirror != nil
    }
}
