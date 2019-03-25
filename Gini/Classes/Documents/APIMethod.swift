//
//  APIMethod.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/4/19.
//

import Foundation

enum APIMethod: ResourceMethod {
    
    case createDocument(fileName: String?, docType: String?, mimeSubType: String, documentType: Document.TypeV2?)
    case documents(limit: Int?, offset: Int?)
    case document(id: String)
    case composite
    case errorReport(forDocumentWithId: String,
        summary: String?, description: String?)
    case extractions(forDocumentId: String)
    case extraction(withLabel: String, documentId: String)
    case layout(forDocumentId: String)
    case partial
    case pages(forDocumentId: String)
    case page(forDocumentId: String, number: Int, size: String?)
    case processedDocument(withId: String)
    
}
