//
//  SecCertificate+Basic.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/23.
//


import Foundation
import Security

/**
    @extension SecCertificate,  representing a X.509 certificate.
    See SecCertificate.h for details.
*/
extension SecCertificate {
    
    /// Create a Ceritficate with given content of a file
    ///
    /// - Parameter path: The 'Path' to read
    /// - Returns: a instance of SecCertificate or nil on failure
    /// - Throws: an error in the Cocoa domain, if 'path' can't read.
    ///
    public static func create(contentOf path: String) throws -> SecCertificate? {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return create(with: data)
    }
    
    
    /// Create a Ceritficate given it's DER representation as a Data
    ///
    /// - Parameter data: DER representation as a Data
    /// - Returns: a instance of SecCertificate or nil on failure
    ///
    public static func create(with data: Data) -> SecCertificate? {
        let cfData = data as CFData
        return SecCertificateCreateWithData(kCFAllocatorDefault, cfData)
    }
    
    /// Return a 'Data' which is the DER representation of an X.509 certificate.
    ///
    var data: Data {
        return SecCertificateCopyData(self) as Data
    }
    
    /// Return a simple string which hopefully represents a human understandable summary.
    ///
    /// Return nil on failure.
    ///
    public var subjectSummary: String? {
        ///'self', a reference to the certificate from which to derive the subject summary string.
        return SecCertificateCopySubjectSummary(self) as? String
    }
    
    /// Return a common name of subject
    ///
    /// Return nil on failure.
    ///
    public var subjectCommonName: String? {
        let pointer = UnsafeMutablePointer<CFString?>.allocate(capacity: 8)
        defer {
            pointer.deallocate()
        }
        
        let status = SecCertificateCopyCommonName(self, pointer)
        guard status == 0 else {
            return nil
        }
        
        return pointer.pointee as? String
    }
    
    /// Return a string array in which each element is  an email address.
    ///
    /// Return nil on failure or no any email address in the certification.
    ///
    public var emailAddresses: [String]? {
        let pointer = UnsafeMutablePointer<CFArray?>.allocate(capacity: 32)
        defer {
            pointer.deallocate()
        }
        
        let status = SecCertificateCopyEmailAddresses(self, pointer)
        guard status == 0 else {
            return nil
        }
        
        guard let cfArray = pointer.pointee else {
            return nil
        }
        
        let count = CFArrayGetCount(cfArray)
        guard count != 0 else {
            return nil
        }
        
        var emails: Array<String>? = []
        for i in 0..<count {
            let valuePointer = CFArrayGetValueAtIndex(cfArray, i)
            let safePointer = unsafeBitCast(valuePointer, to: UnsafePointer<UInt8>.self)
            let value = String(cString: safePointer)
            emails?.append(value)
        }
        
        return emails
    }
    
    /// Return the certificate's normalized issuer
    ///
    /// The content returned is a DER-encoded X.509 distinguished name
    ///
    public var issuer: Data? {
        guard let cfData = SecCertificateCopyNormalizedIssuerSequence(self) else {
            return nil
        }
        
        let data = cfData as Data
        return data
        
    }
    
    /// Return the certificate's normalized subject
    ///
    ///The content returned is a DER-encoded X.509 distinguished name
    ///
    public var subject: Data? {
        guard let cfData = SecCertificateCopyNormalizedSubjectSequence(self) else {
            return nil
        }
        
        let data = cfData as Data
        return data
        
    }
    
    /// Retrieves the public key from this certificate.
    ///
    public var publicKey: SecKey? {
        guard let key = SecCertificateCopyKey(self) else {
            return nil
        }
        
        return key
        
    }
    
    /// Return the certificate's serial number.
    ///
    public var serialNumber: String? {
        let error: UnsafeMutablePointer<Unmanaged<CFError>?> = UnsafeMutablePointer<Unmanaged<CFError>?>.allocate(capacity: 8)
        defer {
            error.deallocate()
        }
        
        guard let cfData = SecCertificateCopySerialNumberData(self, error) else {
            return nil
        }
        
        let data = cfData as Data
        guard data.count <= 8 else {
            return nil
        }
        
        var paddedData = [UInt8](repeating: 0, count: 8)
        for i in 0..<data.count {
            paddedData[i] = data[i]
        }
        paddedData.reverse()
        let value: UInt64 = paddedData.withUnsafeBytes { $0.load(as: UInt64.self) }
        
        return value.description
        
    }
}
