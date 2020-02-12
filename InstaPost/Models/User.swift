//
//  User.swift
//  InstaPost
//
//  Created by Saumil Shah on 2/11/20.
//  Copyright © 2020 Saumil Shah. All rights reserved.
//

import Foundation

struct User: Codable {
    
    private let firstname: String
    private let lastname: String
    private let nickname: String
    private let email: String
    private let password: String
    
    init(firstname: String, lastname: String, nickname: String, email: String, password: String) {
        
        self.firstname = firstname
        self.lastname = lastname
        self.nickname = nickname
        self.email = email
        self.password = password
        
    }
    
    func getEmail() -> String {
        return self.email
    }
    
    func getPassword() -> String {
        return self.password
    }
    
    func encodeToJSON() -> Data? {
        
        return try? JSONEncoder().encode(self)
    }
}

func getCredentialURL(email:String, password: String) -> String {
    return "email="+email.replacingOccurrences(of: "@", with: "%40") + "&" + "password="+password
}


struct UserCredentials {
    
    let email: String
    let password: String
    
    var isEmpty: Bool {
        return email.isEmpty || password.isEmpty
    }
    
    init() {
        self.init(email: "", password: "")
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
}


extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
