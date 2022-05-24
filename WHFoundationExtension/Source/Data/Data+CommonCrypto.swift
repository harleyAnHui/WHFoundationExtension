//
//  Data+Security.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/15.
//

import Foundation
import CommonCrypto

enum SecurityError: Error {
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
    
    case InvalidParams
    case CryptStatusCreateError
    case CryptStatusUpdateError
    case CryptStatusFinalError
    case ivLengthError
    case keyLengthError

}


/// <#Description#>
enum SecurityDigestType {
    case SHA1
    case SHA224
    case SHA256
    case SHA384
    case SHA512
}

enum SecurityAlgorithm {
    case DES  //kCCAlgorithmDES
    case TriDES //kCCAlgorithm3DES
    case AES //kCCAlgorithmAES
    case CAST //kCCAlgorithmCAST
    case RC4 //kCCAlgorithmRC4
    case RC2 //kCCAlgorithmRC2
    case Blowfish //kCCAlgorithmBlowfish
    
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
}

enum SecurityMode {
    case EBC //Reference to kCCModeECB - Electronic Code Book Mode.
    case CBC //Reference to kCCModeCBC - Cipher Block Chaining Mode.
    case CFB //Reference to kCCModeCFB - Output Feedback Mode.
    case OFB //Reference to kCCModeOFB - Output Feedback Mode.
    case RC4 //Reference to kCCModeRC4 - RC4 as a streaming cipher is handled internally as a mode.
    case CFB8 //Reference to kCCModeCFB8 - Cipher Feedback Mode producing 8 bits per round.

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

enum SecurityPadding {
    case NoPadding    //即不填充，要求明文的长度，必须是加密算法分组长度的整数倍
    case PKCS7Padding //PKCS#5和PKCS#7, 在填充字节序列中，每个字节填充为需要填充的字节长度
    case ISO7816Padding //ISO/IEC 7816-4, 在填充字节序列中，第一个字节填充固定值80，其余字节填充0。若只需填充一个字节，则直接填充80
    case ZeroPadding    //在填充字节序列中，每个字节填充为0
    case ANSIPadding   //ANSI X9.23 , 在填充字节序列中，最后一个字节填充为需要填充的字节长度，其余字节填充0
    case ISO10126Padding //ISO 10126, 在填充字节序列中，最后一个字节填充为需要填充的字节长度，其余字节填充随机数
}

/// https://github.com/cocoajin/Security-iOS
/// Reference to https://juejin.cn/post/6844903872905871367
extension Data {
    
    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    func digest(using type: SecurityDigestType) throws -> Data {
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
    
    private func SHA1() throws -> Data {
        var ctx = CC_SHA1_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))

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
        
        updatePointer.deallocate()
        finalPointer.deallocate()
        
        return data
    }
    
    private func SHA224() throws -> Data {
        var ctx = CC_SHA256_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA224_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA224_DIGEST_LENGTH))

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
        
        updatePointer.deallocate()
        finalPointer.deallocate()
        
        return data
    }
    
    private func SHA256() throws -> Data {
        var ctx = CC_SHA256_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

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
        
        updatePointer.deallocate()
        finalPointer.deallocate()
        
        return data
    }
    
    private func SHA384() throws -> Data {
        var ctx = CC_SHA512_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA384_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA384_DIGEST_LENGTH))

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
        
        updatePointer.deallocate()
        finalPointer.deallocate()
        
        return data
    }
    
    private func SHA512() throws -> Data {
        var ctx = CC_SHA512_CTX()
        let updatePointer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(self.count))
        updatePointer.initialize(repeating: 0)
        let length = self.copyBytes(to: updatePointer)
        let finalPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA512_DIGEST_LENGTH))
        finalPointer.initialize(repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))

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
        
        updatePointer.deallocate()
        finalPointer.deallocate()
        
        return data
    }
    
    func encrypt(alg: SecurityAlgorithm, mode: SecurityMode, padding: SecurityPadding, key: Data, iv: Data) throws -> Data {
        
        return try crypt(op: CCOperation(kCCEncrypt), alg: alg.ccAlgorithm, mode: mode.ccMode, padding: padding, key: key, iv: iv)
    }
    
    func decrypt(alg: SecurityAlgorithm, mode: SecurityMode, padding: SecurityPadding, key: Data, iv: Data) throws -> Data {

        return try crypt(op: CCOperation(kCCDecrypt), alg: alg.ccAlgorithm, mode: mode.ccMode, padding: padding, key: key, iv: iv)
    }
    
    private func crypt(op: CCOperation, alg: CCAlgorithm, mode: CCMode, padding: SecurityPadding, key: Data, iv: Data) throws -> Data {
        
        guard check(ivLength: iv.count, for: alg) else {
            throw SecurityError.ivLengthError
        }
        
        guard check(keyLength: key.count, for: alg) else {
            throw SecurityError.keyLengthError
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
        
        var cryptStatus = CCCryptorCreateWithMode(op, mode, alg, CCPadding(ccNoPadding), ivPointer.baseAddress , keyPointer.baseAddress, keyLength, nil, 0, 0, CCModeOptions(kCCModeOptionCTR_BE), &cryptor)
        guard cryptStatus == kCCSuccess else {
            throw SecurityError.CryptStatusCreateError
        }

        let outputLength = CCCryptorGetOutputLength(cryptor, updateLength, true)
        let dataOutPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputLength)
        dataOutPointer.initialize(repeating: 0, count: outputLength)
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
        
        updatePointer.deallocate()
        keyPointer.deallocate()
        dataOutPointer.deallocate()
        ivPointer.deallocate()
        
        return cipherData
    }

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
