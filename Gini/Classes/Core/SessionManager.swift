//
//  SessionManager.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

public typealias CompletionResult<T> = (Result<T>) -> Void

public enum Result<T> {
    case success(T)
    case failure(GiniError)
}

protocol SessionAuthenticationProtocol: class {
    var isLoggedIn: Bool { get }
    
    func logIn(completion: @escaping (Result<Void>) -> Void)
    func logOut()
}

protocol SessionProtocol: class {
    
    init(keyStore: KeyStore, urlSession: URLSession)
    func load<T: Resource>(resource: T, completion: @escaping CompletionResult<T.ResponseType>)
}

typealias SessionManagerProtocol = SessionProtocol & SessionAuthenticationProtocol

final class SessionManager {
    
    static let shared: SessionManager = {
        let sessionManager = SessionManager(keyStore: KeychainStore())
        return sessionManager
    }()
    
    fileprivate let keyStore: KeyStore
    fileprivate let session: URLSession
    
    init(keyStore: KeyStore = KeychainStore(),
         urlSession: URLSession = .init(configuration: .default)) {
        self.keyStore = keyStore
        self.session = urlSession
    }
}

// MARK: - SessionProtocol

extension SessionManager: SessionProtocol {
    
    func load<T: Resource>(resource: T, completion: @escaping CompletionResult<T.ResponseType>) {
        if let authServiceType = resource.authServiceType {
            var value: String?
            var authType: AuthType?
            switch authServiceType {
            case .apiService:
                if AuthHelper.isTokenStillValid(expirationDateString: keyStore.fetch(service: .auth,
                                                                                     key: .expirationDate)) {
                    value = keyStore.fetch(service: .auth, key: .userAccessToken)
                    authType = .bearer
                }
            case .userService(let type):
                if case .basic = type {
                    value = AuthHelper.encoded(credentials: client)
                } else if case .bearer = type {
                    value = keyStore.fetch(service: .auth, key: .clientAccessToken)
                }
                authType = type
            }
            
            if let value = value, let header = authType {
                var request = resource.request
                let authHeader = AuthHelper.authorizationHeader(for: value, headerType: header)
                request.addValue(authHeader.value, forHTTPHeaderField: authHeader.key)
                dataTask(for: resource, finalRequest: request, completion: completion)
                    .resume()
            } else {
                Log("Stored token is no longer valid", event: .warning)
                handleError(resource: resource, statusCode: 401, completion: completion)
            }
            
        } else {
            dataTask(for: resource, finalRequest: resource.request, completion: completion)
                .resume()
        }
    }
}

// MARK: - Fileprivate

extension SessionManager {
    
