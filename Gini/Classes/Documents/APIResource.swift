//
//  APIResource.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/18/18.
//

import Foundation

public enum APIDomain: String {
    case `default` = "api", accounting = "accounting-api"
}

struct APIResource<T: Decodable>: Resource {
    
    typealias ResourceMethodType = APIMethod
    typealias ResponseType = T
    
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
    
    var apiVersion: Int {
        return domain == .default ? 2 : 1
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
        case .createDocument(let fileName, let docType, _, _):
            return [URLQueryItem(name: "filename", itemValue: fileName),
                    URLQueryItem(name: "doctype", itemValue: docType)
            ]
        default: return nil
        }
    }
    
    var path: String {
        switch method {
        case .composite:
            return "/documents/composite"
        case .documents, .createDocument:
            return "/documents/"
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
        case .page(let id, let number, let size):
            if let size = size {
                return "/documents/\(id)/pages/\(number)/\(size.rawValue)"
            } else {
                return "/documents/\(id)/pages/\(number)"
            }
        case .partial:
            return "/documents/partial"
        case .processedDocument(let id):
            return "/documents/\(id)/processed"
        }
    }
    
    var defaultHeaders: HTTPHeaders {
        switch method {
        case .createDocument(_, _, let mimeSubType, let documentType):
            return ["Accept": ContentType.content(version: apiVersion,
                                                  subtype: nil,
                                                  mimeSubtype: "json").value,
                    "Content-Type": ContentType.content(version: apiVersion,
                                                        subtype: documentType?.name,
                                                        mimeSubtype: mimeSubType).value
            ]
        case .page:
            return [:]
        default:
            return ["Accept": ContentType.content(version: apiVersion,
                                                  subtype: nil,
                                                  mimeSubtype: "json").value,
                    "Content-Type": ContentType.content(version: apiVersion,
                                                         subtype: nil,
                                                         mimeSubtype: "json").value
            ]
        }
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
    
    func parsed(response: HTTPURLResponse, data: Data) throws -> ResponseType {
        guard ResponseType.self != String.self else {
            let string: String?
            switch method {
            case .createDocument:
                string = response.allHeaderFields["Location"] as? String
            default:
                string = String(data: data, encoding: .utf8)
            }
            
            if let string = string as? ResponseType {
                return string
            } else {
                throw GiniError.parseError
            }
        }
        
        guard ResponseType.self != Data.self else {
            //swiftlint:disable force_cast
            return data as! ResponseType
        }
        
        return try JSONDecoder().decode(ResponseType.self, from: data)
    }
    
}
