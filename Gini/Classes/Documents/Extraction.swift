//
//  Extraction.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

public struct Extraction {
    
    let box: Box?
    let candidates: String?
    let entity: String
    let value: String
    var name: String?
    
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
    
}

// MARK: - Decodable

extension Extraction: Decodable {
    
}

extension Extraction.Box: Decodable {
    
}

extension Extraction.Candidate: Decodable {
    
}
