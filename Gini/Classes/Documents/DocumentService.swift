//
//  DocumentService.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import Foundation

public protocol DocumentService: class {

    func extractionsForDocument(with id: String,
                                completion: @escaping CompletionResult<[Extraction]>)
    func fetchDocument(with id: String,
                       completion: @escaping CompletionResult<Document>)
    func submiFeedback(forDocument: Document, with extraction: [Extraction])
}

public protocol V2DocumentService: class {
    func createDocument(fileName: String?,
                        docType: String?,
                        type: DocumentTypeV2,
                        completion: @escaping CompletionResult<Document>)
}

public protocol V1DocumentService: class {
    func createDocument(with data: Data,
                        fileName: String?,
                        docType: String?,
                        completion: @escaping CompletionResult<Document>)
}
