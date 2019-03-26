//
//  DocumentService.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import Foundation

typealias ResourceDataHandler<T: Resource> = (T, @escaping CompletionResult<T.ResponseType>) -> Void
typealias CancellableResourceDataHandler<T: Resource> = (T, CancellationToken?,
    @escaping CompletionResult<T.ResponseType>) -> Void

public protocol DocumentService: class {
    
    var apiDomain: APIDomain { get }
    
    func documents(limit: Int?,
                   offset: Int?,
                   completion: @escaping CompletionResult<[Document]>)
    func extractions(for document: Document,
                     cancellationToken: CancellationToken,
                     completion: @escaping CompletionResult<[Extraction]>)
    func fetchDocument(with id: String,
                       completion: @escaping CompletionResult<Document>)
    func layout(for document: Document,
                completion: @escaping CompletionResult<Document.Layout>)
    func pages(in document: Document,
               completion: @escaping CompletionResult<[Document.Page]>)
    func pagePreview(for document: Document,
                     pageNumber: Int,
                     size: Document.Page.Size,
                     completion: @escaping CompletionResult<Data>)
    func submiFeedback(for document: Document, with extractions: [Extraction])
}

public protocol V2DocumentService: class {
    func createDocument(fileName: String?,
                        docType: String?,
                        type: Document.TypeV2,
                        completion: @escaping CompletionResult<Document>)
    
    func deleteDocument(with id: String,
                        type: Document.TypeV2,
                        completion: @escaping CompletionResult<String>)
}

public protocol V1DocumentService: class {
    func createDocument(with data: Data,
                        fileName: String?,
                        docType: String?,
                        completion: @escaping CompletionResult<Document>)
    
    func deleteDocument(with id: String,
                        completion: @escaping CompletionResult<String>)
}

extension DocumentService {
    
    func documents(resourceHandler: ResourceDataHandler<APIResource<DocumentList>>,
                   limit: Int?,
                   offset: Int?,
                   completion: @escaping CompletionResult<[Document]>) {
        let resource = APIResource<DocumentList>(method: .documents(limit: limit, offset: offset),
                                                 apiDomain: apiDomain,
                                                 httpMethod: .get)
        resourceHandler(resource, { result in
            switch result {
            case .success(let documentList):
                completion(.success(documentList.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func deleteDocument(resourceHandler: ResourceDataHandler<APIResource<String>>,
                        with id: String,
                        completion: @escaping CompletionResult<String>) {
        let resource = APIResource<String>(method: .document(id: id),
                                           apiDomain: apiDomain,
                                           httpMethod: .delete)
        
        resourceHandler(resource, { result in
            switch result {
            case .success(let string):
                completion(.success(string))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func extractions(resourceHandler: @escaping CancellableResourceDataHandler<APIResource<ExtractionsContainer>>,
                     documentResourceHandler: @escaping CancellableResourceDataHandler<APIResource<Document>>,
                     for document: Document,
                     cancellationToken: CancellationToken?,
                     completion: @escaping CompletionResult<[Extraction]>) {
        poll(resourceHandler: documentResourceHandler,
             document: document,
             cancellationToken: cancellationToken) { result in
                switch result {
                case .success:
                    let resource = APIResource<ExtractionsContainer>(method: .extractions(forDocumentId: document.id),
                                                                     apiDomain: self.apiDomain,
                                                                     httpMethod: .get)
                    
                    resourceHandler(resource, cancellationToken, { result in
                        switch result {
                        case .success(let extractionsContainer):
                            completion(.success(extractionsContainer.extractions))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    func fetchDocument(resourceHandler: CancellableResourceDataHandler<APIResource<Document>>,
                       with id: String,
                       cancellationToken: CancellationToken? = nil,
                       completion: @escaping CompletionResult<Document>) {
        let resource = APIResource<Document>(method: .document(id: id),
                                             apiDomain: apiDomain,
                                             httpMethod: .get)
        
        resourceHandler(resource, cancellationToken, { result in
            guard !(cancellationToken?.isCancelled ?? false) else {
                completion(.failure(.requestCancelled))
                return
            }
            switch result {
            case .success(let document):
                completion(.success(document))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func layout(resourceHandler: ResourceDataHandler<APIResource<Document.Layout>>,
                for document: Document,
                completion: @escaping CompletionResult<Document.Layout>) {
        let resource = APIResource<Document.Layout>(method: .layout(forDocumentId: document.id),
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
    
    func pages(resourceHandler: ResourceDataHandler<APIResource<[Document.Page]>>,
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
    
    func pagePreview(resourceHandler: @escaping ResourceDataHandler<APIResource<Data>>,
                     in document: Document,
                     pageNumber: Int,
                     size: Document.Page.Size?,
                     completion: @escaping CompletionResult<Data>) {
        guard document.sourceClassification != .composite else {
            preconditionFailure("Composite documents does not have a page preview. " +
                "Fetch each partial page preview instead")
        }
        
        guard pageNumber > 0 else {
            preconditionFailure("The page number starts at 1")
        }
        
        let resource = APIResource<Data>(method: .page(forDocumentId: document.id,
                                                       number: pageNumber,
                                                       size: size),
                                         apiDomain: self.apiDomain,
                                         httpMethod: .get)
        
        resourceHandler(resource) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                if case .notFound = error {
                    print("Document \(document.id) page not found")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.pagePreview(resourceHandler: resourceHandler,
                                         in: document,
                                         pageNumber: pageNumber,
                                         size: size,
                                         completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
            
        }
    }
    
    func submitFeedback(resourceHandler: ResourceDataHandler<APIResource<String>>,
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

// MARK: - Fileprivate

fileprivate extension DocumentService {
    func poll(resourceHandler: @escaping CancellableResourceDataHandler<APIResource<Document>>,
              document: Document,
              cancellationToken: CancellationToken?,
              completion: @escaping CompletionResult<Void>) {
        fetchDocument(resourceHandler: resourceHandler,
                      with: document.id,
                      cancellationToken: cancellationToken) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let document):
                            if document.progress != .pending {
                                completion(.success(()))
                            } else {
                                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                                    self.poll(resourceHandler: resourceHandler,
                                              document: document,
                                              cancellationToken: cancellationToken,
                                              completion: completion)
                                }
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
        }
    }
}
