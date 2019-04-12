//
//  Extraction.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

/**
 * Data model for a document extraction.
 */
public struct Extraction {
    
    /// The extraction's box. Only available for some extractions.
    public let box: Box?
    /// The available candidates for this extraction.
    public let candidates: String?
    /// The extraction's entity.
    public let entity: String
    /// The extraction's value
    public var value: String
    /// The extraction's name
    public var name: String?
    
    /// The extraction's box attributes.
    public struct Box {
        let height: Double
        let left: Double
        let page: Int
        let top: Double
        let width: Double
    }
    
    /// A extraction candidate, containing a box, an entity and a its value.
    public struct Candidate {
        let box: Box?
        let entity: String
        let value: String
    }
    
    public init(box: Box?, candidates: String?, entity: String, value: String, name: String?) {
        self.box = box
        self.candidates = candidates
        self.entity = entity
        self.value = value
        self.name = name
    }
    
}

// MARK: - Decodable

extension Extraction: Decodable {
    
}

extension Extraction.Box: Decodable {
    
}

extension Extraction.Candidate: Decodable {
    
}
