//
//  JSONKey+Data.swift
//  
//
//  Created by jinxiaolong on 2022/12/9.
//

import Foundation

/// The strategy to use for encoding `Data` values.
public enum DataEncodingStrategy : Sendable {

    /// Defer to `Data` for choosing an encoding.
    case deferredToData

    /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
    case base64

    /// Encode the `Data` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
    @preconcurrency case custom(@Sendable (Data, JSONKeyEncoder) throws -> Void)
}

/// The strategy to use for decoding `Data` values.
public enum DataDecodingStrategy {
    
    /// Defer to `Data` for decoding.
    case deferredToData
    
    /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
    case base64
    
    /// Decode the `Data` as a custom value decoded by the given closure.
    case custom((_ decoder: JSONKeyDecoder) throws -> Data)
}

public protocol DataCodable {

    func encode(to encoder: JSONKeyEncoder, encodingStrategy: DataEncodingStrategy) throws
    
    init(from decoder: JSONKeyDecoder, decodingStrategy: DataDecodingStrategy) throws
}

extension Optional: DataCodable where Wrapped: DataCodable {
    
    public func encode(to encoder: JSONKeyEncoder, encodingStrategy: DataEncodingStrategy) throws {
        try self?.encode(to: encoder, encodingStrategy: encodingStrategy)
    }
    
    public init(from decoder: JSONKeyDecoder, decodingStrategy: DataDecodingStrategy) throws {
        self = try? Wrapped(from: decoder, decodingStrategy: decodingStrategy)
    }
}

extension Array: DataCodable where Element: DataCodable {
    
    public func encode(to encoder: JSONKeyEncoder, encodingStrategy: DataEncodingStrategy) throws {
        
    }
    
    public init(from decoder: JSONKeyDecoder, decodingStrategy: DataDecodingStrategy) throws {
        guard case .unkeyed(let container) = try decoder.container.nestedUnkeyedContainer(forKey: decoder.codingPath.last!) else {
            throw DecodingError.typeMismatch(Array<Element>.self,
                                             DecodingError.Context(
                                                codingPath: decoder.codingPath,
                                                debugDescription: "" // TODO:
                                                //                    debugDescription: "Expected to decode \(Array<Element>.self) but found \() instead."
                                             )
            )
        }
        
        var elements: Array<Element> = []
        for index in (container.currentIndex ..< (container.count ?? 0)) {
            try decoder.decoder.decode(at: KeyPath(codingPath: decoder.codingPath) + .index(index)) {
                elements.append(try Element.init(from: $0, decodingStrategy: decodingStrategy))
            }
        }
        self = elements
    }
}

extension Data: DataCodable {
    
    public func encode(to encoder: JSONKeyEncoder, encodingStrategy: DataEncodingStrategy) throws {
        switch encodingStrategy {
        case .deferredToData:
            try encoder.encode(self)
        case .base64:
            try encoder.encode(base64EncodedData())
        case .custom(let adapter):
            try adapter(self, encoder)
        }
    }
    
    public init(from decoder: JSONKeyDecoder, decodingStrategy: DataDecodingStrategy) throws {
        switch decodingStrategy {
        case .deferredToData:
            self = try decoder.decode(Data.self)
        case .base64:
            let string = try decoder.decode(String.self)
            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected data string to be base64 encoded."
                    )
                )
            }
            self = data
        case .custom(let adapter):
            self = try adapter(decoder)
        }
    }
}

public extension JSONKey where T: DataCodable {
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        encodingStrategy: DataEncodingStrategy = .base64,
        decodingStrategy: DataDecodingStrategy = .base64
    ) {
        let encoder = KeyEncoder<T> {
            try $0.encode($1, at: $2) {
                try $0.encode(to: $1, encodingStrategy: encodingStrategy)
            }
        }
        let decoder = KeyDecoder<T> {
            try $0.decode(at: $1) {
                try T.init(from: $0, decodingStrategy: decodingStrategy)
            }
        }
        self.init(keyPath, keyEncoder: encoder, keyDecoder: decoder)
    }
}
