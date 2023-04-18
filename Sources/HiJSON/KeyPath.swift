//
//  KeyPath.swift
//  
//
//  Created by jinxiaolong on 2022/12/4.
//

import Foundation

/// ```
/// @JSONKey()
/// @JSONKey("user_name")
/// @JSONKey(KeyPath("user", "name"))
/// @JSONKey(KeyPath("users", 0, "name"))
/// ```
public struct KeyPath: ExpressibleByStringLiteral {
    
    internal let codingPath: [JSONCodingKey]
    
    internal init(codingPath: [JSONCodingKey]) {
        self.codingPath = codingPath
    }
    
    public init(_ codingKeys: JSONCodingKey...) {
        self.init(codingPath: codingKeys)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(codingPath: [.key(value)])
    }
}

public extension KeyPath {
    
    static func key(_ stringValue: String) -> KeyPath {
        return KeyPath(.key(stringValue))
    }
    
    static func index(_ intValue: Int) -> KeyPath {
        return KeyPath(.index(intValue))
    }
    
    func key(_ stringValue: String) -> KeyPath {
        return KeyPath(codingPath: codingPath + KeyPath.key(stringValue).codingPath)
    }
    
    func index(_ intValue: Int) -> KeyPath {
        return KeyPath(codingPath: codingPath + KeyPath.index(intValue).codingPath)
    }
    
    static func + (lhs: KeyPath, rhs: KeyPath) -> KeyPath {
        return KeyPath(codingPath: lhs.codingPath + rhs.codingPath)
    }
    
    static func + (lhs: KeyPath, rhs: JSONCodingKey) -> KeyPath {
        return KeyPath(codingPath: lhs.codingPath + KeyPath(rhs).codingPath)
    }
}
