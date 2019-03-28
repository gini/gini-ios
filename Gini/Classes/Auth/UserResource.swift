//
//  UserResource.swift
//  Gini
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
        switch method {
        case .token:
            return "/oauth/token"
        case .users:
            return "/api/users"
        }
    }
    
    var queryItems: [URLQueryItem?]? {
        switch method {
        case .token(let grantype):
            return [URLQueryItem(name: "grant_type", itemValue: grantype.rawValue)]
        default: return nil
        }
    }
    
    var params: RequestParameters
    var method: UserMethod
    var authServiceType: AuthServiceType? {
        switch method {
        case .users:
            return .userService(.bearer)
        case .token:
            return .userService(.basic)
        }
    }
    
    var defaultHeaders: HTTPHeaders {
        switch method {
        case .token:
            return ["Accept": ContentType.json.value,
                    "Content-Type": ContentType.formUrlEncoded.value
            ]
        case .users:
            return ["Accept": ContentType.json.value,
                    "Content-Type": ContentType.json.value
            ]
        }
    }

    init(method: UserMethod, httpMethod: HTTPMethod, additionalHeaders: HTTPHeaders = [:], body: Data? = nil) {
        self.method = method
        self.params = RequestParameters(method: httpMethod,
                                        body: body)
        self.params.headers = defaultHeaders.merging(additionalHeaders) { (current, _ ) in current }
    }
    
    func parsed(response: HTTPURLResponse, data: Data) throws -> ResponseType {
        guard ResponseType.self != String.self else {
            // swiftlint:disable:next force_cast
            return String(data: data, encoding: .utf8) as! ResponseType
        }
        
        return try JSONDecoder().decode(ResponseType.self, from: data)
    }
}

