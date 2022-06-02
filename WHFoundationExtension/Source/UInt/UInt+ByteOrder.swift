//
//  UInt+Basic.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/16.
//

import Foundation

/**
 Endianness is primarily expressed as big-endian (BE) or little-endian (LE). A big-endian system stores the most significant byte of a word at the smallest memory address and the least significant byte at the largest. A little-endian system, in contrast, stores the least-significant byte at the smallest address.
 reference to : https://en.wikipedia.org/wiki/Endianness
 **/

extension UInt16 {
    
    /// Init a 16-bit unsigned integer value type from a given 'Data'
    ///
    /// Return nil when 'offset+2 > data.count'
    ///
    /// - Parameters:
    ///   - data: a Data value type
    ///   - offset: to start index of the Data, default is zero.
    ///   - bigEndian: true indicate the given 'Data' will be encoded in big-endian byte ordering. false in Little-Endian byte ordering.
    ///
    public  init?(data: Data, offset: Int = 0, bigEndian: Bool = true) {
        guard offset + 2 <= data.count else {
            return nil
        }
        
        if bigEndian {
            self = (UInt16(data[offset]) << 8) + UInt16(data[offset + 1])
        } else {
            self = (UInt16(data[offset + 1]) << 8) + UInt16(data[offset])
        }
    }
    
    /// Create a 'Data' from self which is a 16-bit unsigned integer value type
    ///
    /// - Parameter bigEndian: true indicate 'self' will be  encoded in big-endian byte ordering. false in Little-Endian byte ordering. Default true.
    /// - Returns: a 'Data' only containing two bytes
    ///
    public func data(bigEndian: Bool = true) -> Data {
        let big = UInt8((self & 0xff00) >> 8)
        let little = UInt8(self & 0x00ff)

        let array = bigEndian ? [big, little] : [little, big]
        return Data(array)
    }
}

extension UInt32 {
    
    /// Init a 32-bit unsigned integer value type from a given 'Data'
    ///
    /// Return nil when 'offset+4 > data.count'
    ///
    /// - Parameters:
    ///   - data: a 'Data' value type to be encoded
    ///   - offset: to start index of the Data, default is zero.
    ///   - bigEndian: true indicate the given 'Data' will be encoded in big-endian byte ordering. false in Little-Endian byte ordering. Default true.
    ///
    public init?(data: Data, offset: Int = 0, bigEndian: Bool = true) {
        guard offset + 4 <= data.count else {
            return nil
        }

        let strideRange = bigEndian ?
            stride(from: offset, to: offset + 4, by: 1) :
            stride(from: offset + 3, to: offset - 1 , by: -1)

        var result: UInt32 = 0
        for i in strideRange {
            result = (result << 8) + UInt32(data[i])
        }
        self = result
    }

    /// Create a 'Data' from self which is a 32-bit unsigned integer value type
    ///
    /// - Parameter bigEndian: true indicate 'self' will be  encoded in big-endian byte ordering. false in Little-Endian byte ordering. Default true.
    /// - Returns: a 'Data' only containing four bytes
    ///
    public func data(bigEndian: Bool = true) -> Data {
        let first = UInt8((self & 0xff000000) >> 24)
        let second = UInt8((self & 0x00ff0000) >> 16)
        let third = UInt8((self & 0x0000ff00) >> 8)
        let fourth = UInt8(self & 0x000000ff)

        let array = bigEndian ? [first, second, third, fourth] : [fourth, third, second, first]
        return Data(array)
    }
}

extension UInt64 {
    /// Init a 64-bit unsigned integer value type from a given 'Data'
    ///
    /// Return nil when 'offset+8 > data.count'
    ///
    /// - Parameters:
    ///   - data: a 'Data' value type to be encoded
    ///   - offset: to start index of the Data, default is zero.
    ///   - bigEndian: true indicate the given 'Data' will be encoded in big-endian byte ordering. false in Little-Endian byte ordering. Default true.
    ///
    public init?(data: Data, offset: Int = 0, bigEndian: Bool = true) {
        guard offset + 8 <= data.count else {
            return nil
        }

        let strideRange = bigEndian ?
            stride(from: offset, to: offset + 8, by: 1) :
            stride(from: offset + 7, to: offset - 1 , by: -1)

        var result: UInt64 = 0
        for i in strideRange {
            result = (result << 8) + UInt64(data[i])
        }
        self = result
    }

    /// Create a 'Data' from self which is a 64-bit unsigned integer value type
    ///
    /// - Parameter bigEndian: true indicate 'self' will be  encoded in big-endian byte ordering. false in Little-Endian byte ordering. Default true.
    /// - Returns: a 'Data' only containing four bytes
    ///
    public func data(bigEndian: Bool = true) -> Data {
        let first = UInt8((self & 0xff00000000000000) >> 56)
        let second = UInt8((self & 0x00ff000000000000) >> 48)
        let third = UInt8((self & 0x0000ff0000000000) >> 40)
        let fourth = UInt8((self & 0x000000ff00000000) >> 32)
        
        let fifth = UInt8((self & 0x00000000ff000000) >> 24)
        let sixth = UInt8((self & 0x0000000000ff0000) >> 16)
        let seventh = UInt8((self & 0x000000000000ff00) >> 8)
        let eighth = UInt8(self & 0x00000000000000ff)

        let array = bigEndian ? [first, second, third, fourth, fifth, sixth, seventh, eighth] : [eighth, seventh, sixth, fifth, fourth, third, second, first]
        return Data(array)
    }
}
