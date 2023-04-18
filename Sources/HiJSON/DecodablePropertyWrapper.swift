//
//  DecodablePropertyWrapper.swift
//  
//
//  Created by jinxiaolong on 2022/12/3.
//

import Foundation

internal protocol DecodablePropertyWrapper {
    
    func decode(from decoder: Decoder, label: String) throws
}
