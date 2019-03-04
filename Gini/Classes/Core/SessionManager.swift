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
    
    func authenticate(completion: @escaping CompletionResult<Void>)
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
        if resource.isAuthRequired {
            if let accessToken = keyStore.fetch(service: .auth, key: .accessToken),
                AuthHelper.isTokenStillValid(keyStore: keyStore) {
                var request = resource.request
                let authHeader = AuthHelper.authorizationHeader(for: accessToken)
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

// MARK: - SessionAuthenticationProtocol

extension SessionManager: SessionAuthenticationProtocol {
    func authenticate(completion: @escaping CompletionResult<Void>) {
        
    }
    
    var isLoggedIn: Bool {
        return keyStore.fetch(service: .auth, key: .refreshToken) != nil
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
            if let refreshToken = keyStore.fetch(service: .auth, key: .refreshToken), resource.isAuthRequired {
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

