//
//  JSONKey+Defaultable.swift
//  
//
//  Created by Kinglets on 2023/4/20.
//

import Foundation

public protocol Defaultable {
    
    static var defaultValue: Self { get }
}

extension Optional : Defaultable where Wrapped : Decodable {
    
    public static var defaultValue: Self { return nil }
}

public extension JSONKey where T : Defaultable & Decodable {
    
    convenience init(_ keyPath: KeyPath? = nil) {
        let keyDecoder = KeyDecoder<T> { (try? $0.decode(at: $1)) ?? T.defaultValue }
        self.init(keyPath, keyEncoder: nil, keyDecoder: keyDecoder)
    }
    
}

public extension JSONKey where T : Defaultable & Codable {
    
    convenience init(_ keyPath: KeyPath? = nil) {
        let keyEncoder = KeyEncoder<T> { try $0.encode($1, at: $2) }
        let keyDecoder = KeyDecoder<T>(decode: { (try? $0.decode(at: $1)) ?? T.defaultValue })
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: keyDecoder)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        encode: @escaping (_ encoder: Encoder, _ value: T, _ keyPath: KeyPath) throws -> Void
    ) {
        let keyEncoder = KeyEncoder<T>(encode: encode)
        let keyDecoder = KeyDecoder<T>(decode: { (try? $0.decode(at: $1)) ?? T.defaultValue })
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: keyDecoder)
    }
}
