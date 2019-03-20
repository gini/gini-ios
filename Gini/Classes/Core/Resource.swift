//
//  Resource.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/24/18.
//

import Foundation

public protocol Resource: Equatable {
    associatedtype ResponseType: Decodable
    associatedtype ResourceMethodType: ResourceMethod
    var scheme: URLScheme { get }
    var host: String { get }
    var path: String { get }
    var params: RequestParameters { get set }
    var queryItems: [URLQueryItem?]? { get }
    var method: ResourceMethodType { get }
    var authServiceType: AuthServiceType? { get }
    var defaultHeaders: HTTPHeaders { get }
    
    func parsedResponse(data: Data, urlResponse: HTTPURLResponse) throws -> ResponseType
}

public protocol ResourceMethod {
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
        
        return filtered.isNotEmpty ? filtered : nil
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.url.absoluteString == rhs.url.absoluteString
    }
    
    func parsedResponse(data: Data, urlResponse: HTTPURLResponse) throws -> ResponseType {
        guard ResponseType.self != String.self else {
            // swiftlint:disable:next force_cast
            return String(data: data, encoding: .utf8) as! ResponseType
        }
        
        return try JSONDecoder().decode(ResponseType.self, from: data)
    }
    
}
