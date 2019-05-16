//
//  ExtractionsContainerTest.swift
//  Gini-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import XCTest
@testable import Gini

final class ExtractionsContainerTest: XCTestCase {
    
    lazy var extractionsContainerJson = loadFile(withName: "extractionsContainer", ofType: "json")
    lazy var extractionsWOCandidatesJson = loadFile(withName: "extractionsContainerWOCandidates", ofType: "json")
    
    func testExtractionsContainerdecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(ExtractionsContainer.self, from: extractionsContainerJson),
                         "extractions container should be decoded")
    }
    
    func testExtractionsContainerWOCandidatesdecoding() {
        XCTAssertNoThrow(try JSONDecoder().decode(ExtractionsContainer.self, from: extractionsWOCandidatesJson),
                         "extractions container without candidates should be decoded")
    }

}
