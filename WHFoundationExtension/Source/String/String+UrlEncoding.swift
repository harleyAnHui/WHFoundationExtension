//
//  String+UrlEncoding.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/15.
//

import Foundation

extension String {
    
    /// Create a 'URL' from this 'String'
    ///
    /// Returns nil if the string doesn’t represent a valid URL. For example, an empty string or one containing characters that are illegal in a URL produces nil.
    ///
    public var asURL: URL? {
        return URL(string: self)
    }
    
    /// Returns a new string made from the receiver by replacing all characters not in the allowedCharacters set with percent encoded characters.
    ///
    /// - Returns: a string encoded by calling 'addingPercentEncoding(withAllowedCharacters:)', or nil if this string can't be percent-encoded.
    ///
    public func urlEncoding() -> String? {
        guard let (scheme, host, port, path, query, anchor) = URLcomponents() else {
            return nil
        }
        
        guard let enccodedHost = host.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) else {
            return nil
        }
        
        var encodedPort = ""
        if port != nil {
            encodedPort = ":" + port!
        }
        
        var enccodedPath = ""
        if path != nil {
            guard let tmp = path!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else {
                return nil
            }
            enccodedPath = tmp
        }
        
        var encodedQuery = ""
        if query != nil {
            guard let tmp = query!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                return nil
            }
            encodedQuery = "?" + tmp
        }
        
        var encodedAnchor = ""
        if anchor != nil {
            guard let tmp = anchor!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) else {
                return nil
            }
            encodedAnchor = "#" + tmp
        }

        return  scheme + enccodedHost + encodedPort + enccodedPath + encodedQuery + encodedAnchor
    }
    
    
    /// This method parses and constructs URLComponents according to RFC 3986.
    ///
    ///     let urlString = http://www.aspxfans.com:8080/news/index.asp?boardID=5&ID=24618&page=1#name
    ///     let (scheme, host, port, path, query, anchor) = urlString.URLcomponents()
    ///
    /// - Returns: a Tuple contains url components such as scheme, host, port, path, query and anchor.
    ///
    /// reference to: https://zhuanlan.zhihu.com/p/58479085
    ///
    public func URLcomponents() -> (scheme: String, host: String, port: String?, path: String?, query: String?, anchor: String?)? {
        guard let schemeRange = self.range(of: "://") else { return nil }
        
        let scheme = String(self[..<schemeRange.upperBound])
        var host: String?
       
        if  let pathRange = self.range(of: "/", options: [], range: schemeRange.upperBound..<self.endIndex) {
            host = String(self[schemeRange.upperBound..<pathRange.lowerBound])
        } else {
            if let queryRange = self.range(of: "?", options: [], range: schemeRange.upperBound..<self.endIndex) {
                host = String(self[schemeRange.upperBound..<queryRange.lowerBound])

            } else {
                if let anchorRange = self.range(of: "#", options: [], range: schemeRange.upperBound..<self.endIndex) {
                    host = String(self[schemeRange.upperBound..<anchorRange.lowerBound])
                } else {
                    host = String(self[schemeRange.upperBound...])
                }
            }
        }
        
        guard let matched = host, let hostRange = self.range(of: matched, options: [], range: schemeRange.upperBound..<self.endIndex) else {
            return nil
        }
        
        var port: String?
        if let portRange = host!.range(of: ":") {
            port = String(host![portRange.upperBound...])
            host = String(host![..<portRange.lowerBound])
        }
        
        var currentRange = hostRange
        var path: String?
        if let pathRange = self.range(of: "/", options: [], range: currentRange.upperBound..<self.endIndex) {
            if let queryRange = self.range(of: "?", options: [], range: pathRange.upperBound..<self.endIndex) {
                path = String(self[pathRange.lowerBound..<queryRange.lowerBound])
            } else {
                if let anchorRange = self.range(of: "#", options: [], range: pathRange.upperBound..<self.endIndex) {
                    path = String(self[pathRange.lowerBound..<anchorRange.lowerBound])
                } else {
                    path = String(self[pathRange.lowerBound...])
                }

            }
        }
        
        if let macthed = path, let range = self.range(of: macthed, options: [], range: currentRange.upperBound..<self.endIndex) {
            currentRange = range
        }
        var query: String?
        if let queryRange = self.range(of: "?", options: [], range: currentRange.upperBound..<self.endIndex) {
            if let anchorRange = self.range(of: "#", options: [], range: queryRange.upperBound..<self.endIndex) {
                query = String(self[queryRange.upperBound..<anchorRange.lowerBound])
            } else {
                query = String(self[queryRange.upperBound...])
            }
        }
        
        
        if let macthed = query, let range = self.range(of: macthed, options: [], range: currentRange.upperBound..<self.endIndex) {
            currentRange = range
        }
        var anchor: String?
        if let anchorRange = self.range(of: "#", options: [], range: currentRange.upperBound..<self.endIndex) {
            anchor = String(self[anchorRange.upperBound...])
        }
        
        return (scheme, host!, port, path, query, anchor)
    }
    
}
