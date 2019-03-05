//
//  Resource.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/24/18.
//

import Foundation

public protocol Resource: Equatable {
    associatedtype ResponseType
    associatedtype ResourceMethodType: ResourceMethod
    var scheme: URLScheme { get }
    var host: String { get }
    var path: String { get }
    var params: RequestParameters { get set }
    var queryItems: [URLQueryItem?]? { get }
    var method: ResourceMethodType { get }
    var authServiceType: AuthServiceType? { get }
    
    func parsedResponse(data: Data, urlResponse: HTTPURLResponse) throws -> ResponseType
}

public protocol ResourceMethod {
    var path: String { get }
    var queryItems: [URLQueryItem?]? { get }
}

public enum AuthServiceType {
    case userService(AuthType), apiService
}

public enum AuthType: String {
    case basic = "Basic"
    case bearer = "BEARER"
}

public extension Resource {
    
    var url: URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme.rawValue
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = filteredQueryItems()
        
        return urlComponents.url!
    }
    
    var request: URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = params.headers
        urlRequest.httpMethod = params.method.rawValue
        urlRequest.httpBody = params.body
        return urlRequest
    }
    
    private func filteredQueryItems() -> [URLQueryItem]? {
        guard let filtered = (queryItems?.compactMap { $0 }) else {
            return nil
        }
        
        return !filtered.isEmpty ? filtered : nil
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.url.absoluteString == rhs.url.absoluteString
    }
    
}


