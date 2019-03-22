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
    fileprivate let apiDomain: APIDomain = .accounting
    
    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
    }
    
    public func createDocument(with data: Data,
                               fileName: String?,
                               docType: String?,
                               completion: @escaping CompletionResult<Document>) {
        let resource = APIResource<String>.init(method: .createDocument(fileName: fileName,
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
