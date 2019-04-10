//
//  Extraction.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

public struct Extraction {
    
    public let box: Box?
    public let candidates: String?
    public let entity: String
    public let value: String
    public var name: String?
    
    public struct Box {
        let height: Double
        let left: Double
        let page: Int
        let top: Double
        let width: Double
    }
    
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
