//
//  Date+Basic.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/19.
//

import Foundation

enum DateFormatStyle: String {
    case local = "yyyy-MM-dd HH:mm:ss"  //2009-06-15 13:45:30

    case ISO = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //2009-06-15T13:45:30.249Z
    case ISOShort = "yyyy-MM-dd'T'HH:mm:ss'Z'" //2009-06-15T13:45:30Z

}

extension Date {
    
    /// Return a string representation of the 'Date',  which is formatted using the given format style.
    /// - Parameter formatStyle: a specified format style. 'DateFormatStyle.local' as default
    /// - Returns: a string representation of the 'Date'
    func string(with formatStyle: DateFormatStyle = DateFormatStyle.local) -> String {
        return string(with: formatStyle.rawValue)
    }
    
    /// Return a string representation of the 'Date',  which is formatted using the given 'dataFormat'
    /// - Parameter dataFormat: a format string
    /// - Returns: a string representation of the 'Date'
    func string(with dataFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dataFormat
        
        return formatter.string(from: self)
    }
}
