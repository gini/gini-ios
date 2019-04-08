//
//  CompositeDocument.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

public struct CompositeDocument {
    public let document: URL
    
    public var id: String? {
        guard let id = document.absoluteString.split(separator: "/").last else { return nil }
        return String(id)
    }
}

// MARK: - Decodable

extension CompositeDocument: Decodable {
    
}
