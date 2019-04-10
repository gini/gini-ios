//
//  Client.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import Foundation

public struct Client {
    public var domain: String
    public var id: String
    public var secret: String
    
    public init(id: String, secret: String, domain: String) {
        self.id = id
        self.secret = secret
        self.domain = domain
    }
}
