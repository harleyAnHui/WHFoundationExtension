//
//  WHUintExtensionTests.swift
//  WHFoundationExtensionTests
//
//  Created by wangwenhui on 2022/6/1.
//

import XCTest

@testable import WHFoundationExtension

class WHUintExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testUint() {
        let data1 = Data([0x15, 0xa3, 0xbc, 0xff])

        /// UInt16
        var value1 = UInt16(data: data1)
        XCTAssertEqual(value1, 0x15a3)
        
        value1 = UInt16(data: data1, bigEndian: false)
        XCTAssertEqual(value1, 0xa315)
        
        value1 = UInt16(data: data1, offset: 2)
        XCTAssertEqual(value1, 0xbcff)
        
        value1 = UInt16(data: data1, offset: 3)
        XCTAssertNil(value1)
 
        value1 = 0x15a3
        var data = value1?.data()
        XCTAssertEqual(data, Data([0x15, 0xa3]))
        
        data = value1?.data(bigEndian: false)
        XCTAssertEqual(data, Data([0xa3, 0x15]))
        
        /// UInt32
        let data2 = Data([0x15, 0xa3, 0xbc, 0xff, 0x35, 0xea])
        var value2 = UInt32(data: data2)
        XCTAssertEqual(value2!, 363052287)
        
        value2 = UInt32(data: data2, bigEndian: false)
        XCTAssertEqual(value2, 0xffbca315)
        
        value2 = UInt32(data: data2, offset: 2)
        XCTAssertEqual(value2, 0xbcff35ea)
        
        value2 = UInt32(data: data2, offset: 3)
        XCTAssertNil(value2)
        
        value2 = 0x15a3bcff
        data = value2?.data()
        XCTAssertEqual(data, Data([0x15, 0xa3, 0xbc, 0xff]))
        
        data = value2?.data(bigEndian: false)
        XCTAssertEqual(data, Data([0xff, 0xbc, 0xa3, 0x15]))
        
        /// UInt64
        let data3 = Data([0x15, 0xa3, 0xbc, 0xff, 0x35, 0xea, 0x22, 0x8d, 0x33, 0x44])
        var value3 = UInt64(data: data3)
        XCTAssertEqual(value3!, 0x15a3bcff35ea228d)
        
        value3 = UInt64(data: data3, bigEndian: false)
        XCTAssertEqual(value3, 0x8d22ea35ffbca315)
        
        value3 = UInt64(data: data3, offset: 2)
        XCTAssertEqual(value3, 0xbcff35ea228d3344)
        
        value3 = UInt64(data: data3, offset: 3)
        XCTAssertNil(value3)
        
        value3 = 0x15a3bcff35ea228d
        data = value3?.data()
        XCTAssertEqual(data, Data([0x15, 0xa3, 0xbc, 0xff, 0x35, 0xea, 0x22, 0x8d]))
        
        data = value3?.data(bigEndian: false)
        XCTAssertEqual(data, Data([0x8d, 0x22, 0xea, 0x35, 0xff, 0xbc, 0xa3, 0x15]))
    }
}
