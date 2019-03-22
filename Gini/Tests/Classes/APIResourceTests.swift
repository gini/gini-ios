//
//  APIResource.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/18/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import Gini

final class APIResourceTests: XCTestCase {
    
    let baseAPIURLString = "https://api.gini.net"
    
    func testDocumentsResource() {
        let resource = APIResource<[Document]>(method: .documents(limit: nil, offset: nil),
                                               apiDomain: .api,
                                               httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/documents/", "path should match")
    }
    
    func testDocumentsWithLimitResource() {
        let resource = APIResource<[Document]>(method: .documents(limit: 1, offset: nil),
                                               apiDomain: .api,
                                               httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/documents/?limit=1", "path should match")
    }
    
    func testDocumentsWithOffsetResource() {
        let resource = APIResource<[Document]>(method: .documents(limit: nil, offset: 2),
                                               apiDomain: .api,
                                               httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/documents/?offset=2", "path should match")
    }
    
    func testDocumentsWithLimitAndOffsetResource() {
        let resource = APIResource<[Document]>(method: .documents(limit: 1, offset: 2),
                                               apiDomain: .api,
                                               httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/documents/?limit=1&offset=2",
                       "path should match")
    }
    
    func testDocumentByIdResource() {
        let resource = APIResource<[Document]>(method: .document(id: "c292af40-d06a-11e2-9a2f-000000000000"),
                                               apiDomain: .api,
                                               httpMethod: .get)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
            "/documents/c292af40-d06a-11e2-9a2f-000000000000", "path should match")
    }
    
    func testDocumentCreation() {
        let resource = APIResource<[Document]>(method: .createDocument(fileName: "invoice.jpg",
                                                                       docType: "Invoice",
                                                                       mimeSubType: "jpeg",
                                                                       documentType: .partial(Data(count: 0))),
                                               apiDomain: .api,
                                               httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
            "/documents/?filename=invoice.jpg&doctype=Invoice", "path should match")
    }
    
    func testDocumentCreationWithoutFilename() {
        let resource = APIResource<[Document]>(method: .createDocument(fileName: nil,
                                                                       docType: "Invoice",
                                                                       mimeSubType: "jpeg",
                                                                       documentType: .partial(Data(count: 0))),
                                               apiDomain: .api,
                                               httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
            "/documents/?doctype=Invoice", "path should match")
    }
    
    func testDocumentCreationWithoutDoctype() {
        let resource = APIResource<[Document]>(method: .createDocument(fileName: "invoice.jpg",
                                                                       docType: nil,
                                                                       mimeSubType: "jpeg",
                                                                       documentType: .partial(Data(count: 0))),
                                               apiDomain: .api,
                                               httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
            "/documents/?filename=invoice.jpg", "path should match")
    }
    
    func testDocumentCreationWithoutQueryParameters() {
        let resource = APIResource<[Document]>(method: .createDocument(fileName: nil,
                                                                       docType: nil,
                                                                       mimeSubType: "jpeg",
                                                                       documentType: .partial(Data(count: 0))),
                                               apiDomain: .api,
                                               httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
            "/documents/", "path should match")
    }
    
    func testDocumentCreationContentTypeV1() {
        let resource = APIResource<[Document]>(method: .createDocument(fileName: nil,
                                                                       docType: nil,
                                                                       mimeSubType: "jpeg",
                                                                       documentType: nil),
                                               apiDomain: .accounting,
                                               httpMethod: .post)
        let contentType = resource.defaultHeaders["Content-Type"]!
        XCTAssertEqual(contentType, "application/vnd.gini.v1+jpeg", "content type should match")
    }
    
    func testDocumentCreationContentTypeV2Partial() {
        let resource = APIResource<[Document]>(method: .createDocument(fileName: nil,
                                                                       docType: nil,
                                                                       mimeSubType: "jpeg",
                                                                       documentType: .partial(Data(count: 0))),
                                               apiDomain: .api,
                                               httpMethod: .post)
        let contentType = resource.defaultHeaders["Content-Type"]!
        XCTAssertEqual(contentType, "application/vnd.gini.v2.partial+jpeg", "content type should match")
    }
    
    func testDocumentCreationContentTypeV2Composite() {
        let compositeDocumentInfo = CompositeDocumentInfo(partialDocuments: [])
        let resource = APIResource<[Document]>(method: .createDocument(fileName: nil,
                                                                       docType: nil,
                                                                       mimeSubType: "jpeg",
                                                                       documentType: .composite(compositeDocumentInfo)),
                                               apiDomain: .api,
                                               httpMethod: .post)
        let contentType = resource.defaultHeaders["Content-Type"]!
        XCTAssertEqual(contentType, "application/vnd.gini.v2.composite+jpeg", "content type should match")
    }
    
    func testExtractionsForDocumentIDResource() {
        let resource = APIResource<Token>(method: .extractions(forDocumentId: "c292af40-d06a-11e2-9a2f-000000000000"),
                                          apiDomain: .api,
                                          httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
            "/documents/c292af40-d06a-11e2-9a2f-000000000000/extractions", "path should match")
    }
    
    func testExtractionsForDocumentIDWithLabelResource() {
        let resource = APIResource<Token>(method: .extraction(withLabel: "amountToPay",
                                                              documentId: "c292af40-d06a-11e2-9a2f-000000000000"),
                                          apiDomain: .api,
                                          httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
            "/documents/c292af40-d06a-11e2-9a2f-000000000000/extractions/amountToPay",
                       "path should match")
    }
    
    func testPagesForDocumentIDResource() {
        let resource = APIResource<Token>(method: .pages(forDocumentId: "c292af40-d06a-11e2-9a2f-000000000000"),
                                          apiDomain: .api,
                                          httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
            "/documents/c292af40-d06a-11e2-9a2f-000000000000/pages", "path should match")
    }
    
    func testLayoutForDocumentIDResource() {
        let resource = APIResource<Token>(method: .layout(forDocumentId: "c292af40-d06a-11e2-9a2f-000000000000"),
                                          apiDomain: .api,
                                          httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/layout", "path should match")
    }
    
    func testProcessedDocumentWithIdResource() {
        let resource = APIResource<Token>(method: .processedDocument(withId: "c292af40-d06a-11e2-9a2f-000000000000"),
                                          apiDomain: .api,
                                          httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/processed",
                       "path should match")
    }
    
    func testErrorReportWOParametersResource() {
        let resource =
            APIResource<Token>(method: .errorReport(forDocumentWithId: "c292af40-d06a-11e2-9a2f-000000000000",
                                                    summary: nil,
                                                    description: nil),
                               apiDomain: .api,
                               httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/errorreport",
                       "path should match")
    }
    
    func testErrorReportWithSummaryParametersResource() {
        let resource =
            APIResource<Token>(method: .errorReport(forDocumentWithId: "c292af40-d06a-11e2-9a2f-000000000000",
                                                    summary: "Extractions Empty",
                                                    description: nil),
                               apiDomain: .api,
                               httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/errorreport?" +
            "summary=Extractions%20Empty",
                       "path should match")
    }
    
    func testErrorReportWithDescriptionResource() {
        let resource =
            APIResource<Token>(method: .errorReport(forDocumentWithId: "c292af40-d06a-11e2-9a2f-000000000000",
                                                    summary: nil,
                                                    description: "Despite the submitted remittance slip"),
                               apiDomain: .api,
                               httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/errorreport?" +
            "description=Despite%20the%20submitted%20remittance%20slip",
                       "path should match")
    }
    
    func testErrorReportWithSummaryAndDescriptionParametersResource() {
        let resource =
            APIResource<Token>(method: .errorReport(forDocumentWithId: "c292af40-d06a-11e2-9a2f-000000000000",
                                                    summary: "Extractions Empty",
                                                    description: "Despite the submitted remittance slip"),
                               apiDomain: .api,
                               httpMethod: .get)
        
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/errorreport?" +
            "summary=Extractions%20Empty&description=Despite%20the%20submitted%20remittance%20slip",
                       "path should match")
    }
    
}
