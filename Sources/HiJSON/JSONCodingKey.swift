//
//  JSONCodingKey.swift
//  
//
//  Created by jinxiaolong on 2022/12/2.
//

import Foundation

public enum JSONCodingKey: CodingKey {
    case key(String)
    case index(Int)
    
    public var stringValue: String {
        switch self {
        case .key(let stringValue):
            return stringValue
        case .index(let intValue):
            return "\(intValue)"
        }
    }
    
    public init(stringValue: String) {
        self = .key(stringValue)
    }
    
    public var intValue: Int? {
        switch self {
        case .key:
            return nil
        case .index(let intValue):
            return intValue
        }
    }
    
    public init(intValue: Int) {
        self = .index(intValue)
    }
}

extension JSONCodingKey: ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self = .index(value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self = .key(value)
    }
}
