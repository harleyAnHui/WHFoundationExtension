//
//  WHStringExtensionTests.swift
//  WHFoundationExtensionTests
//
//  Created by wangwenhui on 2022/5/30.
//

import XCTest

@testable import WHFoundationExtension

class WHStringExtensionTests: XCTestCase {

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

    
    func testStringBasic() {
        let data = Data([0x15, 0xa3, 0xbc, 0xff])
        let hex = data.hexString
        XCTAssertTrue(hex.dataFromHexString!.elementsEqual(data))
        let string = "15a3bcf"
        XCTAssertTrue(string.dataFromHexString!.elementsEqual(Data([0x15, 0xa3, 0xbc, 0x0f])))
        
        let jsonString = "{\"url\" : \"https://www.baidu.com\", \"name\" : \"harley\", \"id\" : \"1000001\", \"sex\" : \"male\"}"
        let dict = jsonString.dictionary
        XCTAssertTrue(dict != nil)
        XCTAssertNil("".dictionary)
        
        let number = "1234567890"
        let numberBase64Encoded = number.base64EncodedString
        print(numberBase64Encoded!)
        let numberBase64Decode = numberBase64Encoded?.base64DecodedString
        XCTAssertTrue(numberBase64Decode!.elementsEqual(number))
        
        let encodedData = number.base64EncodedData
        print("encodedData: \(encodedData!.hexString)")
        let decodedData = encodedData?.base64DecodedData
        print("decodedData: \(decodedData!.hexString)")
        let decodedString = decodedData?.asString()
        print("decodedString: \(decodedString!)")
        XCTAssertTrue(decodedString!.elementsEqual(number))
        
    }
    
    func testStringUrlEncoding() {
        var urlString = "http://www.aspxfans.com:8080/中国/index.asp?boardID=5&ID=24618&page=1#name"
        var encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com:8080/%E4%B8%AD%E5%9B%BD/index.asp?boardID=5&ID=24618&page=1#name")
        
        urlString = "http://www.aspxfan s.com:8080/news/in dex.asp?boardI D=5&ID=24618&page=1#na me"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfan%20s.com:8080/news/in%20dex.asp?boardI%20D=5&ID=24618&page=1#na%20me")
        
        urlString = "http://www.aspxfans.com:8080/中国/index.asp?boardID=5&ID=246&18&page=1#name"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com:8080/%E4%B8%AD%E5%9B%BD/index.asp?boardID=5&ID=246&18&page=1#name")

        
        urlString = "ftp://www.aspxfans.com"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "ftp://www.aspxfans.com")
        
        urlString = "http://www.aspxfans.com:80"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com:80")
        
        urlString = "http://www.aspxfans.com/news"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com/news")
        
        urlString = "http://www.aspxfans.com?boardID=5&ID=24618&page=1"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com?boardID=5&ID=24618&page=1")
        
        urlString = "http://www.aspxfans.com/news?boardID=5&ID=24618&page=1"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com/news?boardID=5&ID=24618&page=1")
        
        urlString = "http://www.aspxfans.com/news#name"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com/news#name")
        
        urlString = "http://www.aspxfans.com#name"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com#name")
        
        urlString = "http://"
        encoded = urlString.urlEncoding()
        XCTAssertNil(encoded)
        
        urlString = "http:/"
        encoded = urlString.urlEncoding()
        XCTAssertNil(encoded)
        
        urlString = "http://www.aspxfans.com#"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com#")
        
        urlString = "http://www.aspxfans.com?"
        encoded = urlString.urlEncoding()
        XCTAssertEqual(encoded, "http://www.aspxfans.com?")
        
        /// reference to: https://zhuanlan.zhihu.com/p/58479085
        ///
        /// RFC 3986 states that the following characters are "reserved" characters.
        ///
        /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
        /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
        ///
        /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
        /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
        /// should be percent-escaped in the query string.
        let delimiters = CharacterSet(charactersIn: ":#[]@!$&'()*+,;=")
        let allowedCharacters = CharacterSet.urlQueryAllowed.subtracting(delimiters)
        let query = "1234567890abcdef/?<>% 中-_.~:#[]@!$&'()*+,;="
        let escape = query.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
        
        XCTAssertEqual(escape, "1234567890abcdef/?%3C%3E%25%20%E4%B8%AD-_.~%3A%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D")
    }
}
