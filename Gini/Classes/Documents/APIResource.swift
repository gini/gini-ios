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
    
    enum APIDomain: String {
        case api, accounting
    }
    
    var domain: APIDomain
    var params: RequestParameters
    var method: APIMethod
    var authServiceType: AuthServiceType? = .apiService
    
    var host: String {
        return "\(domain.rawValue).gini.net"
    }
    
    var scheme: URLScheme {
        return .https
    }
    
    var queryItems: [URLQueryItem?]? {
        switch method {
        case .documents(let limit, let offset):
            return [URLQueryItem(name: "limit", itemValue: limit),
                    URLQueryItem(name: "offset", itemValue: offset)
            ]
        case .errorReport(_, let summary, let description):
            return [URLQueryItem(name: "summary", itemValue: summary),
                    URLQueryItem(name: "description", itemValue: description)
            ]
        default: return nil
        }
    }
    
    var path: String {
        switch method {
        case .documents:
            return "/documents"
        case .document(let id):
            return "/documents/\(id)"
        case .errorReport(let id, _, _):
            return "/documents/\(id)/errorreport"
        case .extractions(let id):
            return "/documents/\(id)/extractions"
        case .extraction(let label, let documentId):
            return "/documents/\(documentId)/extractions/\(label)"
        case .layout(let id):
            return "/documents/\(id)/layout"
        case .pages(let id):
            return "/documents/\(id)/pages"
        case .processedDocument(let id):
            return "/documents/\(id)/processed"
        }
    }
    
    var defaultHeaders: HTTPHeaders {
        return ["Accept": ContentType.json.rawValue,
                "Content-Type": ContentType.formUrlEncoded.rawValue
        ]
    }
    
    init(method: APIMethod,
         apiDomain: APIDomain,
         httpMethod: HTTPMethod,
         additionalHeaders: HTTPHeaders = [:],
         body: Data? = nil) {
        self.method = method
        self.domain = apiDomain
        self.params = RequestParameters(method: httpMethod,
                                        body: body)
        self.params.headers = defaultHeaders.merging(additionalHeaders) { (current, _ ) in current }
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
