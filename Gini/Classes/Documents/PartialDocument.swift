//
//  PartialDocument.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

struct PartialDocument {
    let document: URL
    let rotationDelta: Int

    enum CodingKeys: String, CodingKey {
        case document
        case rotationDelta
    }
}

// MARK: - Decodable

extension PartialDocument: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        document = try container.decode(URL.self, forKey: .document)
        rotationDelta = try container.decodeIfPresent(Int.self, forKey: .rotationDelta) ?? 0
    }
}
