//
//  SessionManager.swift
//  Gini
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
    func logIn(completion: @escaping (Result<Void>) -> Void)
    func logOut()
}

protocol SessionProtocol: class {
    
    init(keyStore: KeyStore, urlSession: URLSession)
    func load<T: Resource>(resource: T, completion: @escaping CompletionResult<T.ResponseType>)
}

typealias SessionManagerProtocol = SessionProtocol & SessionAuthenticationProtocol

final class SessionManager {
    
    static let shared: SessionManager = SessionManager(keyStore: KeychainStore())
    
    let keyStore: KeyStore
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
                value = keyStore.fetch(service: .auth, key: .userAccessToken)
                authType = .bearer
            case .userService(let type):
                if case .basic = type {
                    value = AuthHelper.encoded(client)
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
            if let authServiceType = resource.authServiceType, case .apiService = authServiceType {
                do {
                    // Remove current user
                    try self.keyStore.remove(service: .auth, key: .userEmail)
                    try self.keyStore.remove(service: .auth, key: .userPassword)
                    
                    // Log in again
                    self.logIn { result in
                        switch result {
                        case .success:
                            self.load(resource: resource, completion: completion)
                        case .failure:
                            completion(.failure(.unauthorized))
                        }
                    }
                } catch {
                    completion(.failure(.unauthorized))

                }
            } else {
                completion(.failure(.unauthorized))
            }
        default:
            completion(.failure(.unknown))
        }
    }
    
}
