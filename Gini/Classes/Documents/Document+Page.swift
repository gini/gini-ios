//
//  Document+Page.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

extension Document.Page: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pageNumber = try container.decode(Int.self, forKey: .number)
        let images = try container.decode([String: String].self, forKey: .images)
        
        let imagesFormatted = images.map { image in
            return (image.key, URL(string: image.value)!)
        }
        
        self.init(number: pageNumber, images: imagesFormatted)
    }
}
