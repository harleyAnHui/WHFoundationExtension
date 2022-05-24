//
//  Data+Basic.swift
//  FoundationExtension
//
//  Created by wangwenhui on 2022/4/13.
//

import Foundation

extension Data {
    
    /// Return a string representation of 'Data'.
    /// - Parameter encoding: a type of encoding string. Default is '.utf8'
    /// - Returns: a optional string.  return nil if encoding failed
    func asString(encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
    
    /// Return a hexdecimal string which is uppercased.
    var hexString: String {
        return reduce("") {
            $0 + String(format: "%02x", $1)
        }.uppercased()
    }
    
    
    /// Return a hexdecimal string which is seperated by a given string.
    ///     let data = Data([0x1a, 0x23, 0xff])
    ///     let hex = data.hexString(with: "-")
    ///     print(hex) // "1A-23-FF"
    /// - Parameter delimiters: a given string
    /// - Returns: a hexdecimal string which is uppercased.
    func hexString(with delimiters: String) -> String {
        guard self.count != 0 else {
            return ""
        }
        
        var tmp = reduce("") {
            $0 + String(format: "%02x\(delimiters)", $1)
        }
        
        tmp.removeLast(delimiters.count)
        
        return tmp.uppercased()
    }
    
    /// Return a 'Bool' value that indicates whether a given 'data'  matches the beginning bytes of this 'data'
    ///
    /// - Parameter data: data to be searched for
    /// - Returns: Return true, if this 'data' start with the given 'data'.
    func hasPrefix(data: Data?) -> Bool {
        guard let wrappedData = data else {
            return false
        }
        
        guard wrappedData.endIndex <= self.endIndex else {
            return false
        }
        
        let inRange = self.startIndex..<wrappedData.endIndex
        guard let _ = self.firstRange(of: wrappedData, in: inRange) else {
            return false
        }
        
        return true
    }
    
    /// Return a 'Bool' value that indicates whether a given 'data'  matches the ending bytes of this 'data'
    ///
    /// - Parameter data: data to be matched
    /// - Returns: Return true, if this 'data' end with the given 'data'.
    func hasSuffix(data: Data?) -> Bool {
        guard let wrappedData = data else {
            return false
        }
        
        guard wrappedData.endIndex <= self.endIndex else {
            return false
        }
        
        let inRange = (self.endIndex - wrappedData.endIndex)..<self.endIndex
        guard let _ = self.range(of: wrappedData, in: inRange) else {
            return false
        }
        
        return true
    }
    
    /// Find the data to be contained in the content of this data.
    /// - Parameter data: the data to be matched, it is an optional type.
    /// - Returns: a 'Bool' type, it is true if this data did contains the data to be matched.
    func contains(data: Data?) -> Bool {
        guard data != nil else {
            return false
        }
        
        let range = self.range(of: data!, options:NSData.SearchOptions() , in: nil)
        guard range != nil else {
            return false
        }
        
        return true
    }
    
    
    /// Separate this data by 'prefixData' and finally return An 'Data' array in which every 'Data' should start with 'prefixData'
    /// If this data doesn't contain the given 'prefixData', then return an array only includes this data.
    /// - Parameters:
    ///   - prefixData: The 'Data' in the return array should start with 'prefixData'
    ///   - startIndex: The location of start for searching
    /// - Returns: An 'Data' array. The 'Data' in this array should start with 'prefixData', except that self doesn't contains 'prefixData'
    /// - Complexity: O(*m*), where *m* is the byte count of this data.
    func components(separatedBy prefixData: Data, startIndex:Data.Index) -> [Data] {
        var elements: [Data] = [Data]()
        
        var currentIndex = startIndex
        while currentIndex < self.endIndex {
            /// search 'prefixData' from 'currentIndex'
            var inRange = currentIndex..<self.endIndex
            guard let firstRange = self.range(of: prefixData, options:NSData.SearchOptions() , in: inRange) else {
                /// no found 'prefixData' in the range, just break
                break
            }
            /// search 'prefixData' from the end index of 'firstRange'
            inRange = firstRange.endIndex ..< self.endIndex
            guard let secondRange = self.range(of: prefixData, options:NSData.SearchOptions() , in: inRange) else {
                /// no found more 'prefixData', then sub data from the start index of 'firstRange'
                let element = self.subdata(in: firstRange.startIndex..<self.endIndex)
                elements.append(element)
                
                break
            }
            
            let subRange = firstRange.startIndex..<secondRange.startIndex
            let element = self.subdata(in: subRange)
            elements.append(element)
            
            currentIndex = secondRange.startIndex
        }

        return elements
    }
    
    /// Find the data in given array in the conent of 'Data'
    ///
    /// The following example show how to find the locations of '0x5a' and '0x00' in the 'data' and get a range bettween the two locations.
    ///     let data = Data([0x05, 0x5a, 0x02, 0x00, 0x1c, 0x00])
    ///     let datasToFind = [Data([0x5a]), Data([0x00])]
    ///     let range = data.range(of: datasToFind, startIndex: 0)
    ///     print(range) // (1..<4)
    ///     
    /// - Parameters:
    ///   - datasToFind: The datas to be searched for, it is a 'Data' array
    ///   - startIndex: The location of start for searching
    /// - Returns: A 'Range' specifying the location of the found data.
    /// - Complexity: O(*n* + *m*), where *n* is count of this 'datasToFind' and where *m* is the byte count of this data.
    func range(of datasToFind: [Data], startIndex: Data.Index) -> Range<Data.Index>? {
        var firstRanges:[Range<Data.Index>] = []
        
        for dataToFind in datasToFind {
            /// Start search for 'dataToFind' in the content of 'Data'  from the location of  'startIndex'
            if let range = self.range(of: dataToFind, options: [], in: startIndex..<self.endIndex) {
                firstRanges.append(range)
            }
        }
        /// Find the minimum range in 'firstRanges'
        let firstMinRange = firstRanges.min {  range1, range2  in
            return range1.lowerBound < range2.lowerBound
        }
        
        /// No find any data in 'datasToFind' in the content of this data.
        guard let _ = firstMinRange else {
            return nil
        }
        
        var secondRanges:[Range<Data.Index>] = []
                
        for dataToFind in datasToFind {
            /// Start search for 'dataToFind' in the content of 'Data'  from the location of  'firstMinRange!.endIndex'
            if let range = self.range(of: dataToFind, options: [], in: firstMinRange!.endIndex..<self.endIndex) {
                secondRanges.append(range)
            }
        }
        
        /// Find the minimum range in 'secondRanges'
        let secondMinRange = secondRanges.min {  range1, range2  in
            return range1.lowerBound < range2.lowerBound
        }

        guard let _ = secondMinRange else {
            return firstMinRange!.startIndex..<self.endIndex
        }
        
        return firstMinRange!.startIndex..<secondMinRange!.startIndex
    }
    
    /// Convert self to 'NSData'
    var nsData: NSData {
        return self as NSData
    }
    
    /// Convert self to 'CFData'
    var cfData: CFData {
        return self as CFData
    }
    
    
    /// Returns a Base-64 encoded 'Data'
    /// First get a Base-64 encoded string from self, then encode the string using '.utf8'
    var base64EncodedData: Data? {
        return base64EncodedString().data(using: .utf8)
    }
    
    /// Return a Base-64 decoded `String`
    /// This data  is a Base-64 encoded `Data`.
    ///
    /// Returns nil when self is not recognized as valid Base-64 'Data' or the Decoded 'Data' can't be encoded as 'String'
    var base64DecodedString: String? {
        let decodedData = Data(base64Encoded: self)
        return decodedData?.asString()
    }
    
    /// Return a  Base-64 decoded `Data`
    /// This data  is a Base-64 encoded `Data`.
    ///
    /// Returns nil when self is not recognized as valid Base-64 'Data'.
    var base64DecodedData: Data? {
        return Data(base64Encoded: self)
    }
}
