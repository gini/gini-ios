//
//  DocumentLinks.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

public struct DocumentLinks {
    
    let extractions: URL
    let layout: URL
    let processed: URL
    let document: URL
    let pages: URL?
}

extension DocumentLinks: Decodable {
    
}
