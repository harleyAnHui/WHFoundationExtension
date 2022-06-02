//
//  String+Date.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/15.
//

import Foundation



extension String {
    
    /// Return a  'Date' which created from this 'String'
    ///
    /// - Parameter formatStyle: a specified format style. 'DateFormatStyle.local' as default
    /// - Returns: a  'Date'  or nil if create failed
    ///
    func date(with formatStyle: DateFormatStyle = DateFormatStyle.pattern1) -> Date? {
        return date(with: formatStyle.rawValue)
    }
    
    /// Return a  'Date' which created by the 'String'
    ///
    /// - Parameter dateFormat: a string representation of a 'Date'
    /// - Returns: a  'Date'  or nil if failed
    /// 
    func date(with dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        
        return formatter.date(from: self)
    }
}
