//
//  AuthHelper.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/4/19.
//

import Foundation

final class AuthHelper {
    
    static func authorizationHeader(for accessToken: String) -> (key: String, value: String) {
        return ("Authorization", "Bearer \(accessToken)")
    }
        
    static func isTokenStillValid(keyStore: KeyStore) -> Bool {
        guard let expirationDateString = keyStore.fetch(service: .auth, key: .expirationDate),
            let expirationDate = DateFormatter().date(from: expirationDateString) else { return false }
        
        return Date() < expirationDate
    }
}
