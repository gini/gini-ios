//
//  Client.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import Foundation

struct Client: Credentials {
    var domain: String
    var id: String
    var password: String
    
    init(id: String, password: String, domain: String) {
        self.id = id
        self.password = password
        self.domain = domain
    }
}
