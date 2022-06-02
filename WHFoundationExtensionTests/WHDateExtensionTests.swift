//
//  WHDateExtensionTests.swift
//  WHFoundationExtensionTests
//
//  Created by wangwenhui on 2022/5/30.
//

import XCTest

@testable import WHFoundationExtension


class WHDateExtensionTests: XCTestCase {

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

    
    func testDateBasic() throws {
        let testString1 = "2022-05-06 10:56:00"
        guard let date1 = testString1.date() else {
            XCTFail()
            return
        }
        
        let dateStr = date1.string()
        XCTAssertEqual(dateStr, testString1)
        
        let testString2 = "2022-05-06T10:56:51.259Z"
        guard let date2 = testString2.date(with: DateFormatStyle.pattern2) else {
            XCTFail()
            return
        }
        
        let dateStr2 = date2.string(with: DateFormatStyle.pattern2)
        XCTAssertEqual(dateStr2, testString2)
        
        let testString3 = "2022-05-06T10:56:51Z"
        guard let date3 = testString3.date(with: DateFormatStyle.pattern3) else {
            XCTFail()
            return
        }
        
        let dateStr3 = date3.string(with: DateFormatStyle.pattern3)
        XCTAssertEqual(dateStr3, testString3)
        
        let testString4 = "01996.July.10 AD 12:08 PM"
        guard let date4 = testString4.date(with: DateFormatStyle.pattern4) else {
            XCTFail()
            return
        }
        let dateStr4 = date4.string(with: DateFormatStyle.pattern4)
        XCTAssertEqual(dateStr4, testString4)
    }
}
