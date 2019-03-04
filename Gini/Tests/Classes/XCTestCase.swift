//
//  XCTestCase.swift
//  GiniAPISDKExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest

internal extension XCTestCase {
    func loadFile(withName name: String, ofType type: String) -> Data {
        let fileURLPath: String? = Bundle(for: GiniDocumentTests.self)
            .path(forResource: name, ofType: type)
        let data = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
        
        return data!
    }
}
