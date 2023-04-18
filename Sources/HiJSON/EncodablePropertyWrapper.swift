//
//  EncodablePropertyWrapper.swift
//  
//
//  Created by jinxiaolong on 2022/12/10.
//

import Foundation

internal protocol EncodablePropertyWrapper {
    
    func encode(to encoder: Encoder, label: String) throws
}
