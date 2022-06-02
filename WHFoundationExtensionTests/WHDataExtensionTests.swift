//
//  WHDataExtensionTests.swift
//  WHFoundationExtensionTests
//
//  Created by wangwenhui on 2022/5/30.
//

import XCTest
@testable import WHFoundationExtension

class WHDataExtensionTests: XCTestCase {

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

    
    
    func testBasic() {
        let dict = ["hello": Data([0x68, 0x65, 0x6C, 0x6C, 0x6F])]
        let helloValue = dict.values.first!
        let helloData = dict.keys.first!.data(using: .utf8)
        XCTAssert(helloData!.elementsEqual(dict.values.first!))
        XCTAssert(helloData!.asString()!.elementsEqual(dict.keys.first!))
        
        let data = Data([0x15, 0xa3, 0xbc, 0xff])
        XCTAssert(data.asString() == nil)
        
        let emptyData = Data([])
        XCTAssert(emptyData.asString() == "")

        XCTAssert(helloValue.hexString.elementsEqual("68656C6C6F"))
        XCTAssert(helloValue.hexString(with: "-").elementsEqual("68-65-6C-6C-6F"))
        XCTAssert(helloValue.hexString(with: "---").elementsEqual("68---65---6C---6C---6F"))
        XCTAssert(emptyData.hexString(with: "-").elementsEqual(""))
        XCTAssert(emptyData.hexString(with: "").elementsEqual(""))

        XCTAssertFalse(helloValue.hasPrefix(data: nil))
        XCTAssertFalse(helloValue.hasPrefix(data: Data([0x68, 0x65, 0x6c, 0x6f])))
        XCTAssertFalse(helloValue.hasPrefix(data: Data([0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x6f])))
        XCTAssertTrue(helloValue.hasPrefix(data: Data([0x68, 0x65, 0x6c, 0x6c, 0x6f])))
        XCTAssertTrue(helloValue.hasPrefix(data: Data([0x68, 0x65])))
        
        XCTAssertFalse(helloValue.hasSuffix(data: nil))
        XCTAssertFalse(helloValue.hasSuffix(data: Data([0x11, 0x68, 0x65, 0x6c, 0x6c, 0x6f])))
        XCTAssertFalse(helloValue.hasSuffix(data: Data([0x68, 0x6f])))
        XCTAssertTrue(helloValue.hasSuffix(data: Data([0x68, 0x65, 0x6c, 0x6c, 0x6f])))
        XCTAssertTrue(helloValue.hasSuffix(data: Data([0x6f])))

        XCTAssertFalse(helloValue.contains(data: nil))
        XCTAssertFalse(helloValue.contains(data: Data([0x6d])))
        XCTAssertTrue(helloValue.contains(data: Data([0x68, 0x65, 0x6c, 0x6c, 0x6f])))
        XCTAssertTrue(helloValue.contains(data: Data([0x65, 0x6c, 0x6c])))
        XCTAssertFalse(emptyData.contains(data: Data([0x6d])))


        let response1 = Data([0x55, 0xAA, 0x6C, 0x6C, 0x6F, 0x55, 0xAA, 0x40, 0x69, 0xFF])
        var components = response1.components(separatedBy: Data([0x55, 0xAA]), startIndex: response1.startIndex)
        XCTAssertTrue(components.count == 2)
        XCTAssertTrue(components[0].elementsEqual(Data([0x55, 0xAA, 0x6C, 0x6C, 0x6F])))
        XCTAssertTrue(components[1].elementsEqual(Data([0x55, 0xAA, 0x40, 0x69, 0xFF])))
        components = response1.components(separatedBy: Data([0x55, 0xAA, 0x6C]), startIndex: response1.startIndex)
        XCTAssertTrue(components.count == 1)
        components = response1.components(separatedBy: Data([0x66]), startIndex: response1.startIndex)
        XCTAssertTrue(components.count == 0)
        components = response1.components(separatedBy: Data(), startIndex: response1.startIndex)
        XCTAssertTrue(components.count == 0)
        components = response1.components(separatedBy: Data([0xff]), startIndex: response1.startIndex)
        XCTAssertTrue(components.count == 1)
        components = response1.components(separatedBy: Data([0x6c]), startIndex: response1.startIndex)
        XCTAssertTrue(components.count == 2)
        
        let response2 = Data([0x55, 0xAA, 0x6C, 0x6C, 0x6F, 0x00, 0x0A, 0x40, 0x69, 0xFF, 0x80])
        let range1 = response2.range(of: [Data([0x55, 0xAA])], startIndex: response2.startIndex)
        XCTAssertTrue(range1!.elementsEqual(0..<response2.endIndex))
        let range2 = response2.range(of: [Data([0x55, 0xAA]), Data([0x00, 0x0A]), Data([0xFF, 0x80])], startIndex: response2.startIndex)
        XCTAssertTrue(range2!.elementsEqual(0..<5))
        let range3 = response2.range(of: [Data([0x55, 0xAA]), Data([0x00, 0x0A]), Data([0xFF, 0x80])], startIndex: response2.index(0, offsetBy: 5))
        XCTAssertTrue(range3!.elementsEqual(5..<9))
        let range4 = response2.range(of: [Data([0x55, 0xAA]), Data([0x00, 0x0A]), Data([0xFF, 0x80])], startIndex: response2.index(0, offsetBy: 9))
        XCTAssertTrue(range4!.elementsEqual(9..<11))
        let range5 = response2.range(of: [Data([0x55, 0xAA]), Data([0x00, 0x0A]), Data([0xFF, 0x80])], startIndex: response2.index(0, offsetBy: 11))
        XCTAssertNil(range5)
        
        let range6 = response2.range(of: [Data([0x55, 0xAA, 0x88])], startIndex: response2.startIndex)
        XCTAssertNil(range6)
        let range7 = response2.range(of: [Data([0x6c, 0x6c])], startIndex: response2.startIndex)
        XCTAssertTrue(range7!.elementsEqual(2..<11))
        let range8 = response2.range(of: [Data()], startIndex: response2.startIndex)
        XCTAssertNil(range8)
        let range9 = emptyData.range(of: [Data([0x6c, 0x6c])], startIndex: response2.startIndex)
        XCTAssertNil(range9)

        let nsData = data.nsData
        XCTAssertTrue(nsData.elementsEqual([0x15, 0xa3, 0xbc, 0xff]))
        let cfData = data.cfData
        XCTAssertTrue(CFDataGetLength(cfData) == 4)

        let numberString = "1234567890"
        let numberData = numberString.data(using: .utf8)
        let numberBase64Data = numberData?.base64EncodedData
        XCTAssertTrue(numberBase64Data!.base64DecodedData!.elementsEqual(numberData!))
        XCTAssertTrue(numberBase64Data!.base64DecodedString!.elementsEqual(numberString))

    }
    
