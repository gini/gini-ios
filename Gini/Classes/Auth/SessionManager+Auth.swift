//
//  SessionManager+Auth.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/6/19.
//

import Foundation

extension SessionManager: SessionAuthenticationProtocol {
    
    var client: Client {
        guard let id = self.keyStore.fetch(service: .auth, key: .clientId),
            let password = self.keyStore.fetch(service: .auth, key: .clientPassword),
            let domain = self.keyStore.fetch(service: .auth, key: .clientDomain) else {
                preconditionFailure("There should always be a client stored")
        }
        
        return Client(id: id, password: password, domain: domain)
    }
    
    var user: User? {
        guard let email = self.keyStore.fetch(service: .auth, key: .userEmail),
            let password = self.keyStore.fetch(service: .auth, key: .userPassword) else { return nil }
        
        return User(email: email, password: password)
    }
    
    func logIn(completion: @escaping (Result<Void>) -> Void) {
        if let user = user {
            login(user, completion: completion)
        } else {
            fetchClientAccessToken { result in
                switch result {
                case .success:
                    let domain = self.keyStore.fetch(service: .auth, key: .clientDomain) ?? "no-domain-specified"
                    let user = AuthHelper.generateUser(with: domain)
                    self.create(user) { result in
                        switch result {
                        case .success:
                            self.login(user, completion: completion)
                        case .failure:
                            completion(result)
                        }
                    }
                case .failure:
                    completion(result)
                }
            }
        }
    }
    
    func logOut() {
        keyStore.removeAll()
    }
}

// MARK: - Fileprivate

fileprivate extension SessionManager {
    func create(_ user: User,
                completion: @escaping (Result<Void>) -> Void) {
        let resource = UserResource<String>(method: .users, httpMethod: .post, body: try? JSONEncoder().encode(user))
        
        load(resource: resource) { result in
            switch result {
            case .success:
                do {
                    try self.keyStore.save(item: KeychainManagerItem(key: .userEmail,
                                                                     value: user.email,
                                                                     service: .auth))
                    try self.keyStore.save(item: KeychainManagerItem(key: .userPassword,
                                                                     value: user.password,
                                                                     service: .auth))
                    completion(.success(()))
                } catch {
                    preconditionFailure("Gini couldn't safely save the user credentials in the Keychain. " +
                        "Enable the 'Keychain Sharing' entitlement in your app")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func login(_ user: User,
               completion: @escaping (Result<Void>) -> Void) {
        let body = "username=\(user.id)&password=\(user.password)"
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?
            .data(using: .utf8)
        
        let resource = UserResource<Token>(method: .token(grantType: .password), httpMethod: .post, body: body)
        load(resource: resource) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                do {
                    try self.keyStore.save(item: KeychainManagerItem(key: .userAccessToken,
                                                                     value: token.accessToken,
                                                                     service: .auth))
                    completion(.success(()))
                } catch {
                    preconditionFailure("Gini couldn't safely save the user credentials in the Keychain. " +
                        "Enable the 'Keychain Sharing' entitlement in your app")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchClientAccessToken(completion: @escaping (Result<Void>) -> Void) {
        let resource = UserResource<Token>(method: .token(grantType: .clientCredentials), httpMethod: .get)
        load(resource: resource) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                do {
                    try self.keyStore.save(item: KeychainManagerItem(key: .clientAccessToken,
                                                                     value: token.accessToken,
                                                                     service: .auth))
                    completion(.success(()))
                } catch {
                    preconditionFailure("Gini couldn't safely save the user credentials in the Keychain. " +
                        "Enable the 'Keychain Sharing' entitlement in your app")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
