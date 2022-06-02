//
//  Dictionary+Basic.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/16.
//

import Foundation

extension Dictionary {
    /// Generate a json string from 'self' a 'Dictionary' type
    ///
    /// Return nil if this object can't produce a 'Data'
    ///
    public var jsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return nil
        }
        
        return data.asString()
    }
}
