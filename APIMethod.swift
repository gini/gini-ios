//
//  APIMethod.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/4/19.
//

import Foundation

enum APIMethod: ResourceMethod {
    
    case documents(limit: Int?, offset: Int?)
    case document(id: String)
    case errorReport(forDocumentWithId: String,
        summary: String?, description: String?)
    case extractions(forDocumentId: String)
    case extraction(withLabel: String, documentId: String)
    case layout(forDocumentId: String)
    case pages(forDocumentId: String)
    case processedDocument(withId: String)
    
    var path: String {
        switch self {
        case .documents:
            return "/documents"
        case .document(let id):
            return APIMethod.documents(limit: nil,
                                       offset: nil).path + "/\(id)"
        case .errorReport(let id, _, _):
            return APIMethod.document(id: id).path + "/errorreport"
        case .extractions(let id):
            return APIMethod.document(id: id).path + "/extractions"
        case .extraction(let label, let documentId):
            return APIMethod.extractions(forDocumentId: documentId).path + "/\(label)"
        case .layout(let id):
            return APIMethod.document(id: id).path + "/layout"
        case .pages(let id):
            return APIMethod.document(id: id).path + "/pages"
        case .processedDocument(let id):
            return APIMethod.document(id: id).path + "/processed"
        }
    }
    
    var queryItems: [URLQueryItem?]? {
        switch self {
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
    
}