    func testCommonCrypto() {
        let data = Data([0x31, 0x32, 0x33, 0x34])
        do {
            /// Diggest
            let sha1 = try data.digest(using: SecurityDigestType.SHA1)
            XCTAssertTrue(sha1.elementsEqual("7110EDA4D09E062AA5E4A390B0A572AC0D2C0220".dataFromHexString!))
            
            let sha224 = try data.digest(using: SecurityDigestType.SHA224)
            XCTAssertTrue(sha224.elementsEqual("99FB2F48C6AF4761F904FC85F95EB56190E5D40B1F44EC3A9C1FA319".dataFromHexString!))
            
            let sha256 = try data.digest(using: SecurityDigestType.SHA256)
            XCTAssertTrue(sha256.elementsEqual("03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4".dataFromHexString!))
            
            let sha384 = try data.digest(using: SecurityDigestType.SHA384)
            XCTAssertTrue(sha384.elementsEqual("504f008c8fcf8b2ed5dfcde752fc5464ab8ba064215d9c5b5fc486af3d9ab8c81b14785180d2ad7cee1ab792ad44798c".dataFromHexString!))
            
            let sha512 = try data.digest(using: SecurityDigestType.SHA512)
            XCTAssertTrue(sha512.elementsEqual("d404559f602eab6fd602ac7680dacbfaadd13630335e951f097af3900e9de176b6db28512f2e000b9d04fba5133e8b1c6e8df59db3a8ab9d60be4b97cc9e81db".dataFromHexString!))
            
            /// Encrypt / Decrypt
            let plain = "0123456789".data(using: .utf8)!
            let key8 = "01234567".data(using: .utf8)!
            let iv8 = "01234567".data(using: .utf8)!
            
            /// DES
            var encoded = try plain.encrypt(alg: SecurityAlgorithm.DES, mode: SecurityMode.EBC, padding: SecurityPadding.PKCS7Padding, key: key8, iv: iv8)
            XCTAssertTrue(encoded.base64EncodedString().elementsEqual("xQrQKMbamABjVveOUBYk3g=="))

            var decoded = try encoded.decrypt(alg: SecurityAlgorithm.DES, mode: SecurityMode.EBC, padding: SecurityPadding.PKCS7Padding, key: key8, iv: iv8)
            var final = decoded.subdata(in: 0..<plain.count)
            XCTAssertTrue(final.elementsEqual(plain))
            
            /// 3DES
            let key24 = "0123456789abcedf01234567".data(using: .utf8)!
            let iv24 = "0123456789abcedf01234567".data(using: .utf8)!
            encoded = try plain.encrypt(alg: SecurityAlgorithm.TriDES, mode: SecurityMode.CBC, padding: SecurityPadding.PKCS7Padding, key: key24, iv: iv24)
            XCTAssertTrue(encoded.elementsEqual("761fd098576a0e802044771c1336d09d".dataFromHexString!))
            
            decoded = try encoded.decrypt(alg: SecurityAlgorithm.TriDES, mode: SecurityMode.CBC, padding: SecurityPadding.PKCS7Padding, key: key24, iv: iv24)
            final = decoded.subdata(in: 0..<plain.count)
            XCTAssertTrue(final.elementsEqual(plain))
            
            /// AES
            let key16 = "0123456789abcedf".data(using: .utf8)!
            let iv16 = "0123456789abcedf".data(using: .utf8)!
            encoded = try plain.encrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.CFB, padding: SecurityPadding.ISO7816Padding, key: key16, iv: iv16)

            decoded = try encoded.decrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.CFB, padding: SecurityPadding.ISO7816Padding, key: key16, iv: iv16)
            final = decoded.subdata(in: 0..<plain.count)
            XCTAssertTrue(final.elementsEqual(plain))
            
