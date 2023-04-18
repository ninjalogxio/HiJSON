//
//  JSONKeyDecoder.swift
//  
//
//  Created by jinxiaolong on 2022/12/6.
//

import Foundation

internal extension Decoder {
    
    func decode<T>(
        _ type: T.Type = T.self,
        at keyPath: KeyPath,
        adapt: (JSONKeyDecoder) throws -> T
    ) throws -> T {
        return try adapt(JSONKeyDecoder(decoder: self, codingPath: keyPath.codingPath))
    }
    
    func decode<T>(
        _ type: T.Type = T.self,
        at keyPath: KeyPath
    ) throws -> T where T: Decodable {
        return try JSONKeyDecoder(decoder: self, codingPath: keyPath.codingPath)
            .decode(T.self)
    }
}

public class JSONKeyDecoder {
    
    internal enum Container {
        case keyed(KeyedDecodingContainer<JSONCodingKey>)
        case unkeyed(UnkeyedDecodingContainer)
    }
    
    public let decoder: Decoder
    
    public let codingPath: [JSONCodingKey]
    
    internal private(set) var container: Container
        
    internal init(decoder: Decoder, codingPath: [JSONCodingKey]) throws {
        self.decoder = decoder
        self.codingPath = codingPath
        
        container = .keyed(try decoder.container(keyedBy: JSONCodingKey.self))
        try zip(codingPath, codingPath.dropFirst()).forEach {
            switch $0 {
            case (let key, .index):
                container = try container.nestedUnkeyedContainer(forKey: key)
            case (let key, .key):
                container = try container.nestedKeyedContainer(forKey: key)
            }
        }
    }
    
    internal func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        guard let lastKey = codingPath.last else {
            throw JSONDecodingError.invalidPath
        }
        return try container.decode(forKey: lastKey)
    }
}

internal extension JSONKeyDecoder.Container {
    
    func nestedKeyedContainer(forKey key: JSONCodingKey) throws -> JSONKeyDecoder.Container {
        switch (self, key) {
        case (.keyed(let container), .key):
            return .keyed(try container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key))
        case (.unkeyed(var container), .index(let index)):
            guard let count = container.count, index < count else {
                throw JSONDecodingError.invalidPath
            }
            while index < container.currentIndex {
                _ = try? container.decode(EmptyBox.self)
            }
            return .keyed(try container.nestedContainer(keyedBy: JSONCodingKey.self))
        case (.keyed, .index), (.unkeyed, .key):
            throw JSONDecodingError.invalidPath
        }
    }
    
    func nestedUnkeyedContainer(forKey key: JSONCodingKey) throws -> JSONKeyDecoder.Container {
        switch (self, key) {
        case (.keyed(let container), .key):
            return .unkeyed(try container.nestedUnkeyedContainer(forKey: key))
        case (.unkeyed(var container), .index(let index)):
            guard let count = container.count, index < count else {
                throw JSONDecodingError.invalidPath
            }
            while index < container.currentIndex {
                _ = try? container.decode(EmptyBox.self)
            }
            return .unkeyed(try container.nestedUnkeyedContainer())
        case (.keyed, .index), (.unkeyed, .key):
            throw JSONDecodingError.invalidPath
        }
    }
    
    func decode<T>(_ type: T.Type = T.self, forKey key: JSONCodingKey) throws -> T where T: Decodable {
        switch (self, key) {
        case (.keyed(let container), .key):
            return try container.decode(type, forKey: key)
        case (.unkeyed(var container), .index(let index)):
            guard let count = container.count, index < count else {
                throw JSONDecodingError.invalidPath
            }
            while index < container.currentIndex {
                _ = try? container.decode(EmptyBox.self)
            }
            return try container.decode(type)
        case (.keyed, .index), (.unkeyed, .key):
            throw JSONDecodingError.invalidPath
        }
    }
}

internal struct EmptyBox: Decodable { }
