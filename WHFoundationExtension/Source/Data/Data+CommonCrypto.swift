//
//  Data+Security.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/15.
//

import Foundation
import CommonCrypto

/// `SecurityError` is the error type.
public enum SecurityError: Error {
    case CC_SHA1_Init_Error
    case CC_SHA1_Update_Error
    case CC_SHA1_Final_Error
    
    case CC_SHA224_Init_Error
    case CC_SHA224_Update_Error
    case CC_SHA224_Final_Error
    
    case CC_SHA256_Init_Error
    case CC_SHA256_Update_Error
    case CC_SHA256_Final_Error
    
    case CC_SHA384_Init_Error
    case CC_SHA384_Update_Error
    case CC_SHA384_Final_Error
    
    case CC_SHA512_Init_Error
    case CC_SHA512_Update_Error
    case CC_SHA512_Final_Error
        
    case CryptStatusCreateError
    case CryptStatusUpdateError
    case CryptStatusFinalError
    
    case InvalidParams
    case CryptAlgorithmNotSupported
    
}

/// The Digest Algorithm Type
public enum SecurityDigestType {
    /// Secure Hash Algorithm 1,  is a mechanism for message digesting, following the Secure Hash Algorithm with a 160-bit message digest
    case SHA1
    /// The SHA-224 mechanism, is a mechanism for message digesting, following the Secure Hash Algorithm with a 224-bit message digest
    case SHA224
    /// The SHA-256 mechanism, is a mechanism for message digesting, following the Secure Hash Algorithm with a 256-bit message digest
    case SHA256
    /// The SHA-384 mechanism, is a mechanism for message digesting, following the Secure Hash Algorithm with a 384-bit message digest
    case SHA384
    /// The SHA-512 mechanism, is a mechanism for message digesting, following the Secure Hash Algorithm with a 512-bit message digest
    case SHA512
}

/// Encryption algorithms
///
/// These are symmetric-key algorithm
///
public enum SecurityAlgorithm {
    /// Data Encryption Standard, Reference to 'kCCAlgorithmDES'
    case DES
    /// Triple DES is a symmetric key-block cipher which applies the DES cipher in triplicate, Reference to 'kCCAlgorithm3DES'
    case TriDES
    /// Advanced Encryption Standard, 128-bit block. Reference to 'kCCAlgorithmAES'
    case AES
    case CAST //kCCAlgorithmCAST
    case RC4 //kCCAlgorithmRC4
    case RC2 //kCCAlgorithmRC2
    case Blowfish //kCCAlgorithmBlowfish
    
    /// Convert to CCAlgorithm
    var ccAlgorithm: CCAlgorithm {
        switch self {
        case .DES:
            return CCAlgorithm(kCCAlgorithmDES)
        case .TriDES:
            return CCAlgorithm(kCCAlgorithm3DES)
        case .AES:
            return CCAlgorithm(kCCAlgorithmAES)
        case .CAST:
            return CCAlgorithm(kCCAlgorithmCAST)
        case .RC4:
            return CCAlgorithm(kCCAlgorithmRC4)
        case .RC2:
            return CCAlgorithm(kCCAlgorithmRC2)
        case .Blowfish:
            return CCAlgorithm(kCCAlgorithmBlowfish)
        }
    }
    
    /// Return true if the algorithm is implemented, otherwise false.
    ///
    /// TODO: CAST, RC2, Blowfish not be supported.
    ///
    var isSupported: Bool {
        switch self {
        case .DES:
            fallthrough
        case .TriDES:
            fallthrough
        case .AES:
            fallthrough
        case .RC4:
            return true
        case .CAST:
            fallthrough
        case .RC2:
            fallthrough
        case .Blowfish:
            return false
        }
    }
}

public enum SecurityMode {
    case EBC //Reference to kCCModeECB - Electronic Code Book Mode.
    case CBC //Reference to kCCModeCBC - Cipher Block Chaining Mode.
    case CFB //Reference to kCCModeCFB - Cipher Feedback.
    case OFB //Reference to kCCModeOFB - Output Feedback Mode.
    case RC4 //Reference to kCCModeRC4 - RC4 as a streaming cipher is handled internally as a mode.
    case CFB8 //Reference to kCCModeCFB8 - Cipher Feedback Mode producing 8 bits per round.

