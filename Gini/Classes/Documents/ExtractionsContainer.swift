//
//  ExtractionsContainer.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

struct ExtractionsContainer {
    let extractions: [Extraction]
    let candidates: [Extraction.Candidate]
    
    enum CodingKeys: String, CodingKey {
        case extractions
        case candidates
    }
}

// MARK: - Decodable

extension ExtractionsContainer: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let extractions = try container.decode([String: Extraction].self, forKey: .extractions)
        let candidates = try container.decodeIfPresent([String: [Extraction.Candidate]].self,
                                                       forKey: .candidates) ?? [:]
        
        self.extractions = extractions.map {
            let extraction = $0.value
            extraction.name = $0.key
            return extraction
        }
        self.candidates = candidates.flatMap { $0.value }
    }
}
