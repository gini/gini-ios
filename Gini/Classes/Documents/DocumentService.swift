//
//  DocumentService.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import Foundation

public protocol DocumentServiceProtocol: class {
    func createDocument(with data: Data,
                        fileName: String?,
                        docType: String?,
                        completion: @escaping CompletionResult<Document>)
    func fetchDocument(with id: String,
                       completion: @escaping CompletionResult<Document>)
}

public final class DocumentService: DocumentServiceProtocol {
    
    fileprivate let sessionManager: SessionManagerProtocol
    fileprivate let apiDomain: APIDomain
        
    init(sessionManager: SessionManagerProtocol = SessionManager.shared, apiDomain: APIDomain) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }
    
    public func createDocument(with data: Data,
                               fileName: String?,
                               docType: String?,
                               completion: @escaping CompletionResult<Document>) {
        
        let resource = APIResource<String>.init(method: .createDocument(fileName: fileName, docType: ""),
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
}
