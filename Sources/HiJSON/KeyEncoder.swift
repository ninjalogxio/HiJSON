//
//  KeyEncoder.swift
//  
//
//  Created by jinxiaolong on 2022/12/10.
//

import Foundation

internal struct KeyEncoder<T> {
    
    internal let encode: (Encoder, T, KeyPath) throws -> Void
    
    internal func encode(to encoder: Encoder, value: T, keyPath: KeyPath) throws {
        try encode(encoder, value, keyPath)
    }
}
