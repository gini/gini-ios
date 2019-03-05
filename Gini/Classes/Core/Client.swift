//
//  Client.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import Foundation

struct Client: Credentials {
    var id: String
    var password: String
    
    init(id: String, password: String) {
        self.id = id
        self.password = password
    }
}
