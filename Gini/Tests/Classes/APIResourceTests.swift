//
//  APIResource.swift
//  GiniAPISDKExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/18/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniAPISDK

// TODO: this are not the correct types (AccessToken). Change all of them

final class APIResourceTests: XCTestCase {
    
    let baseAPIURLString = "https://api.gini.net"
    let requestParameters = RequestParameters(method: .get,
                                              headers: ["Accept": "application/vnd.gini.v1+json"])
    
    func testDocumentsResource() {
        let resource: APIResource<Token> = APIResource.documents(limit: nil,
                                                                       offset: nil,
                                                                       requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/documents", "path should match")
    }
    
    func testDocumentsWithLimitResource() {
        let resource: APIResource<Token> = APIResource.documents(limit: 1,
                                                                       offset: nil,
                                                                       requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/documents?limit=1", "path should match")
    }
    
    func testDocumentsWithOffsetResource() {
        let resource: APIResource<Token> = APIResource.documents(limit: nil,
                                                                       offset: 2,
                                                                       requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/documents?offset=2", "path should match")
    }
    
    func testDocumentsWithLimitAndOffsetResource() {
        let resource: APIResource<Token> = APIResource.documents(limit: 1,
                                                                       offset: 2,
                                                                       requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString + "/documents?limit=1&offset=2",
                       "path should match")
    }
    
    func testDocumentsByIdResource() {
        let resource: APIResource<Token> = APIResource.document(withId: "c292af40-d06a-11e2-9a2f-000000000000",
                                                                      requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
                       "/documents/c292af40-d06a-11e2-9a2f-000000000000", "path should match")
    }
    
    func testExtractionsForDocumentIDResource() {
        let resource: APIResource<Token> = APIResource
            .extractions(forDocumentId: "c292af40-d06a-11e2-9a2f-000000000000",
                         requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
                       "/documents/c292af40-d06a-11e2-9a2f-000000000000/extractions", "path should match")
    }
    
    func testExtractionsForDocumentIDWithLabelResource() {
        let resource: APIResource<Token> = APIResource
            .extraction(withLabel: "amountToPay",
                        documentId: "c292af40-d06a-11e2-9a2f-000000000000",
                        requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
                       "/documents/c292af40-d06a-11e2-9a2f-000000000000/extractions/amountToPay",
                       "path should match")
    }
    
    func testPagesForDocumentIDResource() {
        let resource: APIResource<Token> = APIResource
            .pages(forDocumentId: "c292af40-d06a-11e2-9a2f-000000000000",
                   requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseAPIURLString +
                       "/documents/c292af40-d06a-11e2-9a2f-000000000000/pages", "path should match")
    }
    
    func testLayoutForDocumentIDResource() {
        let resource: APIResource<Token> = APIResource
            .layout(forDocumentId: "c292af40-d06a-11e2-9a2f-000000000000",
                    requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/layout", "path should match")
    }
    
    func testProcessedDocumentWithIdResource() {
        let resource: APIResource<Token> = APIResource
            .processedDocument(withId: "c292af40-d06a-11e2-9a2f-000000000000",
                               requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/processed",
                       "path should match")
    }
    
    func testErrorReportWOParametersResource() {
        let resource: APIResource<Token> = APIResource
            .errorReport(forDocumentWithId: "c292af40-d06a-11e2-9a2f-000000000000",
                         summary: nil,
                         description: nil,
                         requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/errorreport",
                       "path should match")
    }
    
    func testErrorReportWithSummaryParametersResource() {
        let resource: APIResource<Token> = APIResource
            .errorReport(forDocumentWithId: "c292af40-d06a-11e2-9a2f-000000000000",
                         summary: "Extractions Empty",
                         description: nil,
                         requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/errorreport?" +
            "summary=Extractions%20Empty",
                       "path should match")
    }
    
    func testErrorReportWithDescriptionResource() {
        let resource: APIResource<Token> = APIResource
            .errorReport(forDocumentWithId: "c292af40-d06a-11e2-9a2f-000000000000",
                         summary: nil,
                         description: "Despite the submitted remittance slip",
                         requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/errorreport?" +
            "description=Despite%20the%20submitted%20remittance%20slip",
                       "path should match")
    }
    
    func testErrorReportWithSummaryAndDescriptionParametersResource() {
        let resource: APIResource<Token> = APIResource
            .errorReport(forDocumentWithId: "c292af40-d06a-11e2-9a2f-000000000000",
                         summary: "Extractions Empty",
                         description: "Despite the submitted remittance slip",
                         requestParams: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString,
                       baseAPIURLString + "/documents/c292af40-d06a-11e2-9a2f-000000000000/errorreport?" +
            "summary=Extractions%20Empty&description=Despite%20the%20submitted%20remittance%20slip",
                       "path should match")
    }
    
}