    /// Convert to CCMode
    var ccMode: CCMode {
        switch self {
        case .EBC:
            return CCMode(kCCModeECB)
        case .CBC:
            return CCMode(kCCModeCBC)
        case .CFB:
            return CCMode(kCCModeCFB)
        case .OFB:
            return CCMode(kCCModeOFB)
        case .RC4:
            return CCMode(kCCModeRC4)
        case .CFB8:
            return CCMode(kCCModeCFB8)
        }
    }
}

public enum SecurityPadding {
    case NoPadding    //即不填充，要求明文的长度，必须是加密算法分组长度的整数倍
    case PKCS7Padding //PKCS#5和PKCS#7, 在填充字节序列中，每个字节填充为需要填充的字节长度
    case ISO7816Padding //ISO/IEC 7816-4, 在填充字节序列中，第一个字节填充固定值80，其余字节填充0。若只需填充一个字节，则直接填充80
    case ZeroPadding    //在填充字节序列中，每个字节填充为0
    case ANSIPadding   //ANSI X9.23 , 在填充字节序列中，最后一个字节填充为需要填充的字节长度，其余字节填充0
    case ISO10126Padding //ISO 10126, 在填充字节序列中，最后一个字节填充为需要填充的字节长度，其余字节填充随机数
}

extension Data {
    /// Gemerate a hash value for this 'Data', following the given digest type.
    /// - Parameter type: a digest type, see 'SecurityDigestType'
    /// - Returns: a hash value for this 'Data'.
    public func digest(using type: SecurityDigestType) throws -> Data {
        switch type {
        case .SHA1:
            return try SHA1()
        case .SHA224:
            return try SHA224()
        case .SHA256:
            return try SHA256()
        case .SHA384:
            return try SHA384()
        case .SHA512:
            return try SHA512()
        }
    }
    
    /// Produce a output of 160-bit hash value using SHA1
    ///
    /// - Returns: a 'Data' representing a hash value of this 'Data'
    /// - Throws: thow a SecurityError while hash function return fail status.
    ///
    private func SHA1() throws -> Data {
        var ctx = CC_SHA1_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        defer {
            updatePointer.deallocate()
            finalPointer.deallocate()
        }
        
        // Initialize the context.
        guard CC_SHA1_Init(&ctx) != 0 else {
            throw SecurityError.CC_SHA1_Init_Error
        }
        // Perform the hash.
        guard CC_SHA1_Update(&ctx, updatePointer.baseAddress, (CC_LONG)(length)) != 0 else {
            throw SecurityError.CC_SHA1_Update_Error
        }
        // Finalize the output.
        guard CC_SHA1_Final(finalPointer, &ctx) != 0 else {
            throw SecurityError.CC_SHA1_Final_Error
        }
                
        let data = Data(bytes: finalPointer, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        return data
    }
    
    /// Produce a output of 224-bit hash value using SHA-224
    ///
    /// - Returns: a 'Data' representing a hash value of this 'Data'
    /// - Throws: thow a SecurityError while hash function return fail status.
    ///
    private func SHA224() throws -> Data {
        var ctx = CC_SHA256_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA224_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA224_DIGEST_LENGTH))
        
        defer {
            updatePointer.deallocate()
            finalPointer.deallocate()
        }
        
        // Initialize the context.
        guard CC_SHA224_Init(&ctx) != 0 else {
            throw SecurityError.CC_SHA224_Init_Error
        }
        // Perform the hash.
        guard CC_SHA224_Update(&ctx, updatePointer.baseAddress, (CC_LONG)(length)) != 0 else {
            throw SecurityError.CC_SHA224_Update_Error
        }
        // Finalize the output.
        guard CC_SHA224_Final(finalPointer, &ctx) != 0 else {
            throw SecurityError.CC_SHA224_Final_Error
        }
                
        let data = Data(bytes: finalPointer, count: Int(CC_SHA224_DIGEST_LENGTH))
        
