//
//  Client.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import Foundation

struct Client {
    var domain: String
    var id: String
    var secret: String
    
    init(id: String, secret: String, domain: String) {
        self.id = id
        self.secret = secret
        self.domain = domain
    }
}
