//
//  JSONDecodable.swift
//  
//
//  Created by jinxiaolong on 2022/12/2.
//

import Foundation

public struct _HiJSONDecoder {
    
    fileprivate init() { }
}

public protocol JSONDecodable: Decodable {
    
    init(_ decoder: _HiJSONDecoder)
    
}

public extension JSONDecodable {
    
    init(from decoder: Decoder) throws {
        self.init(_HiJSONDecoder())
        
        var mirror: Mirror! = Mirror(reflecting: self)
        repeat {
            for (label, value) in mirror.children {
                guard var label = label, let value = value as? DecodablePropertyWrapper else {
                    continue
                }
                if label.hasPrefix("_") {
                    label.remove(at: label.startIndex)
                }
                
                try value.decode(from: decoder, label: label)
            }
            mirror = mirror.superclassMirror
        } while mirror != nil
    }
}
