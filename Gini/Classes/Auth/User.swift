//
//  User.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

struct User: Encodable {
    
    let email: String
    let password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

}

extension User: Credentials {
    
    init(id: String, password: String) {
        self.init(email: id, password: password)
    }
    
    var id: String {
        return email
    }
    
    static var service: String {
        return "UserService"
    }
}
