//
//  Data+SecKey.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/20.
//

import Foundation
import Security
import CommonCrypto

public enum SecKeyError: Error {
    case createKeyError
    case InvalidParams
    case CreateEncryptedDataError
    case CreateDecryptedDataError
    case CreateSignatureError
}

// reference: https://github.com/ideawu/Objective-C-RSA/blob/master/RSA.m
/**
 "-----BEGIN RSA PUBLIC KEY-----\nMIIBCgKCAQEArb6rlir9rESq2iKsl1aukS+/7gyZ7PzPUssa3arhI2yPOyEC+0RA\nvT6pTsrf4y2YcU5KprHyEGD71YL0+yrBm8MCWr6cky3REbth7NFL1VBasEueil9X\nHBglgjwD1sJzWFeBYDZoKBNeZKyDQIyLyj6jSdq9PoU8JksvN4fQg7LhO7b24FUl\nDIW6H/b1Mb1HQS68c66Ny6J/cbePYBdkqSfzk9/e8D5/z9kRyb/Erw8qqgHbHgde\nwzEtcXH5hlD1LJMEfVyeVjCPoHwZdXvGAWI9CWTwi+zKkKm0EL6XGb0QlagakX2X\nby2XHJxeOYArxwKXZptBMh1s/a1FReLPwwIDAQAB\n-----END RSA PUBLIC KEY-----\n"
 **/
public struct SecKeyPem {
    let pem: String
    let begin: String = "-----BEGIN"
    let end: String = "-----END"
    let bodyStart: String = "-----\n"
    let bodyEnd: String = "\n-----"

    var body: String? {
        guard let start = pem.range(of: bodyStart), let end = pem.range(of: bodyEnd) else {
            return nil
        }
        return pem[start.upperBound..<end.lowerBound].replacingOccurrences(of: "\n", with: "")
    }
    
    init?(path: String) {
        do {
            pem = try String(contentsOfFile: path)
            guard pem.hasPrefix(begin), pem.contains(end) else {
                return nil
            }
            
        } catch {
            return nil
        }
    }
}

extension Data {
    
    /// Create an instance of  'SecKey' from this 'Data' which representing a public key
    /// Return nil on failure
    ///
    var publicKey: SecKey? {
        //keyData CFData representing the key. The format of the data is PKCS#1 format.
        let keyCFData = self.cfData
        
        let attributes = [
            kSecClassKey: kSecClass,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecValueData: keyCFData,
            kSecAttrKeyClass: kSecAttrKeyClassPublic
        ] as CFDictionary
        
        var error: Unmanaged<CFError>?
        
        guard let _seckey = SecKeyCreateWithData(keyCFData, attributes, &error) else {
            return nil
        }
        
        return _seckey
    }
    
    /// Create an instance of  'SecKey' from this 'Data' which representing a private key
    /// Return nil on failure
    ///
    var privateKey: SecKey? {
        //keyData CFData representing the key. The format of the data is PKCS#1 format.
        let keyCFData = self.cfData
        
        let attributes = [
            kSecClassKey: kSecClass,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecValueData: keyCFData,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ] as CFDictionary
        var error: Unmanaged<CFError>?
        
        guard let _seckey = SecKeyCreateWithData(keyCFData, attributes, &error) else {
            return nil
        }
        
        return _seckey
    }
    
    
    /// This is a class method. Create a key pair of RSA with the given bits.
    /// 
    /// - Parameter bits: the number of bits of the key
    /// - Returns: a key pair which representing a public key and a private key.
    /// - Throws: thow an error while creating failed.
    ///
    static func createRSAKeyPair(_ bits: Int) throws -> (SecKey, SecKey) {
        let tag = "com.WHfoundationExtension.keys.rsa".data(using: .utf8)
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: bits,
            kSecPrivateKeyAttrs: [
//                kSecAttrIsPermanent: true,  /// comment this line because it will make 'SecKeyCreateRandomKey' fail when running it in unit test.
                kSecAttrApplicationTag: tag as Any
            ] as [CFString : Any]
        ] as [CFString : Any]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        guard let pubicKey = SecKeyCopyPublicKey(privateKey) else {
            throw error!.takeRetainedValue() as Error
        }
        
