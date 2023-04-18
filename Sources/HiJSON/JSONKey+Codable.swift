//
//  JSONKey+Codable.swift
//  
//
//  Created by jinxiaolong on 2022/12/3.
//

import Foundation

public extension JSONKey where T: Decodable {
    
    convenience init(_ keyPath: KeyPath? = nil) {
        let keyDecoder = KeyDecoder<T> { try $0.decode(at: $1) }
        self.init(keyPath, keyEncoder: nil, keyDecoder: keyDecoder)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        defaultValue: @autoclosure @escaping () -> T
    ) {
        let keyDecoder = KeyDecoder<T> { (try? $0.decode(at: $1)) ?? defaultValue() }
        self.init(keyPath, keyEncoder: nil, keyDecoder: keyDecoder)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        decode: @escaping (_ decoder: Decoder, _ keyPath: KeyPath) throws -> T
    ) {
        let keyDecoder = KeyDecoder<T>(decode: decode)
        self.init(keyPath, keyEncoder: nil, keyDecoder: keyDecoder)
    }
}

public extension JSONKey where T: Encodable {
    
    convenience init(_ keyPath: KeyPath? = nil) {
        let keyEncoder = KeyEncoder<T> { try $0.encode($1, at: $2) }
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: nil)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        encode: @escaping (_ encoder: Encoder, _ value: T, _ keyPath: KeyPath) throws -> Void
    ) {
        let keyEncoder = KeyEncoder<T>(encode: encode)
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: nil)
    }
}

public extension JSONKey where T: Codable {
    
    convenience init(
        _ keyPath: KeyPath? = nil
    ) {
        let keyEncoder = KeyEncoder<T> { try $0.encode($1, at: $2) }
        let keyDecoder = KeyDecoder<T> { try $0.decode(at: $1) }
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: keyDecoder)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        encode: @escaping (_ encoder: Encoder, _ value: T, _ keyPath: KeyPath) throws -> Void
    ) {
        let keyEncoder = KeyEncoder<T>(encode: encode)
        let keyDecoder = KeyDecoder<T> { try $0.decode(at: $1) }
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: keyDecoder)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        decode: @escaping (_ decoder: Decoder, _ keyPath: KeyPath) throws -> T
    ) {
        let keyEncoder = KeyEncoder<T> { try $0.encode($1, at: $2) }
        let keyDecoder = KeyDecoder<T>(decode: decode)
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: keyDecoder)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        encode: @escaping (_ encoder: Encoder, _ value: T, _ keyPath: KeyPath) throws -> Void,
        decode: @escaping (_ decoder: Decoder, _ keyPath: KeyPath) throws -> T
    ) {
        let keyEncoder = KeyEncoder<T>(encode: encode)
        let keyDecoder = KeyDecoder<T>(decode: decode)
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: keyDecoder)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        defaultValue: @autoclosure @escaping () -> T
    ) {
        let keyEncoder = KeyEncoder<T> { try $0.encode($1, at: $2) }
        let keyDecoder = KeyDecoder<T>(decode: { (try? $0.decode(at: $1)) ?? defaultValue() })
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: keyDecoder)
    }
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        encode: @escaping (_ encoder: Encoder, _ value: T, _ keyPath: KeyPath) throws -> Void,
        defaultValue: @autoclosure @escaping () -> T
    ) {
        let keyEncoder = KeyEncoder<T>(encode: encode)
        let keyDecoder = KeyDecoder<T>(decode: { (try? $0.decode(at: $1)) ?? defaultValue() })
        self.init(keyPath, keyEncoder: keyEncoder, keyDecoder: keyDecoder)
    }
}
