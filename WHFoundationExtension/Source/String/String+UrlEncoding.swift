//
//  String+UrlEncoding.swift
//  WHFoundationExtension
//
//  Created by wangwenhui on 2022/4/15.
//

import Foundation

extension String {
    var asURL: URL? {
        return URL(string: self)
    }
    
    func encode() -> String? {
        guard let url = self.asURL else {
            return nil
        }
        
        guard var _ = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        
        return  escape(query: self)
    }
    
    func escape(query: String) -> String {
        var allowedCharactersWithSpace: CharacterSet = CharacterSet.urlQueryAllowed
        allowedCharactersWithSpace.insert(charactersIn: " ")
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: allowedCharactersWithSpace) ?? query

        return escapedQuery
    }
    
    func unescape() -> String? {
        return nil
    }
}
