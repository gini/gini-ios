//
//  DocumentServicesTests.swift
//  Gini-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/26/19.
//

import XCTest
@testable import Gini

final class DocumentServicesTests: XCTestCase {

    var sessionManagerMock: SessionManagerMock!
    var defaultDocumentService: DefaultDocumentService!
    var accountingDocumentService: AccountingDocumentService!

    override func setUp() {
        sessionManagerMock = SessionManagerMock()
        defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock)
        accountingDocumentService = AccountingDocumentService(sessionManager: sessionManagerMock)
    }
    
    func testV1DocumentCreation() {
        let expect = expectation(description: "it returns a document")
        
        accountingDocumentService.createDocument(with: Data(count: 1), fileName: "", docType: nil) { result in
            switch result {
            case .success(let document):
                XCTAssertEqual(document.id, SessionManagerMock.v1DocumentId, "document ids should match")
                expect.fulfill()
            case .failure:
                break
            }
            
        }
        
        wait(for: [expect], timeout: 1)
    }
    
    func testPartialDocumentCreation() {
        let expect = expectation(description: "it returns a partial document")
        
        defaultDocumentService.createDocument(fileName: "", docType: nil, type: .partial(Data(count: 1))) { result in
            switch result {
            case .success(let document):
                XCTAssertEqual(document.id, SessionManagerMock.partialDocumentId, "document ids should match")
                expect.fulfill()
            case .failure:
                break
            }
            
        }
        
        wait(for: [expect], timeout: 1)
    }
    
    func testCompositeDocumentCreation() {
        let expect = expectation(description: "it returns a composite document")
        
        defaultDocumentService.createDocument(fileName: "",
                                              docType: nil,
                                              type: .composite(CompositeDocumentInfo(partialDocuments: []))) { result in
            switch result {
            case .success(let document):
                XCTAssertEqual(document.id, SessionManagerMock.compositeDocumentId, "document ids should match")
                expect.fulfill()
            case .failure:
                break
            }
            
        }
        
        wait(for: [expect], timeout: 1)
    }
    
    func testV1DocumentDeletion() {
        let expect = expectation(description: "it deletes a document")
        sessionManagerMock.initializeWithV1MockedDocuments()
        
        accountingDocumentService.deleteDocument(with: SessionManagerMock.v1DocumentId) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.sessionManagerMock.documents.isEmpty, "documents should be empty")
                expect.fulfill()
            case .failure:
                break
            }
            
        }
        
        wait(for: [expect], timeout: 1)
    }
    
    func testPartialDocumentDeletion() {
        let expect = expectation(description: "it deletes the partial document")
        sessionManagerMock.initializeWithV2MockedDocuments()
        
        defaultDocumentService.deleteDocument(with: SessionManagerMock.partialDocumentId,
                                              type: .partial(Data(count: 0))) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.sessionManagerMock.documents.isEmpty, "documents should be empty")
                expect.fulfill()
            case .failure:
                break
            }
            
        }
        
        wait(for: [expect], timeout: 1)
    }
    
    func testCompositeDocumentDeletion() {
        let expect = expectation(description: "it deletes the composite document")
        sessionManagerMock.initializeWithV2MockedDocuments()
        
        defaultDocumentService.deleteDocument(with: SessionManagerMock.compositeDocumentId,
                                              type: .composite(CompositeDocumentInfo(partialDocuments: []))) { result in
                                                switch result {
                                                case .success:
                                                    XCTAssertEqual(self.sessionManagerMock.documents.count, 1,
                                                                   "there should be one aprtial document left")
                                                    expect.fulfill()
                                                case .failure:
                                                    break
                                                }
                                                
        }
        
        wait(for: [expect], timeout: 1)
    }
    
}