    // swiftlint:disable function_body_length
    fileprivate func dataTask<T: Resource>(for resource: T,
                                           finalRequest request: URLRequest,
                                           completion: @escaping CompletionResult<T.ResponseType>)
        -> URLSessionDataTask {
            return self.session.dataTask(with: request) {[weak self] data, response, _ in
                guard let self = self else { return }
                guard let response = response else {
                    completion(.failure(.noResponse))
                    return
                }
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<400:
                        if let jsonData = data {
                            do {
                                let result = try resource.parsedResponse(data: jsonData, urlResponse: response)
                                Log("Success: \(request.httpMethod!) - \(request.url!)", event: .success)
                                completion(.success(result))
                            } catch let error {
                                Log("""
                                    Failure: \(request.httpMethod!) - \(request.url!)
                                    Parse error: \(error)
                                    Data content: \(String(describing: String(data: jsonData, encoding: .utf8)))
                                    """, event: .error)
                                completion(.failure(.parseError))
                            }
                        } else {
                            completion(.failure(.unknown))
                        }
                    case 400..<500:
                        Log("""
                            Failure: \(request.httpMethod!) - \(request.url!) - \(response.statusCode)
                            Data content: \(String(describing: String(data: data ?? Data(count: 0), encoding: .utf8)))
                            """,
                            event: .error)
                        self.handleError(resource: resource,
                                         statusCode: response.statusCode,
                                         completion: completion)
                    default:
                        if let data = data {
                            Log("""
                                Failure: \(request.httpMethod!) - \(request.url!)
                                Data content: \(String(describing: String(data: data, encoding: .utf8)))
                                """,
                                event: .error)
                        }
                        completion(.failure(.unknown))
                    }
                } else {
                    if let data = data {
                        Log("""
                            Failure: \(request.httpMethod!) - \(request.url!)
                            Data content: \(String(describing: String(data: data, encoding: .utf8)))
                            """,
                            event: .error)
                    } else {
                        Log("""
                            Failure: \(request.httpMethod!) - \(request.url!)
                            
                            """,
                            event: .error)
                    }
                    completion(.failure(.parseError))
                }
            }
    }
    
    fileprivate func handleError<T: Resource>(resource: T,
                                              statusCode: Int,
                                              completion: @escaping CompletionResult<T.ResponseType>) {
        switch statusCode {
        case 400:
            completion(.failure(.badRequest))
        case 401:
            if let refreshToken = keyStore.fetch(service: .auth, key: .refreshToken), resource.authServiceType != nil {
                //                authenticate(with: .refreshToken(refreshToken), in: baseURL, completion: { result in
                //                    switch result {
                //                    case .success:
                //                        self.load(resource: resource, completion: completion)
                //                        self.connect()
                //                    case .failure(let error):
                //                        let error = error == .noResponse ? error : .invalidCredentials
                //                        completion(.failure(error))
                //                    }
                //                })
            } else {
                Log("No refresh token stored", event: .warning)
                completion(.failure(.unauthorized))
            }
        default:
            completion(.failure(.unknown))
        }
    }
    
}

// MARK: - SessionAuthenticationProtocol

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
    
    var isLoggedIn: Bool {
        return keyStore.fetch(service: .auth, key: .refreshToken) != nil
    }
    
    private func create(_ user: User,
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
    
    private func login(_ user: User,
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
    
    private func fetchClientAccessToken(completion: @escaping (Result<Void>) -> Void) {
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
    
    //    func authenticate(with authType: AuthGrantType,
    //                      in url: HAURL,
    //                      completion: @escaping CompletionResult<Void>) {
    //        load(resource: AuthHelper.authResource(for: authType, in: url),
    //             completion: { result in
    //                switch result {
    //                case .success(let token):
    //                    do {
    //                        Log("Access Token refreshed", event: .custom("🔑"))
    //
    //                        // Save access token
    //                        try self.keyStore
    //                            .save(item: KeychainManagerItem(key: .accessToken,
    //                                                            value: token.accessToken,
    //                                                            service: .auth))
    //
    //                        // Save expiration date
    //                        let expirationDate = DateFormatter
    //                            .iso8601Full
    //                            .string(from: Date().addingTimeInterval(token.expiresIn))
    //                        try self.keyStore
    //                            .save(item: KeychainManagerItem(key: .expirationDate,
    //                                                            value: expirationDate,
    //                                                            service: .auth))
    //
    //                        // Save refresh token (if exists)
    //                        if let refreshToken = token.refreshToken {
    //                            try self.keyStore
    //                                .save(item: KeychainManagerItem(key: .refreshToken,
    //                                                                value: refreshToken,
    //                                                                service: .auth))
    //                        }
    //
    //                        // Save host
    //                        try self.keyStore
    //                            .save(item: KeychainManagerItem(key: .haUrl, value: url.string, service: .auth))
    //
    //                        completion(.success(()))
    //                    } catch {
    //                        completion(.failure(.keychainError))
    //                    }
    //                case .failure(let error):
    //                    completion(.failure(error))
    //                }
    //        })
    //    }
    
    func logOut() {
        keyStore.removeAll()
    }
}
