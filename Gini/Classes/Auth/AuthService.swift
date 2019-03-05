//
//  AuthService.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

protocol AuthServiceProtocol: class {

    func basicAuthHeader(sessionManager: SessionManagerProtocol,
                         completion: @escaping (Result<HTTPHeader>) -> Void)
}

final class AuthService: AuthServiceProtocol {
    
    fileprivate let keyStore: KeyStore
    var accessToken: Token?
    var client: Client? {
        guard let id = self.keyStore.fetch(service: .auth, key: .clientId),
            let password = self.keyStore.fetch(service: .auth, key: .clientPassword) else { return nil }
        
        return Client(id: id, password: password)
    }

    var user: User? {
        guard let email = self.keyStore.fetch(service: .auth, key: .userEmail),
            let password = self.keyStore.fetch(service: .auth, key: .userPassword) else { return nil }
        
        return User(email: email, password: password)
    }
    
    init(keyStore: KeyStore = KeychainStore()) {
        self.keyStore = keyStore
    }
    
    func basicAuthHeader(sessionManager: SessionManagerProtocol, completion: @escaping (Result<HTTPHeader>) -> Void) {
        if let user = user {
            accessToken(from: user, sessionManager: sessionManager, completion: completion)
        } else if let client = client {
            let encodedCredentials = self.encodedCredentials(credentials: client)
            let header = generateBasicAuthHeader(withValue: encodedCredentials)
            completion(.success(header))
        } else {
            completion(.failure(.unauthorized))
        }
    }
    
    private func accessToken(from user: User,
                             sessionManager: SessionManagerProtocol,
                             completion: @escaping (Result<HTTPHeader>) -> Void) {
        login(asUser: user, sessionManager: sessionManager) { [weak self] result in
            switch result {
            case .success(let accessToken):
                let header: HTTPHeader? = self?.generateBasicAuthHeader(withValue: accessToken.accessToken)
                completion(.success(header!))
            case .failure:
                self?.obtainUserCenterToken(sessionManager: sessionManager) { result in
                    switch result {
                    case .success(let accessToken):
                        self?.create(user: user, withToken: accessToken, sessionManager: sessionManager) { result in
                            switch result {
                            case .success:
                                self?.accessToken(from: user, sessionManager: sessionManager, completion: completion)
                            case .failure:
                                completion(.failure(.unauthorized))
                            }
                        }
                    case .failure:
                        completion(.failure(.unauthorized))
                    }
                }
            }
        }
    }
    
    func create(user: User,
                withToken token: Token,
                sessionManager: SessionManagerProtocol,
                completion: @escaping (Result<Void>) -> Void) {
        let headers = ["Authorization": "BEARER " + token.accessToken,
                       "Accept": "application/json",
                       "Content-Type": "application/json"
        ]
        let body = try? JSONEncoder().encode(user)
        let requestParams = RequestParameters(method: .post,
                                              headers: headers,
                                              body: body)
        
        let resource = UserResource<Data>(method: .users, params: requestParams)
        
        sessionManager.load(resource: resource) { _ in
            completion(.success(()))
        }
    }
    
    func login(asUser user: User,
               sessionManager: SessionManagerProtocol,
               completion: @escaping (Result<Token>) -> Void) {
        let encodedCredentials = self.encodedCredentials(credentials: client!)
        let basicAuthHeader = generateBasicAuthHeader(withValue: encodedCredentials)
        
        let headers = [basicAuthHeader.key: basicAuthHeader.value,
                       "Accept": "application/json",
                       "Content-Type": "application/x-www-form-urlencoded"
        ]
        let body = ("username=" + user.id + "&password=" + user.password)
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?
            .data(using: .utf8)
        let requestParams = RequestParameters(method: .post,
                                              headers: headers,
                                              body: body)
        let resource = UserResource<Token>(method: .token(grantType: .password),
                                           params: requestParams)
        sessionManager.load(resource: resource, completion: completion)
    }
    
    func obtainUserCenterToken(sessionManager: SessionManagerProtocol,
                               completion: @escaping (Result<Token>) -> Void) {
        let encodedCredentials = self.encodedCredentials(credentials: client!)
        let basicAuthHeader = generateBasicAuthHeader(withValue: encodedCredentials)
        let headers = [basicAuthHeader.key: basicAuthHeader.value,
                       "Accept": "application/json"]
        let requestParams = RequestParameters(method: .get,
                                              headers: headers)
        let resource = UserResource<Token>(method: .token(grantType: .clientCredentials),
                                           params: requestParams)
        sessionManager.load(resource: resource, completion: completion)
    }
}

extension AuthService {
    
    fileprivate func generateBasicAuthHeader(withValue value: String) -> HTTPHeader {
        return ("Authorization", "Basic " + value)
    }
    
    fileprivate func encodedCredentials(credentials: Credentials) -> String {
        let credentials = "\(credentials.id):\(credentials.password)"
        let credData = credentials.data(using: .utf8)
        return "\(credData?.base64EncodedString() ?? "")"
    }
}
