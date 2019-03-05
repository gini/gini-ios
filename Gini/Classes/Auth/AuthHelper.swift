//
//  AuthHelper.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/4/19.
//

import Foundation

final class AuthHelper {
    
    enum AuthHeaderType: String {
        case basic = "Basic"
        case bearer = "BEARER"
    }
    
    static func authorizationHeader(for accessToken: String, headerType: AuthHeaderType) -> HTTPHeader {
        return ("Authorization", "\(headerType.rawValue) \(accessToken)")
    }
        
    static func isTokenStillValid(keyStore: KeyStore) -> Bool {
        guard let expirationDateString = keyStore.fetch(service: .auth, key: .expirationDate),
            let expirationDate = DateFormatter().date(from: expirationDateString) else { return false }
        
        return Date() < expirationDate
    }
    
    static func encoded(credentials: Credentials) -> String {
        let credentials = "\(credentials.id):\(credentials.password)"
        let credData = credentials.data(using: .utf8)
        return "\(credData?.base64EncodedString() ?? "")"
    }
}
