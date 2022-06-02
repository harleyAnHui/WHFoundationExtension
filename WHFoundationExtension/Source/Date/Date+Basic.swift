//
//  Date+Basic.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/19.
//

import Foundation

/// Reference to : http://www.unicode.org/reports/tr35/tr35-19.html#Date_Format_Patterns
///
public enum DateFormatStyle: String {
    case pattern1 = "yyyy-MM-dd HH:mm:ss"  // 2009-06-15 13:45:30
    case pattern2 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // 2009-06-15T13:45:30.249Z
    case pattern3 = "yyyy-MM-dd'T'HH:mm:ss'Z'" // 2009-06-15T13:45:30Z
    case pattern4 = "yyyyy.MMMM.dd GGG hh:mm aaa" /// 01996.July.10 AD 12:08 PM
}

extension Date {
    
    /// Return a string representation of the 'Date',  which is formatted using the given format style.
    /// 
    /// - Parameter formatStyle: a specified format style. 'DateFormatStyle.local' as default
    /// - Returns: a string representation of the 'Date'
    ///
    func string(with formatStyle: DateFormatStyle = DateFormatStyle.pattern1) -> String {
        return string(with: formatStyle.rawValue)
    }
    
    /// Return a string representation of the 'Date',  which is formatted using the given 'dataFormat'
    ///
    /// - Parameter dataFormat: a format string, for example: "yyyy-MM-dd HH:mm:ss"
    /// - Returns: a string representation of the 'Date'
    /// 
    func string(with dataFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dataFormat
        formatter.locale = Locale.current
        
        return formatter.string(from: self)
    }
}
