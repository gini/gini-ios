//
//  APIResource.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/18/18.
//

import Foundation

struct APIResource<T: Decodable>: Resource {
    
    typealias ResourceMethodType = APIMethod
    typealias ResponseType = T
    
    var params: RequestParameters
    var method: APIMethod
    var isAuthRequired: Bool {
        return true
    }
    
    var host: String {
        return "api.gini.net"
    }
    
    var scheme: URLScheme {
        return .https
    }
    
    var queryItems: [URLQueryItem?]? {
        return method.queryItems
    }
    
    var path: String {
        return method.path
    }
    
    init(method: APIMethod, params: RequestParameters) {
        self.method = method
        self.params = params
    }
    
    public func parsedResponse(data: Data, urlResponse: HTTPURLResponse) throws -> T {
        guard T.self != String.self else {
            // swiftlint:disable:next force_cast
            return String(data: data, encoding: .utf8) as! T
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }
    
}
