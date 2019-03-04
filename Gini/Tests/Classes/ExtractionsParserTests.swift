//
//  GINIExtractionsParserTests.swift
//  GiniAPISDKExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniAPISDK

final class ExtractionsParserTests: XCTestCase {
    
    lazy var extractions: [Extraction] = {
        let jsonData = loadFile(withName: "extractions", ofType: "json")
        let extractionsParser = ExtractionsParser()
        let extractions = extractionsParser.parse(extractionsJSON: jsonData)
        return extractions
    }()
    
    lazy var extractionsWOCandidates: [Extraction] = {
        let jsonData = loadFile(withName: "extractionsWOCandidates", ofType: "json")
        let extractionsParser = ExtractionsParser()
        let extractions = extractionsParser.parse(extractionsJSON: jsonData)
        return extractions
    }()
    
    lazy var extractionsWOMatchingCandidates: [Extraction] = {
        let jsonData = loadFile(withName: "extractionsWOMatchingCandidates", ofType: "json")
        let extractionsParser = ExtractionsParser()
        let extractions = extractionsParser.parse(extractionsJSON: jsonData)
        return extractions
    }()
    
    func testExtractionCount() {
        XCTAssertEqual(extractions.count, 1, "extractions count should be 1")
    }
    
    func testFirstExtractionCandidatesCount() {
        XCTAssertEqual(extractions[0].candidates?.count, 2,
                       "candidates count on first extraction should be 2")
    }
    
    func testFirstExtractionCandidatesCountWhenNoCandidates() {
        XCTAssertNil(extractionsWOCandidates[0].candidates, "candidates should be nil")
    }
    
    func testFirstExtractionCandidatesCountWhenNoMatchingCandidates() {
        XCTAssertNotNil(extractionsWOMatchingCandidates[0].candidates, "candidates should be nil")
    }
    
}
