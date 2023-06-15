//
//  JSONKey.swift
//  
//
//  Created by jinxiaolong on 2022/12/2.
//

import Foundation

private enum Value<Wrapped> {
    case undefined
    case some(Wrapped)
}

@propertyWrapper
public final class JSONKey<T>: CustomStringConvertible, CustomReflectable {
    
    internal let keyPath: KeyPath?
    
    internal let keyEncoder: KeyEncoder<T>?
    
    internal let keyDecoder: KeyDecoder<T>?
    
    internal init(
        _ keyPath: KeyPath?,
        keyEncoder: KeyEncoder<T>?,
        keyDecoder: KeyDecoder<T>?
    ) {
        self.keyPath = keyPath
        self.keyEncoder = keyEncoder
        self.keyDecoder = keyDecoder
    }
    
    public var wrappedValue: T {
        get {
            guard case .some(let wrapped) = _value else {
                fatalError()
            }
            return wrapped
        }
        set { _value = .some(newValue) }
    }
    
    private var _value: Value<T> = .undefined
    
    public var description: String {
        String(describing: _value)
    }
    
    public var customMirror: Mirror {
        Mirror(reflecting: _value)
    }
}

extension JSONKey: DecodablePropertyWrapper {
    
    func decode(from decoder: Decoder, label: String) throws {
        guard let keyDecoder = keyDecoder else {
            throw JSONDecodingError.undecodable
        }
        let value = try keyDecoder.decode(
            from: decoder,
            keyPath: keyPath ?? .key(label)
        )
        _value = .some(value)
    }
}

extension JSONKey: EncodablePropertyWrapper {
    
    func encode(to encoder: Encoder, label: String) throws {
        guard let keyEncoder = keyEncoder else {
            throw JSONEncodingError.unencodable
        }
        try keyEncoder.encode(
            to: encoder,
            value: self.wrappedValue,
            keyPath: keyPath ?? .key(label)
        )
    }
}
