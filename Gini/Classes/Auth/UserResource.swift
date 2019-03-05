//
//  UserResource.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

struct UserResource<T: Decodable>: Resource {
    typealias ResourceMethodType = UserMethod
    typealias ResponseType = T
    
    var host: String {
        return "user.gini.net"
    }
    
    var scheme: URLScheme {
        return .https
    }
    
    var path: String {
        return method.path
    }
    
    var queryItems: [URLQueryItem?]? {
        return method.queryItems
    }
    
    var params: RequestParameters
    var method: UserMethod
    
    var isAuthRequired: Bool {
        return false
    }
    
    init(method: UserMethod, params: RequestParameters) {
        self.method = method
        self.params = params
    }
    
    public func parsedResponse(data: Data, urlResponse: HTTPURLResponse) throws -> T {
        guard T.self != String.self else {
            // swiftlint:disable:next force_cast
            return String(data: data, encoding: .utf8) as! T
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

