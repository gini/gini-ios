//
//  PartialDocument.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

public struct PartialDocumentInfo {
    public var document: URL?
    public var rotationDelta: Int
    
    public var id: String? {
        guard let id = document?.absoluteString.split(separator: "/").last else { return nil }
        return String(id)
    }

    enum CodingKeys: String, CodingKey {
        case document
        case rotationDelta
    }
    
    public init(document: URL?, rotationDelta: Int = 0) {
        self.document = document
        self.rotationDelta = rotationDelta
    }
}

// MARK: - Decodable

extension PartialDocumentInfo: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        document = try container.decode(URL.self, forKey: .document)
        rotationDelta = try container.decodeIfPresent(Int.self, forKey: .rotationDelta) ?? 0
    }
}
