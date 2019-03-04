//
//  GiniDocument.swift
//  Pods-GiniAPISDKExample
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

enum DocumentStatus: String, Decodable {
    case completed = "COMPLETED"
    case pending = "PENDING"
    case error = "ERROR"
}

enum DocumentOrigin: String, Decodable {
    case upload = "UPLOAD"
    case unknown = "UNKNOWN"
}

enum DocumentType: String, Decodable {
    case scanned = "SCANNED"
    case sandwich = "SANDWICH"
    case native = "NATIVE"
    case text = "TEXT"
}

public struct GiniDocument {

    let creationDate: Date
    let id: String
    let name: String
    let origin: DocumentOrigin
    let pageCount: Int
    let pages: [DocumentPage]
    let resources: DocumentLinks
    let status: DocumentStatus
    let type: DocumentType

    fileprivate enum Keys: String, CodingKey {
        case creationDate
        case id
        case name
        case origin
        case pageCount
        case pages
        case resources = "_links"
        case status = "progress"
        case type = "sourceClassification"
    }
}

extension GiniDocument: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let creationDate = try container.decode(Date.self, forKey: .creationDate)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let origin = try container.decode(DocumentOrigin.self, forKey: .origin)
        let pageCount = try container.decode(Int.self, forKey: .pageCount)
        let pages = try container.decode([DocumentPage].self, forKey: .pages)
        let resources = try container.decode(DocumentLinks.self, forKey: .resources)
        let status = try container.decode(DocumentStatus.self, forKey: .status)
        let type = try container.decode(DocumentType.self, forKey: .type)

        self.init(creationDate: creationDate,
                  id: id,
                  name: name,
                  origin: origin,
                  pageCount: pageCount,
                  pages: pages,
                  resources: resources,
                  status: status,
                  type: type)
    }
}
