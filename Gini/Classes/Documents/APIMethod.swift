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
    
}
