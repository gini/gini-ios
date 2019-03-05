//
//  User.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

struct User: Credentials, Codable {
    let password: String
    var id: String
    
    init(email: String, password: String) {
        self.id = email
        self.password = password
    }

}
