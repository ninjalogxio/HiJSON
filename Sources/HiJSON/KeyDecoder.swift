//
//  KeyDecoder.swift
//  
//
//  Created by jinxiaolong on 2022/12/2.
//

import Foundation

internal struct KeyDecoder<T> {
    
    internal let decode: (Decoder, KeyPath) throws -> T
    
    internal func decode(from decoder: Decoder, keyPath: KeyPath) throws -> T {
        return try decode(decoder, keyPath)
    }
}
