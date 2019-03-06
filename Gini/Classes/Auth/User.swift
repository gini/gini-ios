//
//  User.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

struct User: Credentials, Codable {
    let password: String
    let email: String
    var id: String {
        return email
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

}
