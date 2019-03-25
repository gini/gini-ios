//
//  AccountingDocumentService.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/22/19.
//

import Foundation

typealias AccountingDocumentServiceProtocol = DocumentService & V1DocumentService

public final class AccountingDocumentService: AccountingDocumentServiceProtocol {
    
    fileprivate let sessionManager: SessionManagerProtocol
    public var apiDomain: APIDomain = .accounting
    
    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
    }
    
    public func createDocument(with data: Data,
                               fileName: String?,
                               docType: String?,
                               completion: @escaping CompletionResult<Document>) {
        let resource = APIResource<String>(method: .createDocument(fileName: fileName,
                                                                   docType: docType,
                                                                   mimeSubType: data.mimeSubType,
                                                                   documentType: nil),
                                                apiDomain: apiDomain,
                                                httpMethod: .post)
        sessionManager.upload(resource: resource, data: data) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let documentUrl):
                guard let id = documentUrl.split(separator: "/").last else { completion(.failure(.parseError)); return }
                self.fetchDocument(with: String(id), completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func deleteDocument(with id: String, completion: @escaping CompletionResult<String>) {
        let resource = APIResource<String>(method: .document(id: id),
                                           apiDomain: apiDomain,
                                           httpMethod: .delete)
        
        sessionManager.data(resource: resource, completion: completion)
    }
    
    public func documents(limit: Int?, offset: Int?, completion: @escaping CompletionResult<[Document]>) {
        documents(resourceHandler: sessionManager.data, limit: limit, offset: offset, completion: completion)
    }
    
    public func fetchDocument(with id: String, completion: @escaping CompletionResult<Document>) {
        fetchDocument(resourceHandler: sessionManager.data, with: id, completion: completion)
    }
    
    public func extractions(for document: Document,
                            cancellationToken: CancellationToken,
                            completion: @escaping CompletionResult<[Extraction]>) {
        extractions(resourceHandler: sessionManager.data,
                    documentResourceHandler: sessionManager.data,
                    for: document,
                    cancellationToken: cancellationToken,
                    completion: completion)
    }
    
    public func layout(for document: Document, completion: @escaping CompletionResult<Document.Layout>) {
        layout(resourceHandler: sessionManager.data, for: document, completion: completion)
    }
    
    public func pages(in document: Document, completion: @escaping CompletionResult<[Document.Page]>) {
        pages(resourceHandler: sessionManager.data, in: document, completion: completion)
    }
    
    public func submiFeedback(for document: Document, with extractions: [Extraction]) {
        submitFeedback(resourceHandler: sessionManager.data, for: document, with: extractions)
    }
}
