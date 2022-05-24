//
//  Dictionary+Basic.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/16.
//

import Foundation

extension Dictionary {
    var jsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return nil
        }
        
        return data.asString()
    }
}
