//
//  UInt+Basic.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/16.
//

import Foundation

extension UInt16 {
    init?(data: Data, offset: Int = 0, bigEndian: Bool = true) {
        guard offset + 2 <= data.count else {
            return nil
        }
        if bigEndian {
            self = (UInt16(data[offset]) << 8) + UInt16(data[offset + 1])
        } else {
            self = (UInt16(data[offset + 1]) << 8) + UInt16(data[offset])
        }
    }

    func data(bigEndian: Bool = true) -> Data {
        let big = UInt8((self & 0xff00) >> 8)
        let small = UInt8(self & 0x00ff)

        let array = bigEndian ? [big, small] : [small, big]
        return Data(array)
    }
}

extension UInt32 {
    init?(data: Data, offset: Int = 0, bigEndian: Bool = true) {
        guard offset + 4 <= data.count else {
            return nil
        }

        var result: UInt32 = 0
        let strideRange = bigEndian ?
            stride(from: offset, to: offset + 4, by: 1) :
            stride(from: offset + 3, to: offset - 1 , by: -1)

        for i in strideRange {
            result = (result << 8) + UInt32(data[i])
        }
        self = result
    }

    func data(bigEndian: Bool = true) -> Data {
        let first = UInt8((self & 0xff000000) >> 24)
        let second = UInt8((self & 0x00ff0000) >> 16)
        let third = UInt8((self & 0xff000000) >> 8)
        let fourth = UInt8(self & 0x000000ff)

        let array = bigEndian ? [first, second, third, fourth] : [fourth, third, second, first]
        return Data(array)
    }
}
