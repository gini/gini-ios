//
//  DocumentPage.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

extension Document {
    public struct Page {
        
        let number: Int
        let images: [(quality: String, url: URL)]
        
        fileprivate enum Keys: String, CodingKey {
            case number = "pageNumber"
            case images
        }
        
    }
}

extension Document.Page: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let pageNumber = try container.decode(Int.self, forKey: .number)
        let images = try container.decode([String: String].self, forKey: .images)
        
        let imagesFormatted = images.map { image in
            return (image.key, URL(string: image.value)!)
        }
        
        self.init(number: pageNumber, images: imagesFormatted)
    }
}
