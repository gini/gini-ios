//
//  SessionManager.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation
#if PINNING_AVAILABLE
import TrustKit
#endif

/// Represents a completion result callback
public typealias CompletionResult<T> = (Result<T, GiniError>) -> Void

protocol SessionAuthenticationProtocol: class {
    func logIn(completion: @escaping (Result<Token, GiniError>) -> Void)
    func logOut()
}

protocol SessionProtocol: class {
    
    func data<T: Resource>(resource: T,
                           cancellationToken: CancellationToken?,
                           completion: @escaping CompletionResult<T.ResponseType>)
    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping CompletionResult<T.ResponseType>)
    func upload<T: Resource>(resource: T,
                             data: Data,
                             cancellationToken: CancellationToken?,
                             completion: @escaping CompletionResult<T.ResponseType>)
    
}

extension SessionProtocol {
    func data<T: Resource>(resource: T,
                           completion: @escaping CompletionResult<T.ResponseType>) {
        data(resource: resource, cancellationToken: nil, completion: completion)
    }
    
    func upload<T: Resource>(resource: T,
                             data: Data,
                             completion: @escaping CompletionResult<T.ResponseType>) {
        upload(resource: resource, data: data, cancellationToken: nil, completion: completion)
    }
    
    func download<T: Resource>(resource: T,
                               completion: @escaping CompletionResult<T.ResponseType>) {
        download(resource: resource, cancellationToken: nil, completion: completion)
    }
    
}

typealias SessionManagerProtocol = SessionProtocol & SessionAuthenticationProtocol

final class SessionManager: NSObject {
    
    let keyStore: KeyStore
    let alternativeTokenSource: AlternativeTokenSource?
    private var session: URLSession = .init(configuration: .default)
    let userDomain: UserDomain
    
    enum TaskType {
        case data, download, upload(Data)
    }
    
    init(keyStore: KeyStore = KeychainStore(),
         alternativeTokenSource: AlternativeTokenSource? = nil,
         urlSession: URLSession = .init(configuration: .default),
         userDomain: UserDomain = .default) {
        self.keyStore = keyStore
        self.alternativeTokenSource = alternativeTokenSource
        self.userDomain = userDomain
        super.init()
        #if PINNING_AVAILABLE
        self.session = URLSession(configuration: urlSession.configuration, delegate: self, delegateQueue: OperationQueue.main)
        #else
        self.session = urlSession
        #endif
    }
}

// MARK: - SessionProtocol

extension SessionManager: SessionProtocol {
    
    func data<T: Resource >(resource: T,
                            cancellationToken: CancellationToken?,
                            completion: @escaping CompletionResult<T.ResponseType>) {
        load(resource: resource, taskType: .data, cancellationToken: cancellationToken, completion: completion)
    }
    
    func upload<T: Resource>(resource: T,
                             data: Data,
                             cancellationToken: CancellationToken?,
                             completion: @escaping CompletionResult<T.ResponseType>) {
        load(resource: resource, taskType: .upload(data), cancellationToken: cancellationToken, completion: completion)
    }
    
    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping CompletionResult<T.ResponseType>) {
        load(resource: resource, taskType: .download, cancellationToken: cancellationToken, completion: completion)
    }
}

/// Cancellation token needed during the analysis process
public final class CancellationToken {
    internal weak var task: URLSessionTask?
    
    /// Indicates if the analysis has been cancelled
    public var isCancelled = false
    
    public init() {
        
    }
    
    /// Cancels the current task
    public func cancel() {
        isCancelled = true
        task?.cancel()
    }
}

// MARK: - Private

private extension SessionManager {
    
    func load<T: Resource>(resource: T,
                           taskType: TaskType,
                           cancellationToken: CancellationToken?,
                           completion: @escaping CompletionResult<T.ResponseType>) {
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
                
                dataTask(for: resource,
                         finalRequest: request,
                         type: taskType,
                         cancellationToken: cancellationToken,
                         completion: completion).resume()
            } else {
                Log("Stored token is no longer valid", event: .warning)
                handleError(resource: resource,
                            statusCode: 401,
                            taskType: taskType,
                            cancellationToken: cancellationToken,
                            completion: completion)
            }
            
        } else {
            dataTask(for: resource,
                     finalRequest: resource.request,
                     type: taskType,
                     cancellationToken: cancellationToken,
                     completion: completion).resume()
        }
    }
    
    private func dataTask<T: Resource>(for resource: T,
                                       finalRequest request: URLRequest,
                                       type: TaskType,
                                       cancellationToken: CancellationToken?,
                                       completion: @escaping CompletionResult<T.ResponseType>)
        -> URLSessionTask {
            let task: URLSessionTask
            switch type {
            case .data:
                task = session.dataTask(with: request,
                                        completionHandler: taskCompletionHandler(for: resource,
                                                                                 request: request,
                                                                                 taskType: type,
                                                                                 cancellationToken: cancellationToken,
                                                                                 completion: completion))
            case .download:
                task = session
                    .downloadTask(with: request,
                                  completionHandler: downloadTaskCompletionHandler(for: resource,
                                                                                   request: request,
                                                                                   taskType: type,
                                                                                   cancellationToken: cancellationToken,
                                                                                   completion: completion))
            case .upload(let data):
                task = session.uploadTask(with: request,
                                          from: data,
                                          completionHandler: taskCompletionHandler(for: resource,
                                                                                   request: request,
                                                                                   taskType: type,
                                                                                   cancellationToken: cancellationToken,
                                                                                   completion: completion))
                
            }
            
            cancellationToken?.task = task
            return task
    }
    
    // swiftlint:disable function_body_length
    private func taskCompletionHandler<T: Resource>(
        for resource: T,
        request: URLRequest,
        taskType: TaskType,
        cancellationToken: CancellationToken?,
        completion: @escaping CompletionResult<T.ResponseType>) -> ((Data?, URLResponse?, Error?) -> Void) {
        return { [weak self] data, response, error in
            guard let self = self else { return }
            guard let response = response else { completion(.failure(.noResponse)); return }
            guard !(cancellationToken?.isCancelled ?? false) else { completion(.failure(.requestCancelled)); return }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<400:
                    if let jsonData = data {
                        do {
                            let result = try resource.parsed(response: response, data: jsonData)
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
                                     taskType: taskType,
                                     cancellationToken: cancellationToken,
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
    
    private func downloadTaskCompletionHandler<T: Resource>(
        for resource: T,
        request: URLRequest,
        taskType: TaskType,
        cancellationToken: CancellationToken?,
        completion: @escaping CompletionResult<T.ResponseType>) -> ((URL?, URLResponse?, Error?) -> Void) {
        return {[weak self] url, response, error in
            guard let self = self else { return }
            
            self.taskCompletionHandler(for: resource,
                                       request: request,
                                       taskType: taskType,
                                       cancellationToken: cancellationToken,
                                       completion: completion)(Data(url: url), response, error)
        }
    }
    
    private func handleError<T: Resource>(resource: T,
                                          statusCode: Int,
                                          taskType: TaskType,
                                          cancellationToken: CancellationToken?,
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
                            self.load(resource: resource,
                                      taskType: taskType,
                                      cancellationToken: cancellationToken,
                                      completion: completion)
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
        case 404:
            completion(.failure(.notFound))
        case 406:
            completion(.failure(.notAcceptable))
        case 429:
            completion(.failure(.tooManyRequests))
        default:
            completion(.failure(.unknown))
        }
    }
    
}

// MARK: - URLSessionDelegate

#if PINNING_AVAILABLE

extension SessionManager: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

#endif
