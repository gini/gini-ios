//
//  DocumentLinks.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

public struct DocumentLinks {
    
    let extractions: URL
    let layout: URL
    let processed: URL
    let document: URL
    
    fileprivate enum Keys: String, CodingKey {
        case extractions
        case layout
        case processed
        case document
    }
}

extension DocumentLinks: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let extractionsPath = try container.decode(String.self, forKey: .extractions)
        let layoutPath = try container.decode(String.self, forKey: .layout)
        let processedPath = try container.decode(String.self, forKey: .processed)
        let documentPath = try container.decode(String.self, forKey: .document)
        
        self.init(extractions: URL(string: extractionsPath)!,
                  layout: URL(string: layoutPath)!,
                  processed: URL(string: processedPath)!,
                  document: URL(string: documentPath)!)

    }
}
