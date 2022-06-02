# <font face="微软雅黑" >WHFoundationExtension</font>

WHFoundationExtension is an extension of Foundation framework written in Swift.

- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#Usage)
- [License](#license)

## Features

- [x] Create a UInt from Data with given byte ordering
- [x] Conversion between Date and String
- [x] Conversion between Dictionary and String
- [x] URL Encoding
- [x] Base-64 encoding or decoding support
- [x] Conversion between Data and hexadecimal string
- [x] Create or parse a SecCertificate in a convinence way
- [x] Generate hash for Data with a hashing algorithm, SHA1,SHA224...
- [x] Symmetric encryption support
- [x] RSA support, such as generating a key pair, encryption and Signature


## Requirements

| Platform | Minimum Swift Version | Installation | Status |
| --- | --- | --- | --- |
| iOS 13.0+ | 5.1 | [CocoaPods](#cocoapods), [Swift Package Manager](#swift-package-manager), [Manual](#manually) | Fully Tested |


## Communication

- If you **found a bug**, open an issue here on GitHub and follow the guide. The more detail the better!
- If you **want to contribute**, submit a pull request!

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate WHFoundationExtension into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'WHFoundationExtension', '~> 0.0.4'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but WHFoundationExtension does support its use on supported platforms.

Once you have your Swift package set up, adding WHFoundationExtension as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/harleyAnHui/WHFoundationExtension.git", .upToNextMajor(from: "0.0.4"))
]
```

### Manually

If you prefer not to use any of the above mentioned dependency managers, you can integrate WHFoundationExtension into your project manually.


## Usage

Create a UInt from Data with given byte ordering

```swift
let data = Data([0x15, 0xa3, 0xbc, 0xff])
let value = UInt16(data: data, offset: 1) // value is 0xa3bc
let lData = value.data(bigEndian: false) // lData is [0xbc, 0xa3]
        
```

Conversion between Date and String

```swift
let dateString = "2022-05-06 10:56:00"
let date = dateString.date()
let string = date.string()
        
```

Create or parse a SecCertificate

```swift
let testBundle = Bundle(for: type(of: self))
let path = testBundle.path(forResource: "DeveloperCertification", ofType: ".cer")
do {
     let cert = try SecCertificate.create(contentOf: path!)
     let subjet = cert?.subjectSummary
     let serialNumber = cert?.serialNumber
     let publicKey = cert?.publicKey
} catch  {
     print(error)
}
        
```

Generate hash value for Data

Symmetric encryption


```swift
let data = Data([0x31, 0x32, 0x33, 0x34])
do {
	/// Generate hash value for Data
	let sha1 = try data.digest(using: SecurityDigestType.SHA1)
	
	/// Encrypt or Decrypt
	let plain = "0123456789".data(using: .utf8)!
	let key16 = "0123456789abcedf".data(using: .utf8)!
	let iv16 = "0123456789abcedf".data(using: .utf8)!
	let encoded = try plain.encrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.CFB, padding: SecurityPadding.ISO7816Padding, key: key16, iv: iv16)
	let decoded = try encoded.decrypt(alg: SecurityAlgorithm.AES, mode: SecurityMode.CFB, padding: SecurityPadding.ISO7816Padding, key: key16, iv: iv16)
   
} catch {
	print(error)
}
        
```

RSA support


```swift
do {
   /// Create RSA Key pair
   let (publicSecKey, privateSecKey) = try Data.createRSAKeyPair(2048)
   let plain = "995614A05501D98C52B80BF57DF1837CCF74C019E125FDD4A8245DA9CF6FC6F357BEC04E9DBD7E802E10FF94CB3E6F7DF442B027F0DE07432C701D9F08ADB3A3BEDF71AD325A4FF7F61D7430559806E6F615FF756038BD0868D8BCC5BD41C375831ECE4D489E9EECD66E0952BEA1B9947BE86B20AE985029BA357E0FBDE1CE41".data(using: .utf8)
   let cipher = try plain?.encrypt(with: publicSecKey)
   let decrpt = try cipher?.decrpt(with: privateSecKey)
   
   /// Sign and Verify
   let plainDigest = try plain?.digest(using: SecurityDigestType.SHA256)
   var signature = try plainDigest?.signature(with: privateSecKey, digestType: SecurityDigestType.SHA256)
   let successful = try signature!.verifySignature(with: publicSecKey, dataToSign: plainDigest!, digestType: SecurityDigestType.SHA256)
   
} catch {
	print(error)
}
        
```



## License

WHFoundationExtension is released under the MIT license. [See LICENSE](https://github.com/harleyAnHui/WHFoundationExtension/blob/main/LICENSE) for details.

