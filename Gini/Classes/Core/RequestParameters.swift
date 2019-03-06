//
//  Request.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

public typealias HTTPHeaders = [String: String]
public typealias HTTPHeader = (key: String, value: String)

public enum HTTPHeaderKey: String {
    case contentType = "content-type"
}

public enum HTTPContentType: String {
    case json = "application/json"
    case urlEncode = "application/x-www-form-urlencoded"
}

public enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

public enum URLScheme: String {
    case http, https
}

public struct RequestParameters: Equatable {
    
    let body: Data?
    let method: HTTPMethod
    var headers: HTTPHeaders
    
    public init(method: HTTPMethod, headers: HTTPHeaders = [:], body: Data? = nil) {
        self.method = method
        self.headers = headers
        self.body = body
    }
    
}
