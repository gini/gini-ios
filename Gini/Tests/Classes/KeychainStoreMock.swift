//
//  KeychainStoreMock.swift
//  GiniAPISDKExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import Foundation
@testable import GiniAPISDK

final class KeychainStoreMock: KeyStore {
    
    typealias FakeItem = (service: String, id: String, password: String)
    var fakeItems: [FakeItem] = []
    
    func fetch<T: Credentials>(service: String, id: String?) -> T? {
        var password: String?
        
        if let id = id {
            fakeItems.forEach { item in
                if item.service == service && item.id == id {
                    password = item.password
                }
            }
            
            if let password = password {
                return T.init(id: id, password: password)
            }
        }

        return nil
    }
    
    func remove(service: String, id: String) {
        let itemIndex: Int? = fakeItems.index { $0.service == service && $0.id == id }
        if let index = itemIndex {
            fakeItems.remove(at: index)
        }
    }
    
    func save<T: Credentials>(credentials: T) {
        fakeItems = fakeItems.filter { $0.service != T.service }
        let item = (T.service, credentials.id, credentials.password)
        fakeItems.append(item)
    }
    
    func update<T: Credentials>(newCredentials: T) {
        let itemIndex: Int? = fakeItems.index { $0.service == T.service && $0.id == newCredentials.id }
        if let index = itemIndex {
            let item = (T.service, newCredentials.id, newCredentials.password)
            fakeItems.remove(at: index)
            fakeItems.append(item)
        }
    }
    
}
