//
//  AccessToken.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

final class Token {
    
    var expiration: Date
    var scope: String
    var type: String
    var accessToken: String
    var refreshToken: String?
    
    init(expiration: Date, scope: String, type: String, accessToken: String, refreshToken: String?) {
        self.expiration = expiration
        self.scope = scope
        self.type = type
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    enum Keys: String, CodingKey {
        case expiresIn = "expires_in"
        case scope
        case type = "token_type"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }

}

extension Token: Decodable {
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let expiresIn = try container.decode(Double.self, forKey: .expiresIn) // seconds
        let expiration = Date(timeInterval: expiresIn, since: Date())
        let scope = try container.decode(String.self, forKey: .scope)
        let type = try container.decode(String.self, forKey: .type)
        let accessToken = try container.decode(String.self, forKey: .accessToken)
        let refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)

        self.init(expiration: expiration,
                  scope: scope,
                  type: type,
                  accessToken: accessToken,
                  refreshToken: refreshToken)

    }
}
