//
//  DefaultDocumentService.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/22/19.
//

import Foundation

typealias DefaultDocumentServiceProtocol = DocumentService & V2DocumentService

public final class DefaultDocumentService: DefaultDocumentServiceProtocol {
    
    fileprivate let sessionManager: SessionManagerProtocol
    public var apiDomain: APIDomain = .default
    
    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
    }
    
    public func createDocument(fileName: String?,
                               docType: String?,
                               type: DocumentTypeV2,
                               completion: @escaping CompletionResult<Document>) {
        let completionResult: CompletionResult<String> = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let documentUrl):
                guard let id = documentUrl.split(separator: "/").last else { completion(.failure(.parseError)); return }
                self.fetchDocument(with: String(id), completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        switch type {
        case .composite(let compositeDocumentInfo):
            let resource = APIResource<String>.init(method: .createDocument(fileName: fileName,
                                                                            docType: docType,
                                                                            mimeSubType: "json",
                                                                            documentType: type),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .post,
                                                    body: try? JSONEncoder().encode(compositeDocumentInfo))
            sessionManager.data(resource: resource, completion: completionResult)
        case .partial(let data):
            let resource = APIResource<String>.init(method: .createDocument(fileName: fileName,
                                                                            docType: docType,
                                                                            mimeSubType: "json",
                                                                            documentType: type),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .post)
            sessionManager.upload(resource: resource, data: data, completion: completionResult)
        }
        
    }
    
    public func fetchDocument(with id: String, completion: @escaping CompletionResult<Document>) {
        fetchDocument(resourceHandler: sessionManager.data, with: id, completion: completion)
    }
    
    public func extractions(for document: Document, completion: @escaping CompletionResult<[Extraction]>) {
        extractions(resourceHandler: sessionManager.data, for: document, completion: completion)
    }
    
    public func pages(in document: Document, completion: @escaping CompletionResult<[Document.Page]>) {
        pages(resourceHandler: sessionManager.data, in: document, completion: completion)
    }
    
    public func submiFeedback(for document: Document, with extractions: [Extraction]) {
        submitFeedback(resourceHandler: sessionManager.data, for: document, with: extractions)
    }
}
