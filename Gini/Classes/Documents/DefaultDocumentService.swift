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
    fileprivate let apiDomain: APIDomain = .api
    
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
        let resource = APIResource<Document>.init(method: .document(id: id),
                                                  apiDomain: apiDomain,
                                                  httpMethod: .get)
        sessionManager.data(resource: resource, completion: completion)
    }
    
    public func extractionsForDocument(with id: String, completion: @escaping CompletionResult<[Extraction]>) {
        let resource = APIResource<ExtractionsContainer>.init(method: .extractions(forDocumentId: id),
                                                              apiDomain: apiDomain,
                                                              httpMethod: .get)
        sessionManager.data(resource: resource) { result in
            switch result {
            case .success(let extractionsContainer):
                completion(.success(extractionsContainer.extractions))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
