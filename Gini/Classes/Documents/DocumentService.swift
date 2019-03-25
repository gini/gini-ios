//
//  DocumentService.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import Foundation

public protocol DocumentService: class {

    var apiDomain: APIDomain { get }
    
    func extractions(for document: Document,
                     completion: @escaping CompletionResult<[Extraction]>)
    func fetchDocument(with id: String,
                       completion: @escaping CompletionResult<Document>)
    func layout(for document: Document,
                completion: @escaping CompletionResult<[Document.Page]>)
    func pages(in document: Document,
               completion: @escaping CompletionResult<[Document.Page]>)
    func submiFeedback(for document: Document, with extractions: [Extraction])
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

extension DocumentService {
    
    func extractions(resourceHandler: (APIResource<ExtractionsContainer>,
        @escaping CompletionResult<ExtractionsContainer>) -> Void,
                     for document: Document,
                     completion: @escaping CompletionResult<[Extraction]>) {
        let resource = APIResource<ExtractionsContainer>.init(method: .extractions(forDocumentId: document.id),
                                                              apiDomain: apiDomain,
                                                              httpMethod: .get)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let extractionsContainer):
                completion(.success(extractionsContainer.extractions))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func fetchDocument(resourceHandler: (APIResource<Document>, @escaping CompletionResult<Document>) -> Void,
                       with id: String,
                       completion: @escaping CompletionResult<Document>) {
        let resource = APIResource<Document>.init(method: .document(id: id),
                                                  apiDomain: apiDomain,
                                                  httpMethod: .get)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let document):
                completion(.success(document))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func pages(resourceHandler: (APIResource<[Document.Page]>, @escaping CompletionResult<[Document.Page]>) -> Void,
               in document: Document,
               completion: @escaping CompletionResult<[Document.Page]>) {
        let resource = APIResource<[Document.Page]>(method: .pages(forDocumentId: document.id),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .get)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let document):
                completion(.success(document))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func submitFeedback(resourceHandler: (APIResource<String>, @escaping CompletionResult<String>) -> Void,
                        for document: Document,
                        with extractions: [Extraction]) {
        let json = try? JSONEncoder().encode(ExtractionsFeedback(feedback: extractions))
        
        let resource = APIResource<String>(method: .extractions(forDocumentId: document.id),
                                           apiDomain: apiDomain,
                                           httpMethod: .put,
                                           body: json)
        
        resourceHandler(resource, { _ in})
    }
}