            encoded = try plain.encrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.CBC, padding: SecurityPadding.ANSIPadding, key: key16, iv: iv16)
            XCTAssertTrue(encoded.elementsEqual("f44f7fd8f4bc1f194500ec421785c21d".dataFromHexString!))

            decoded = try encoded.decrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.CBC, padding: SecurityPadding.ANSIPadding, key: key16, iv: iv16)
            final = decoded.subdata(in: 0..<plain.count)
            XCTAssertTrue(final.elementsEqual(plain))
            
            encoded = try plain.encrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.OFB, padding: SecurityPadding.ZeroPadding, key: key16, iv: iv16)
            XCTAssertTrue(encoded.elementsEqual("434c8180a8e306952921cabd7c20c88a".dataFromHexString!))

            decoded = try encoded.decrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.OFB, padding: SecurityPadding.ZeroPadding, key: key16, iv: iv16)
            final = decoded.subdata(in: 0..<plain.count)
            XCTAssertTrue(final.elementsEqual(plain))
            
            encoded = try plain.encrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.EBC, padding: SecurityPadding.PKCS7Padding, key: key16, iv: iv16)
            XCTAssertTrue(encoded.elementsEqual("f79816c2ef6cd57fab20164a4b34ce02".dataFromHexString!))

            decoded = try encoded.decrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.EBC, padding: SecurityPadding.PKCS7Padding, key: key16, iv: iv16)
            final = decoded.subdata(in: 0..<plain.count)
            XCTAssertTrue(final.elementsEqual(plain))
            
            /// RC4
            encoded = try plain.encrypt(alg: SecurityAlgorithm.RC4, mode: SecurityMode.RC4, padding: SecurityPadding.NoPadding, key: key16, iv: iv16)
            XCTAssertTrue(encoded.base64EncodedString().elementsEqual("K2D8w8k6cVv1Vg=="))
            
            decoded = try encoded.decrypt(alg: SecurityAlgorithm.RC4, mode: SecurityMode.RC4, padding: SecurityPadding.NoPadding, key: key16, iv: iv16)
            final = decoded.subdata(in: 0..<plain.count)
            XCTAssertTrue(final.elementsEqual(plain))
            
            let key64 = "0123456789abcedf0123456789abcedf0123456789abcedf0123456789abcedf".data(using: .utf8)!
            encoded = try plain.encrypt(alg: SecurityAlgorithm.RC4, mode: SecurityMode.RC4, padding: SecurityPadding.NoPadding, key: key64, iv: iv16)
            XCTAssertTrue(encoded.base64EncodedString().elementsEqual("K2D8w8k6cVv1Vg=="))
            
            decoded = try encoded.decrypt(alg: SecurityAlgorithm.RC4, mode: SecurityMode.RC4, padding: SecurityPadding.NoPadding, key: key64, iv: iv16)
            final = decoded.subdata(in: 0..<plain.count)
            XCTAssertTrue(final.elementsEqual(plain))
            
        } catch {
            print(error)
            XCTAssertFalse(true)
        }
    }
    
    
    func testSecKey() {
        ///
        let pem = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCZVhSgVQHZjFK4C/V98YN8z3TAGeEl/dSoJF2pz2/G81e+wE6dvX6ALhD/lMs+b330QrAn8N4HQyxwHZ8IrbOjvt9xrTJaT/f2HXQwVZgG5vYV/3VgOL0IaNi8xb1Bw3WDHs5NSJ6e7NZuCVK+obmUe+hrIK6YUCm6NX4PveHOQQIDAQAB"
        var der = pem.base64DecodedData
        var publicKey = der?.publicKey
        XCTAssertNotNil(publicKey) /* - some : <SecKeyRef algorithm id: 1, key type: RSAPublicKey, version: 4, block size: 1024 bits, exponent: {hex: 10001, decimal: 65537}, modulus: 995614A05501D98C52B80BF57DF1837CCF74C019E125FDD4A8245DA9CF6FC6F357BEC04E9DBD7E802E10FF94CB3E6F7DF442B027F0DE07432C701D9F08ADB3A3BEDF71AD325A4FF7F61D7430559806E6F615FF756038BD0868D8BCC5BD41C375831ECE4D489E9EECD66E0952BEA1B9947BE86B20AE985029BA357E0FBDE1CE41, addr: 0x600001879330> */
        
        let testBundle = Bundle(for: type(of: self))
        let publicKeyFile = testBundle.path(forResource: "public_pkcs1", ofType: ".pem")
        var secKeyPem = SecKeyPem(path: publicKeyFile!)
        XCTAssertNotNil(secKeyPem)
        var body = secKeyPem!.body
        XCTAssertNotNil(body)
        der = body!.base64DecodedData
        publicKey = der?.publicKey
        XCTAssertNotNil(publicKey)
        
        let privateKeyFile = testBundle.path(forResource: "private_pkcs1", ofType: ".pem")
        secKeyPem = SecKeyPem(path: privateKeyFile!)
        XCTAssertNotNil(secKeyPem)
        body = secKeyPem!.body
        XCTAssertNotNil(body)
        der = body!.base64DecodedData
        let privateKey = der?.privateKey
        XCTAssertNotNil(privateKey)
        
        do {
            /// Create RSA Key pair
            let (publicSecKey, privateSecKey) = try Data.createRSAKeyPair(2048)
            
            /// Encrypt / Decrypt
            var plain = "1234567890".data(using: .utf8)
            var cipher = try plain?.encrypt(with: publicSecKey)
            XCTAssertEqual(cipher?.count, 256)
            
            var decrpt = try cipher?.decrpt(with: privateSecKey)
            XCTAssertEqual(decrpt!, plain!)
            
            plain = "995614A05501D98C52B80BF57DF1837CCF74C019E125FDD4A8245DA9CF6FC6F357BEC04E9DBD7E802E10FF94CB3E6F7DF442B027F0DE07432C701D9F08ADB3A3BEDF71AD325A4FF7F61D7430559806E6F615FF756038BD0868D8BCC5BD41C375831ECE4D489E9EECD66E0952BEA1B9947BE86B20AE985029BA357E0FBDE1CE41".data(using: .utf8)
            
            cipher = try plain?.encrypt(with: publicSecKey)
            XCTAssertEqual(cipher?.count, 512)
            
            decrpt = try cipher?.decrpt(with: privateSecKey)
            XCTAssertEqual(decrpt!,plain!)
            
            /// Sign / Verify
            var plainDigest = try plain?.digest(using: SecurityDigestType.SHA256)
            var signature = try plainDigest?.signature(with: privateSecKey, digestType: SecurityDigestType.SHA256)
            XCTAssertNotNil(signature)
            var successful = try signature!.verifySignature(with: publicSecKey, dataToSign: plainDigest!, digestType: SecurityDigestType.SHA256)
            XCTAssertTrue(successful)
            
            plainDigest = try plain?.digest(using: SecurityDigestType.SHA512)
            signature = try plainDigest?.signature(with: privateSecKey, digestType: SecurityDigestType.SHA512)
            XCTAssertNotNil(signature)
            successful = try signature!.verifySignature(with: publicSecKey, dataToSign: plainDigest!, digestType: SecurityDigestType.SHA512)
            XCTAssertTrue(successful)
            
        } catch  {
            print(error)
            XCTFail()
        }
        
    }
}