        return data
    }
    
    /// Produce a output of 256-bit hash value using SHA-256
    ///
    /// - Returns: a 'Data' representing a hash value of this 'Data'
    /// - Throws: thow a SecurityError  while hash function return fail status.
    ///
    private func SHA256() throws -> Data {
        var ctx = CC_SHA256_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        defer {
            updatePointer.deallocate()
            finalPointer.deallocate()
        }
        
        // Initialize the context.
        guard CC_SHA256_Init(&ctx) != 0 else {
            throw SecurityError.CC_SHA256_Init_Error
        }
        // Perform the hash.
        guard CC_SHA256_Update(&ctx, updatePointer.baseAddress, (CC_LONG)(length)) != 0 else {
            throw SecurityError.CC_SHA256_Update_Error
        }
        // Finalize the output.
        guard CC_SHA256_Final(finalPointer, &ctx) != 0 else {
            throw SecurityError.CC_SHA256_Final_Error
        }
                
        let data = Data(bytes: finalPointer, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        return data
    }
    
    /// Produce a output of 384-bit hash value using SHA-384
    ///
    /// - Returns: a 'Data' representing a hash value of this 'Data'
    /// - Throws: thow a SecurityError  while hash function return fail status.
    ///
    private func SHA384() throws -> Data {
        var ctx = CC_SHA512_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA384_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA384_DIGEST_LENGTH))
        defer {
            updatePointer.deallocate()
            finalPointer.deallocate()
        }
        
        // Initialize the context.
        guard CC_SHA384_Init(&ctx) != 0 else {
            throw SecurityError.CC_SHA384_Init_Error
        }
        // Perform the hash.
        guard CC_SHA384_Update(&ctx, updatePointer.baseAddress, (CC_LONG)(length)) != 0 else {
            throw SecurityError.CC_SHA384_Update_Error
        }
        // Finalize the output.
        guard CC_SHA384_Final(finalPointer, &ctx) != 0 else {
            throw SecurityError.CC_SHA384_Final_Error
        }
                
        let data = Data(bytes: finalPointer, count: Int(CC_SHA384_DIGEST_LENGTH))
        
        return data
    }
    
    /// Produce a output of 512-bit hash value using SHA-512
    ///
    /// - Returns: a 'Data' representing a hash value of this 'Data'
    /// - Throws: thow a SecurityError  while hash function return fail status.
    ///
    private func SHA512() throws -> Data {
        var ctx = CC_SHA512_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA512_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        defer {
            updatePointer.deallocate()
            finalPointer.deallocate()
        }
        
        // Initialize the context.
        guard CC_SHA512_Init(&ctx) != 0 else {
            throw SecurityError.CC_SHA512_Init_Error
        }
        // Perform the hash.
        guard CC_SHA512_Update(&ctx, updatePointer.baseAddress, (CC_LONG)(length)) != 0 else {
            throw SecurityError.CC_SHA512_Update_Error
        }
        // Finalize the output.
        guard CC_SHA512_Final(finalPointer, &ctx) != 0 else {
            throw SecurityError.CC_SHA512_Final_Error
        }
                
        let data = Data(bytes: finalPointer, count: Int(CC_SHA512_DIGEST_LENGTH))
    
        
        return data
    }
    
    
    /// Encrypt this 'Data' with given algorithm, cipher mode, padding type, key and iv
    ///
    ///
    /// - Parameters:
    ///   - alg: a type of Encryption Algorithm
    ///   - mode: a block cipher mode of operation
    ///   - padding: Specifies the padding to use
    ///   - key: a data representing raw key
    ///   - iv: Initialization vector, optional. Used by block ciphers
    /// - Returns: a cipher data
    /// - Throws: thow a SecurityError  while encryption failed.
    ///
    public func encrypt(alg: SecurityAlgorithm, mode: SecurityMode, padding: SecurityPadding, key: Data, iv: Data) throws -> Data {
        guard alg.isSupported else {
            throw SecurityError.CryptAlgorithmNotSupported
        }
        
        return try crypt(op: CCOperation(kCCEncrypt), alg: alg.ccAlgorithm, mode: mode.ccMode, padding: padding, key: key, iv: iv)
    }
    
    
    /// Decrypt this 'Data' with given algorithm, cipher mode, padding type, key and iv
    ///
    /// - Parameters:
    ///   - alg: a type of Encryption Algorithm
    ///   - mode: a block cipher mode of operation
    ///   - padding: Specifies the padding to use
    ///   - key: a data representing raw key
    ///   - iv: Initialization vector, optional. Used by block ciphers
    /// - Returns: a plain data
    /// - Throws: a SecurityError  while encryption failed.
    ///
    public func decrypt(alg: SecurityAlgorithm, mode: SecurityMode, padding: SecurityPadding, key: Data, iv: Data) throws -> Data {
        guard alg.isSupported else {
            throw SecurityError.CryptAlgorithmNotSupported
        }
        
        return try crypt(op: CCOperation(kCCDecrypt), alg: alg.ccAlgorithm, mode: mode.ccMode, padding: padding, key: key, iv: iv)
    }
    
    private func crypt(op: CCOperation, alg: CCAlgorithm, mode: CCMode, padding: SecurityPadding, key: Data, iv: Data) throws -> Data {

        guard check(ivLength: iv.count, for: alg) else {
            throw SecurityError.InvalidParams
        }
        
        guard check(keyLength: key.count, for: alg) else {
            throw SecurityError.InvalidParams
        }
        
        var cryptor: CCCryptorRef?
        
        var blockSize = 0
        var updateLength = self.count
        if isBlockEnryption(alg: alg) {
            blockSize = lengthOfPacket(for: alg)
            updateLength = blockSize * (self.count/blockSize + (self.count % blockSize == 0 ? 0 : 1))
        }
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: updateLength)
        updatePointer.initialize(repeating: 0)
        let _ = self.copyBytes(to: updatePointer)
        defer {
            updatePointer.deallocate()
        }
        
        if isBlockEnryption(alg: alg) {
            // Add padding if length is not enough.
            try addPadding(to: updatePointer, range: self.count..<updateLength, padding: padding)
        }
        
        let ivPointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(iv.count))
        ivPointer.initialize(repeating: 0)
        let _ = iv.copyBytes(to: ivPointer)

        let keyPointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(key.count))
        keyPointer.initialize(repeating: 0)
        let keyLength = key.copyBytes(to: keyPointer)
        
        defer {
            keyPointer.deallocate()
            ivPointer.deallocate()
        }
        
        var cryptStatus = CCCryptorCreateWithMode(op, mode, alg, CCPadding(ccNoPadding), ivPointer.baseAddress , keyPointer.baseAddress, keyLength, nil, 0, 0, CCModeOptions(kCCModeOptionCTR_BE), &cryptor)
        guard cryptStatus == kCCSuccess else {
            throw SecurityError.CryptStatusCreateError
        }

        let outputLength = CCCryptorGetOutputLength(cryptor, updateLength, true)
        let dataOutPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputLength)
        dataOutPointer.initialize(repeating: 0, count: outputLength)
        
        defer {
            dataOutPointer.deallocate()
        }
        
        var dataOutMoved: Int = 0
        cryptStatus = CCCryptorUpdate(cryptor, updatePointer.baseAddress, updateLength, dataOutPointer, outputLength, &dataOutMoved)
        guard cryptStatus == kCCSuccess else {
            throw SecurityError.CryptStatusUpdateError
        }
        var cipherData = Data(bytes: dataOutPointer, count: dataOutMoved)

        cryptStatus = CCCryptorFinal(cryptor, dataOutPointer, outputLength, &dataOutMoved)
        guard cryptStatus == kCCSuccess else {
            throw SecurityError.CryptStatusFinalError
        }
        
        cipherData.append(UnsafePointer(dataOutPointer), count: dataOutMoved)

        return cipherData
    }

    
    /// Check if this algorithm is block encryption algorithm.
    ///
    /// - Parameter alg: an Encyption algorithm
    /// - Returns: true if 'alg' belongs to block enryption algorithm. false otherwise
    /// 
    private func isBlockEnryption(alg: CCAlgorithm) -> Bool {
        let algInt: Int = Int(alg)

        switch algInt {
        case kCCAlgorithmAES:
            return true
        case kCCAlgorithm3DES:
            return true
        case kCCAlgorithmDES:
            return true

        default:
            return false
        }
    }
        
    /// Check if given ivLength is equal to the IV size of 'alg'
    /// 
    /// - Parameters:
    ///   - ivLength: the length of 'iv'
    ///   - alg: an Encryption Algorithm
    /// - Returns: true if the length of 'iv' is equal to the IV size of 'alg', false otherwise
    ///
    private func check(ivLength: Int, for alg: CCAlgorithm) -> Bool {
        let algInt: Int = Int(alg)

        switch algInt {
        case kCCAlgorithmAES: //AES-128, AES-192, AES-256
            return (ivLength == 16)
        case kCCAlgorithm3DES:
            return (ivLength == 16 || ivLength == 24)
        case kCCAlgorithmDES:
            return (ivLength == 8)
        case kCCAlgorithmRC4:
            return true

        default:
            return false
        }
    }
    
    /// Check if the given keyLength is appropriate for the assigned  algorithm.
    ///
    /// - Parameters:
    ///   - keyLength: the length of key
    ///   - alg: an Encryption Algorithm
    /// - Returns: true if keyLength is equal to the key length of 'alg', otherwise return false.
    ///
    private func check(keyLength: Int, for alg: CCAlgorithm) -> Bool {
        let algInt: Int = Int(alg)

        switch algInt {
        case kCCAlgorithmAES: //AES-128, AES-192, AES-256
            return (keyLength == 16 || keyLength == 24 || keyLength == 32)
        case kCCAlgorithm3DES:
            return (keyLength == 16 || keyLength == 24)
        case kCCAlgorithmDES:
            return (keyLength == 8)
        case kCCAlgorithmRC4:
            return (keyLength < 256) && (keyLength > 0)
        default:
            return false
        }
    }
    
    /// Return the block size of the given algorithm.
    ///
    ///  Return -1 if the given algorithm is not block encryption function.
    ///
    /// - Parameter alg:an Encryption Algorithm
    /// - Returns: Return the block size of the given algorithm
    ///
    private func lengthOfPacket(for alg: CCAlgorithm) -> Int {
        let algInt: Int = Int(alg)
        switch algInt {
        case kCCAlgorithmAES: //AES-128, AES-192, AES-256
            return 16
        case kCCAlgorithm3DES:
            fallthrough
        case kCCAlgorithmDES:
            return 8
        case kCCAlgorithmRC4:
            return -1
        default:
            assertionFailure()
        }
        
        return 0
    }
    
    
    /// Add padding to the assigned place of the buffer
    ///
    /// - Parameters:
    ///   - buffer: to be added padding
    ///   - range: The range of adding padding.
    ///   - padding: Specifies the padding to use
    ///
    private func addPadding(to buffer: UnsafeMutableBufferPointer<UInt8>, range: Range<Self.Index>, padding: SecurityPadding) throws {
        guard range.lowerBound < range.upperBound else {
            return
        }
        
        switch padding {
        case .NoPadding:
            assertionFailure()

        case .PKCS7Padding:
            let padSize = range.upperBound - range.lowerBound
            for index in range {
                buffer[index] = UInt8(padSize)
            }
        case .ISO7816Padding:
            buffer[range.lowerBound] = 0x80

            for index in (range.lowerBound + 1)..<range.upperBound {
                buffer[index] = 0
            }
            
        case .ZeroPadding:
            for index in range {
                buffer[index] = 0
            }
        case .ANSIPadding:
            let padSize = range.upperBound - range.lowerBound
            buffer[range.upperBound-1] = UInt8(padSize)
            
            for index in range.lowerBound..<range.upperBound-1 {
                buffer[index] = 0
            }
        case .ISO10126Padding:
            let padSize = range.upperBound - range.lowerBound
            buffer[range.upperBound-1] = UInt8(padSize)
            for index in range.lowerBound..<range.upperBound-1 {
                buffer[index] = UInt8(Int.random(in: 0...255))
            }
        }
    }
    
}
