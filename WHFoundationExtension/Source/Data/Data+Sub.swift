//
//  Data+Sub.swift
//  FoundationExtension
//
//  Created by wangwenhui on 2022/4/13.
//

import Foundation

extension Data {
    func containsData(_ data: Data?) -> Bool {
        guard data != nil else {
            return false
        }
        
        let range = self.range(of: data!, options:NSData.SearchOptions() , in: nil)
        guard range != nil else {
            return false
        }
        
        return true
    }
}
