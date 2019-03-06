//
//  Extraction.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

public struct Extraction {
    
    let box: ExtractionBox?
    var candidates: [Extraction]?
    let candidatesReference: String?
    let entity: String
    let name: String
    let value: String
    
    fileprivate enum Keys: String, CodingKey {
        case box
        case candidatesReference = "candidates"
        case entity
        case name
        case value
    }
    
}

extension Extraction: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let box = try container.decodeIfPresent(ExtractionBox.self, forKey: .box)
        let candidatesReference = try container.decodeIfPresent(String.self, forKey: .candidatesReference)
        let entity = try container.decode(String.self, forKey: .entity)
        let name = try container.decode(String.self, forKey: .name)
        let value = try container.decode(String.self, forKey: .value)
        
        self.init(box: box,
                  candidates: nil,
                  candidatesReference: candidatesReference,
                  entity: entity,
                  name: name,
                  value: value)
    }
}
