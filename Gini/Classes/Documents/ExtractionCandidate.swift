//
//  ExtractionCandidate.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/20/19.
//

import Foundation

public struct ExtractionCandidate {
    
    let box: ExtractionBox?
    let entity: String
    let value: String    
}

extension ExtractionCandidate: Decodable {
}