        return (pubicKey, privateKey)
    }
    
    /// Encrypt this 'Data' with the public key
    ///
    /// - Parameter publicKey: an instance of SecKey
    /// - Returns:a cipher data
    /// - Throws: thow a SecKeyError while enrypt failed.
    ///
    func encrypt(with publicKey: SecKey) throws -> Data? {
        let plainCFData = self.cfData

        var error: Unmanaged<CFError>?
        let blockSize = SecKeyGetBlockSize(publicKey)
        let blockPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: blockSize)
        defer {
            blockPointer.deallocate()
        }
        
        var cipherData: Data?
        let plainCFDataLen = CFDataGetLength(plainCFData)
        let maxLength = blockSize - paddingLength(for: SecKeyAlgorithm.rsaEncryptionPKCS1)

        for index in stride(from: 0, to: plainCFDataLen, by: maxLength) {
            let length = index > (plainCFDataLen-maxLength) ? (plainCFDataLen-index) : maxLength
            blockPointer.initialize(repeating: 0, count: blockSize)
            CFDataGetBytes(plainCFData, CFRange(location: index, length: length), blockPointer)
            let blockCFData = NSData(bytes: blockPointer, length: length) as CFData

            guard let cfData = SecKeyCreateEncryptedData(publicKey, SecKeyAlgorithm.rsaEncryptionPKCS1, blockCFData, &error) else {
                throw SecKeyError.CreateEncryptedDataError
            }
            
            if cipherData == nil {
                cipherData = Data(bytes: CFDataGetBytePtr(cfData), count: CFDataGetLength(cfData))
            } else {
                cipherData?.append(CFDataGetBytePtr(cfData), count: CFDataGetLength(cfData))
            }
        }

        return cipherData
    }
    
    /// Encrypt this 'Data' with 'KeyData' representing the public key
    ///
    /// - Parameters:
    ///   - KeyData: an instance of 'Data' which representing a public key.
    /// - Returns: an ciphered 'Data' or nil on failure
    /// - Throws: thow an error while enrypt failed.
    ///
    func encrypt(with KeyData: Data) throws -> Data? {
        guard let publicKey = KeyData.publicKey else {
            throw SecKeyError.createKeyError
        }
        
        return try encrypt(with: publicKey)
    }
    
    func decrpt(with privateKey: SecKey) throws -> Data? {
        let cipherCFData = self.cfData
        var error: Unmanaged<CFError>?
        let blockSize = SecKeyGetBlockSize(privateKey)
        let blockPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: blockSize)
        var plainData: Data?
        let cipherCFDataLen = CFDataGetLength(cipherCFData)
        
        for index in stride(from: 0, to: cipherCFDataLen, by: blockSize) {
            let length = index > (cipherCFDataLen-blockSize) ? (cipherCFDataLen-index) : blockSize
            blockPointer.initialize(repeating: 0, count: blockSize)
            CFDataGetBytes(cipherCFData, CFRange(location: index, length: length), blockPointer)

            let blockCFData = NSData(bytes: blockPointer, length: blockSize) as CFData

            guard let data = SecKeyCreateDecryptedData(privateKey, SecKeyAlgorithm.rsaEncryptionPKCS1, blockCFData, &error) else {
                throw SecKeyError.CreateDecryptedDataError
            }
            
            if plainData == nil {
                plainData = Data(bytes: CFDataGetBytePtr(data), count: CFDataGetLength(data))
            } else {
                plainData?.append(CFDataGetBytePtr(data), count: CFDataGetLength(data))
            }
        }
        
        blockPointer.deallocate()

        return plainData
    }
    
    /// Decrypt this 'Data' with the private key.
    ///   - KeyData: an instance of 'Data' which representing a private key.
    /// - Returns: an ciphered 'Data' or nil on failure
    /// - Throws: thow an error while decrypt failed.
    ///
    func decrypt(with KeyData: Data) throws -> Data? {
        guard let privateKey = KeyData.privateKey else {
            throw SecKeyError.createKeyError
        }

        return try decrpt(with: privateKey)
    }
    
    
    /// Generate a digital signature from this 'Data' with the given private key and diggest type.
    ///  This 'Data' is the digest of actual value with given digest type.
    ///
    /// - Parameters:
    ///   - privateKey: Private key with which to sign.
    ///   - digestType: a digest type. reference to 'SecurityDigestType'
    /// - Returns:a data representing signature or nil on failure.
    /// - Throws: thow an error while sign failed.
    ///
    func signature(with privateKey: SecKey, digestType: SecurityDigestType) throws -> Data? {
        guard isValidLength(for: digestType) else {
            throw SecKeyError.InvalidParams
        }
        
        let hashedCFData = self.cfData
        
        let alg = signAlgorithm(for: digestType)
        var error: Unmanaged<CFError>?
        guard let _data = SecKeyCreateSignature(privateKey, alg, hashedCFData, &error) else {
            throw SecKeyError.CreateSignatureError
        }
        
        let signatureData: Data = Data(bytes: CFDataGetBytePtr(_data), count: CFDataGetLength(_data))
        
        return signatureData
    }
    
    
    /// Verify this 'Data' representing a signature with the given public key and diggest type.
    /// - Parameters:
    ///   - keyData: an instance of 'Data' which representing public key
    ///   - dataToSign: The data over which signature is being verified, typically the digest of the actual data.
    ///   - digestType: a diggest type. reference to 'SecurityDigestType'
    ///
    /// - Returns: true if verify successfully, else return false.
    ///
    /// - Throws: thow an error while keyData can't be as a public key.
    ///
    func verifySignature(with publicKey: SecKey, dataToSign: Data, digestType: SecurityDigestType) throws -> Bool {
        let signedCFData = dataToSign.cfData
        
        let signatureCFData = self.cfData
        
        let alg = signAlgorithm(for: digestType)
        var error: Unmanaged<CFError>?

        return SecKeyVerifySignature(publicKey, alg, signedCFData, signatureCFData, &error)
    }
    
    
    /// Get the length of padding according to given algorithm
    ///
    /// - Parameter alg: One of SecKeyAlgorithm constants
    /// - Returns: the length of padding
    private func paddingLength(for alg: SecKeyAlgorithm) -> Int {
        switch alg {
        case SecKeyAlgorithm.rsaEncryptionPKCS1:
            return 11
        case SecKeyAlgorithm.rsaEncryptionOAEPSHA1:
            return 42
        default:
            return 0
        }
    }
    
    /// Check the length of this Data which representing a diggest.
    ///
    /// - Parameter digestType: a diggest type. reference to 'SecurityDigestType'
    /// - Returns: true if the length of this data is equals to the length of given digest type. else return false.
    ///
    private func isValidLength(for digestType: SecurityDigestType) -> Bool {
        let length = self.count
        switch digestType {
        case .SHA1:
            return CC_SHA1_DIGEST_LENGTH == length
        case .SHA224:
            return CC_SHA224_DIGEST_LENGTH == length
        case .SHA256:
            return CC_SHA256_DIGEST_LENGTH == length
        case .SHA384:
            return CC_SHA384_DIGEST_LENGTH == length
        case .SHA512:
            return CC_SHA512_DIGEST_LENGTH == length
        }
    }
    
    /// Return a RSA sign algorithm which is type of 'SecKeyAlgorithm' with given diggest type
    /// 
    /// - Parameter digestType: a diggest type. reference to 'SecurityDigestType'
    /// - Returns: a kind of 'SecKeyAlgorithm'
    ///
    private func signAlgorithm(for digestType: SecurityDigestType) -> SecKeyAlgorithm {
        switch digestType {
        case .SHA1:
            return .rsaSignatureDigestPKCS1v15SHA1
        case .SHA224:
            return .rsaSignatureDigestPKCS1v15SHA224

        case .SHA256:
            return .rsaSignatureDigestPKCS1v15SHA256
        case .SHA384:
            return .rsaSignatureDigestPKCS1v15SHA384
        case .SHA512:
            return .rsaSignatureDigestPKCS1v15SHA512
        }
    }
    
}
