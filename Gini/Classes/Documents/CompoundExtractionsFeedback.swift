//
//  CompoundExtractionsFeedback.swift
//  Gini
//
//  Created by Alpár Szotyori on 27/08/20.
//

import Foundation

struct CompoundExtractionsFeedback {
    let extractions: [Extraction]
    let compoundExtractions: [String: [[Extraction]]]
}

// MARK: - Encodable

extension CompoundExtractionsFeedback: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case extractions
        case compoundExtractions
    }
    
    private struct StringKey: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var extractionsContainer = container.nestedContainer(keyedBy: StringKey.self, forKey: .extractions)
        
        try extractions.forEach { extraction in
            guard let name = extraction.name,
                let nameKey = StringKey(stringValue: name),
                let valueKey = StringKey(stringValue: "value") else {
                throw GiniError.parseError
            }
            
            var extractionContainer = extractionsContainer.nestedContainer(keyedBy: StringKey.self, forKey: nameKey)
            
            try extractionContainer.encode(extraction.value, forKey: valueKey)
        }
        
        var compoundExtractionsContainer = container.nestedContainer(keyedBy: StringKey.self, forKey: .compoundExtractions)
        
        try compoundExtractions.forEach { (name, compoundExtractions) in
            guard let nameKey = StringKey(stringValue: name) else {
                throw GiniError.parseError
            }
            
            var compoundExtractionsContainer = compoundExtractionsContainer.nestedUnkeyedContainer(forKey: nameKey)
            
            try compoundExtractions.forEach { compoundExtraction in
                var compoundExtractionContainer = compoundExtractionsContainer.nestedContainer(keyedBy: StringKey.self)
                
                try compoundExtraction.forEach { extraction in
                    guard let name = extraction.name,
                        let nameKey = StringKey(stringValue: name),
                        let valueKey = StringKey(stringValue: "value") else {
                        throw GiniError.parseError
                    }
                    
                    var extractionContainer = compoundExtractionContainer.nestedContainer(keyedBy: StringKey.self, forKey: nameKey)
                    
                    try extractionContainer.encode(extraction.value, forKey: valueKey)
                }
            }
            
        }
    }
}
