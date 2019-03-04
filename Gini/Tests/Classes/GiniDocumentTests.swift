//
//  GiniDocumentTests.swift
//  GiniAPISDKExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniAPISDK

final class GiniDocumentTests: XCTestCase {
    
    lazy var validDocument: GiniDocument = {
        let jsonData: Data = loadFile(withName: "document", ofType: "json")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let giniDocument = try? decoder.decode(GiniDocument.self, from: jsonData)
        return giniDocument!
    }()
    let invalidJSON: Data = "invalid json".data(using: .utf8)!
    let incompleteJSON: Data = {
        """
        {
            "id": "626626a0-749f-11e2-bfd6-000000000000",
            "creationDate": 1515932941.2839971,
            "progress": "COMPLETED",
            "origin": "UPLOAD",
            "sourceClassification": "SCANNED",
            "pageCount": 1,
            "pages" : [
            {
            "images" : {
            "750x900" : "http://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/pages/1/750x900",
            "1280x1810" : "http://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/pages/1/1280x1810"
            },
            "pageNumber" : 1
            }
            ],
            "_links": {
            "extractions": "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/extractions",
            "layout": "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/layout",
            "document": "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000",
            "processed": "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/processed"
            }
        }
        """.data(using: .utf8)!
    }()
    
    func testID() {
        XCTAssertEqual(validDocument.id,
                       "626626a0-749f-11e2-bfd6-000000000000",
                       "document ID should match")
    }
    
    func testCreationDate() {
        XCTAssertEqual(validDocument.creationDate.timeIntervalSince1970,
                       1515932941.2839971,
                       "document creationDate should match")
    }
    
    func testName() {
        XCTAssertEqual(validDocument.name, "scanned.jpg", "document name should match")
    }
    
    func testStatus() {
        XCTAssertEqual(validDocument.status, .completed, "document status should match")
    }
    
    func testOrigin() {
        XCTAssertEqual(validDocument.origin, .upload, "document origin should match")
    }
    
    func testType() {
        XCTAssertEqual(validDocument.type, .scanned, "document type should match")
    }
    
    func testPageCount() {
        XCTAssertEqual(validDocument.pageCount, 1, "document pageCount should be 1")
    }
    
    func testPages() {
        XCTAssertEqual(validDocument.pages.count, validDocument.pageCount,
                       "document pageCount and pages count should match")
        XCTAssertEqual(validDocument.pages[0].number, 1, "first page number should be 1")
        XCTAssertEqual(validDocument.pages[0].images.count, 2, "first page images count should be 2")
    }
    
    func testResources() {
        XCTAssertEqual(validDocument.resources.extractions.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/extractions",
                       "document extractions resource should match")
        XCTAssertEqual(validDocument.resources.layout.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/layout",
                       "document layout resource should match")
        XCTAssertEqual(validDocument.resources.document.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000",
                       "document document resource should match")
        XCTAssertEqual(validDocument.resources.processed.absoluteString,
                       "https://api.gini.net/documents/626626a0-749f-11e2-bfd6-000000000000/processed",
                       "document processed resource should match")
    }
    
    func testIncompleteJSONDecoding() {
        let giniDocument = try? JSONDecoder().decode(GiniDocument.self, from: incompleteJSON)
        XCTAssertNil(giniDocument, "document should be nil since one of its properties is missing")
    }
    
    func testInvalidJSONDecoding() {
        let giniDocument = try? JSONDecoder().decode(GiniDocument.self, from: invalidJSON)
        XCTAssertNil(giniDocument, "document should be nil since it is not a valid JSON")
    }
    
}

