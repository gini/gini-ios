//
//  CompositeDocumentInfo.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

public struct CompositeDocumentInfo {
    let partialDocuments: [PartialDocumentInfo]
}

// MARK: - Decodable

extension CompositeDocumentInfo: Encodable {
    
}
