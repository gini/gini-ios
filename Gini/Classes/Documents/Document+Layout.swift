//
//  Document+Layout.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import Foundation

extension Document.Layout {
    struct Page: Decodable {
        let number: Int
        let sizeX, sizeY: Double
        let textZones: [TextZone]
        let regions: [Region]?
    }
    
    struct Region: Decodable {
        let l: Double
        let t, w, h: Double
        let type: String?
        let lines: [Region]?
        let wds: [Word]?
    }
    
    struct TextZone: Decodable {
        let paragraphs: [Region]
    }
    
    struct Word: Decodable {
        let l: Double
        let t, w, h, fontSize: Double
        let fontFamily: String
        let bold: Bool
        let text: String
    }
}
