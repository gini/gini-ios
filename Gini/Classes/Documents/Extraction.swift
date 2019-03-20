//
//  Extraction.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

public struct Extraction {
    
    let box: ExtractionBox?
    let candidates: String?
    let entity: String
    let value: String
    var name: String?
    
}

extension Extraction: Decodable {
    
}
