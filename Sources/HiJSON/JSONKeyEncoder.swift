//
//  JSONKeyEncoder.swift
//  
//
//  Created by jinxiaolong on 2022/12/10.
//

import Foundation

internal extension Encoder {
    
    func encode<T>(
        _ value: T,
        at keyPath: KeyPath,
        adapt: (T, JSONKeyEncoder) throws -> Void
    ) throws {
        try adapt(value, JSONKeyEncoder(encoder: self, codingPath: keyPath.codingPath))
    }
    
    func encode<T>(
        _ value: T,
        at keyPath: KeyPath
    ) throws where T: Encodable {
        try JSONKeyEncoder(encoder: self, codingPath: keyPath.codingPath)
            .encode(value)
    }
}

public class JSONKeyEncoder {
    
    internal enum Container {
        case keyed(KeyedEncodingContainer<JSONCodingKey>)
        case unkeyed(UnkeyedEncodingContainer)
    }
    
    public let encoder: Encoder
    
    public let codingPath: [JSONCodingKey]
    
    internal private(set) var container: Container
    
    internal init(encoder: Encoder, codingPath: [JSONCodingKey]) throws {
        self.encoder = encoder
        self.codingPath = codingPath
        
        container = .keyed(encoder.container(keyedBy: JSONCodingKey.self))
        try zip(codingPath, codingPath.dropFirst()).forEach {
            switch $0 {
            case (let key, .index):
                container = try container.nestedUnkeyedContainer(forKey: key)
            case (let key, .key):
                container = try container.nestedKeyedContainer(forKey: key)
            }
        }
    }
    
    internal func encode<T>(_ value: T) throws where T: Encodable {
        guard let lastKey = codingPath.last else {
            throw JSONEncodingError.invalidPath
        }
        try container.encode(value, forKey: lastKey)
    }
}

internal extension JSONKeyEncoder.Container {
    
    func nestedKeyedContainer(forKey key: JSONCodingKey) throws -> JSONKeyEncoder.Container {
        switch (self, key) {
        case (.keyed(var container), .key):
            return .keyed(container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key))
        case (.unkeyed(var container), .index(let index)):
            guard index < container.count else {
                throw JSONDecodingError.invalidPath
            }
            while index > container.count {
                try? container.encodeNil()
            }
            return .keyed(container.nestedContainer(keyedBy: JSONCodingKey.self))
        case (.keyed, .index), (.unkeyed, .key):
            throw JSONDecodingError.invalidPath
        }
    }
    
    func nestedUnkeyedContainer(forKey key: JSONCodingKey) throws -> JSONKeyEncoder.Container {
        switch (self, key) {
        case (.keyed(var container), .key):
            return .unkeyed(container.nestedUnkeyedContainer(forKey: key))
        case (.unkeyed(var container), .index(let index)):
            guard index < container.count else {
                throw JSONDecodingError.invalidPath
            }
            while index > container.count {
                try? container.encodeNil()
            }
            return .unkeyed(container.nestedUnkeyedContainer())
        case (.keyed, .index), (.unkeyed, .key):
            throw JSONDecodingError.invalidPath
        }
    }
    
    func encode<T>(_ value: T, forKey key: JSONCodingKey) throws where T: Encodable {
        switch (self, key) {
        case (.keyed(var container), .key):
            try container.encode(value, forKey: key)
        case (.unkeyed(var container), .index(let index)):
            guard index < container.count else {
                throw JSONDecodingError.invalidPath
            }
            while index > container.count {
                try? container.encodeNil()
            }
            try container.encode(value)
        case (.keyed, .index), (.unkeyed, .key):
            throw JSONDecodingError.invalidPath
        }
    }
}
