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
                               docType: Document.DocType?,
                               type: Document.TypeV2,
                               metadata: Document.Metadata?,
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
                                                    additionalHeaders: metadata?.headers ?? [:],
                                                    body: try? JSONEncoder().encode(compositeDocumentInfo))
            sessionManager.data(resource: resource, completion: completionResult)
        case .partial(let data):
            let resource = APIResource<String>.init(method: .createDocument(fileName: fileName,
                                                                            docType: docType,
                                                                            mimeSubType: "json",
                                                                            documentType: type),
                                                    apiDomain: apiDomain,
                                                    httpMethod: .post,
                                                    additionalHeaders: metadata?.headers ?? [:])
            sessionManager.upload(resource: resource, data: data, completion: completionResult)
        }
        
    }
    
    public func deleteDocument(with id: String,
                               type: Document.TypeV2,
                               completion: @escaping CompletionResult<String>) {
        switch type {
        case .composite:
            deleteDocument(resourceHandler: sessionManager.data, with: id, completion: completion)
        case .partial:
            fetchDocument(with: id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let document):
                    // Before removing the partial document, all its composite documents must be deleted
                    let dispatchGroup = DispatchGroup()
                    document.compositeDocuments?.forEach { compositeDocument in
                        guard let id = compositeDocument.id else { return }
                        dispatchGroup.enter()
                        
                        self.deleteDocument(resourceHandler: self.sessionManager.data,
                                            with: id) { _ in
                            dispatchGroup.leave()
                        }
                    }
                    
                    // Once all composite documents are deleted, it proceeds with the partial document
                    dispatchGroup.notify(queue: DispatchQueue.global()) {
                        self.deleteDocument(resourceHandler: self.sessionManager.data,
                                            with: id,
                                            completion: completion)
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        }
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
    
    public func pagePreview(for document: Document,
                            pageNumber: Int,
                            size: Document.Page.Size,
                            completion: @escaping CompletionResult<Data>) {
        pagePreview(resourceHandler: sessionManager.download,
                    in: document,
                    pageNumber: pageNumber,
                    size: size,
                    completion: completion)
    }
    
    public func submitFeedback(for document: Document, with extractions: [Extraction]) {
        submitFeedback(resourceHandler: sessionManager.data, for: document, with: extractions)
    }
}
