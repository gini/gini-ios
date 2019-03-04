//
//  KeyStore.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

public protocol KeyStore: class {
    func fetch(service: KeychainService, key: KeychainKey) -> String?
    func remove(service: KeychainService, key: KeychainKey) throws
    func save(item: KeychainManagerItem) throws
    func removeAll()
}

public enum KeychainService: String {
    case auth
}

public enum KeychainKey: String {
    case accessToken
    case clientId
    case clientPassword
    case expirationDate
    case refreshToken
    case userId
    case userPassword
}

public struct KeychainManagerItem {
    let key: KeychainKey
    let value: String
    let service: KeychainService
}

public enum KeyStoreError: Error {
    case unhandledError(status: OSStatus)
}

final class KeychainStore: KeyStore {
    
    fileprivate let classValueKey = NSString(format: kSecClass)
    fileprivate let attributeAccountKey = NSString(format: kSecAttrAccount)
    fileprivate let valueDataKey = NSString(format: kSecValueData)
    fileprivate let classGenericPasswordKey = NSString(format: kSecClassGenericPassword)
    fileprivate let attributeServiceKey = NSString(format: kSecAttrService)
    fileprivate let matchLimitKey = NSString(format: kSecMatchLimit)
    fileprivate let returnDataKey = NSString(format: kSecReturnData)
    fileprivate let returnAttributes = NSString(format: kSecReturnAttributes)
    fileprivate let matchLimitOneKey = NSString(format: kSecMatchLimitOne)
    
    var accessGroup: String?
    
    public func fetch(service: KeychainService, key: KeychainKey) -> String? {
        var query = keychainQuery(with: service, key: key, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else { return nil }
        guard status == noErr else { return nil }
        
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                return nil
        }
        
        return password
    }
    
    public func remove(service: KeychainService, key: KeychainKey) throws {
        let query = keychainQuery(with: service, key: key, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else {
            throw KeyStoreError.unhandledError(status: status)
        }
    }
    
    public func save(item: KeychainManagerItem) throws {
        let encodedPassword = item.value.data(using: String.Encoding.utf8)!
        
        if fetch(service: item.service, key: item.key) != nil {
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            
            let query = keychainQuery(with: item.service, key: item.key, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else {  return }
        } else {
            var newItem = keychainQuery(with: item.service, key: item.key, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            guard status == noErr else { throw KeyStoreError.unhandledError(status: status) }
        }
        
    }
    
    public func removeAll() {
        let secItemClasses = [kSecClassGenericPassword,
                              kSecClassInternetPassword,
                              kSecClassCertificate,
                              kSecClassKey,
                              kSecClassIdentity]
        for secItemClass in secItemClasses {
            let dictionary = [kSecClass as String: secItemClass]
            SecItemDelete(dictionary as CFDictionary)
        }
    }
    
    fileprivate func keychainQuery(with service: KeychainService,
                                   key: KeychainKey? = nil,
                                   accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service.rawValue as AnyObject?
        
        if let key = key {
            query[kSecAttrAccount as String] = key.rawValue as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}
