//
//  JSONKey+Date.swift
//  
//
//  Created by jinxiaolong on 2022/12/3.
//

import Foundation

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
private var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

/// The strategy to use for encoding `Date` values.
public enum DateEncodingStrategy {
    
    /// Defer to `Date` for choosing an encoding. This is the default strategy.
    case deferredToDate
    
    /// Encode the `Date` as a UNIX timestamp (as a JSON number).
    case secondsSince1970
    
    /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
    case millisecondsSince1970
    
    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    case iso8601
    
    /// Encode the `Date` as a string formatted by the given formatter.
    case formatted(DateFormatter)
    
    /// Encode the `Date` as a custom value encoded by the given closure.
    ///
    /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
    case custom((Date, JSONKeyEncoder) throws -> Void)
}

/// The strategy to use for decoding `Date` values.
public enum DateDecodingStrategy {
    
    /// Defer to `Date` for decoding. This is the default strategy.
    case deferredToDate
    
    /// Decode the `Date` as a UNIX timestamp from a JSON number.
    case secondsSince1970
    
    /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
    case millisecondsSince1970
    
    /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    case iso8601
    
    /// Decode the `Date` as a string parsed by the given formatter.
    case formatted(DateFormatter)
    
    /// Decode the `Date` as a custom value decoded by the given closure.
    case custom((JSONKeyDecoder) throws -> Date)
}

public protocol DateCodable {
    
    func encode(to encoder: JSONKeyEncoder, encodingStrategy: DateEncodingStrategy) throws
    
    init(from decoder: JSONKeyDecoder, decodingStrategy: DateDecodingStrategy) throws
}

extension Optional: DateCodable where Wrapped: DateCodable {
    
    public func encode(to encoder: JSONKeyEncoder, encodingStrategy: DateEncodingStrategy) throws {
        try self?.encode(to: encoder, encodingStrategy: encodingStrategy)
    }
    
    public init(from decoder: JSONKeyDecoder, decodingStrategy: DateDecodingStrategy) throws {
        self = try? Wrapped(from: decoder, decodingStrategy: decodingStrategy)
    }
}

extension Array: DateCodable where Element: DateCodable {
    
    public func encode(to encoder: JSONKeyEncoder, encodingStrategy: DateEncodingStrategy) throws {
        
    }
    
    public init(from decoder: JSONKeyDecoder, decodingStrategy: DateDecodingStrategy) throws {
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

extension Date: DateCodable {
        
    public func encode(to encoder: JSONKeyEncoder, encodingStrategy: DateEncodingStrategy) throws {
        switch encodingStrategy {
        case .deferredToDate:
            try encoder.encode(self)
        case .secondsSince1970:
            try encoder.encode(timeIntervalSince1970)
        case .millisecondsSince1970:
            try encoder.encode(timeIntervalSince1970 * 1000)
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string = _iso8601Formatter.string(from: self)
                try encoder.encode(string)
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
        case .formatted(let dateFormatter):
            let string = dateFormatter.string(from: self)
            try encoder.encode(string)
        case .custom(let adapter):
            try adapter(self, encoder)
        }
    }
    
    public init(from decoder: JSONKeyDecoder, decodingStrategy: DateDecodingStrategy) throws {
        switch decodingStrategy {
        case .deferredToDate:
            self = try decoder.decode(Date.self)
        case .secondsSince1970:
            let timeInterval = try decoder.decode(TimeInterval.self)
            self = Date(timeIntervalSince1970: timeInterval)
        case .millisecondsSince1970:
            let timeInterval = try decoder.decode(TimeInterval.self)
            self = Date(timeIntervalSince1970: timeInterval / 1000)
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string = try decoder.decode(String.self)
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Expected date string to be ISO8601-formatted."
                        )
                    )
                }
                self = date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
        case .formatted(let dateFormatter):
            let string = try decoder.decode(String.self)
            guard let date = dateFormatter.date(from: string) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected date string to be formatted as \(dateFormatter.dateFormat!)."
                    )
                )
            }
            self = date
        case .custom(let adapter):
            self = try adapter(decoder)
        }
    }
}

public extension JSONKey where T: DateCodable {
    
    convenience init(
        _ keyPath: KeyPath? = nil,
        encodingStrategy: DateEncodingStrategy = .deferredToDate,
        decodingStrategy: DateDecodingStrategy = .deferredToDate
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
