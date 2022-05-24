//
//  String+Basic.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/16.
//

import Foundation

extension String {
    private var _dataFromHexString: Data? {
        var data: Data?
        var cursor = self.startIndex
        while cursor < self.endIndex {
            let range = cursor..<self.index(cursor, offsetBy: 2)
            guard range.upperBound <= self.endIndex else {
                break
            }
            
            let subString = self[range].uppercased()
            var intValue: Int = 0
            if Scanner(string: subString).scanInt(&intValue) {
                if data == nil {
                    data = Data()
                }
                data!.append(Data([UInt8(intValue)]))
            }
            
            cursor = self.index(cursor, offsetBy: 2)
        }
        
        return data
    }
    
    /// Get a 'Data' from this ‘String’ which is composed of some hexdecimal numbers
    ///     let hex = "15a3bcff"
    ///     let data = hex.dataFromHexString
    ///     print(data) // Data([0x15, 0xa3, 0xbc, 0xff])
    /// Return nil if this string can't be encoded as a C string
    var dataFromHexString: Data? {
        guard let chars = cString(using: String.Encoding.utf8) else { return nil }
        
        let count = self.count
        var data = Data(capacity: count/2)
        var cchars: [CChar] = [0, 0, 0]
        var compact: UInt = 0
        
        for i in stride(from: 0, to: count, by: 2) {
            cchars[0] = chars[i]
            cchars[1] = chars[i + 1]
            compact = strtoul(cchars, nil, 16)
            data.append(contentsOf: [UInt8(compact)])
        }
        return data
    }
    
    /// Return a "Dictionary<String, String>"
    var dictionary: Dictionary<String, String>? {
        guard let data = self.data(using: .utf8) else { return nil }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? Dictionary<String, String> else { return nil }
        
        return jsonObject
    }
    
    /// Return a Base-64 encoded `String`.
    ///
    /// First this string is encoded as 'Data' using '.utf8', then call  'base64EncodedString()'
    /// Return nil if encoding failed.
    var base64EncodedString: String? {
        let data = data(using: .utf8)
        
        return data?.base64EncodedString()
    }
    
    /// Return a Base-64 encoded `Data`.
    ///
    /// First this string is encoded as 'Data' using '.utf8', then call 'base64EncodedData'
    /// Return nil if encode failed.
    var base64EncodedData: Data? {
        let data = data(using: .utf8)
        
        return data?.base64EncodedData
    }
    
    /// Return a Base-64 decoded `String` .
    ///
    /// First this string is encoded as 'Data' using '.utf8', then decode this 'Data' by calling 'base64DecodedString'
    /// Return nil if decoding failed.
    var base64DecodedString: String? {
        let data = data(using: .utf8)
        
        return data?.base64DecodedString
    }
    
    /// Return a Base-64 decoded `String` .
    ///
    /// First self is encoded as 'Data' using '.utf8', then decode this 'Data' by calling 'base64DecodedData'
    /// Return nil if decoding failed.
    var base64DecodedData: Data? {
        let data = data(using: .utf8)

        return data?.base64DecodedData
    }
}