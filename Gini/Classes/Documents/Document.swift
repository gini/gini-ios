//
//  Document.swift
//  Pods-GiniExample
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

public enum DocumentTypeV2 {
    case partial(Data)
    case composite(CompositeDocumentInfo)
    
    var name: String {
        switch self {
        case .partial:
            return "partial"
        case .composite:
            return "composite"
        }
    }
}

public struct Document {

    let compositeDocuments: [CompositeDocument]?
    let creationDate: Date
    let id: String
    let name: String
    let origin: Origin
    let pageCount: Int
    let pages: [Page]?
    let links: Links
    let partialDocuments: [PartialDocumentInfo]?
    let progress: Progress
    let sourceClassification: SourceClassification

    fileprivate enum Keys: String, CodingKey {
        case compositeDocuments
        case creationDate
        case id
        case links = "_links"
        case name
        case origin
        case pageCount
        case pages
        case partialDocuments
        case progress
        case sourceClassification
    }
}

// MARK: - Inner types

extension Document {
    enum Progress: String, Decodable {
        case completed = "COMPLETED"
        case pending = "PENDING"
        case error = "ERROR"
    }
    
    enum Origin: String, Decodable {
        case upload = "UPLOAD"
        case unknown = "UNKNOWN"
    }
    
    enum SourceClassification: String, Decodable {
        case composite = "COMPOSITE"
        case native = "NATIVE"
        case scanned = "SCANNED"
        case sandwich = "SANDWICH"
        case text = "TEXT"
    }
    
    public struct Links {
        let extractions: URL
        let layout: URL
        let processed: URL
        let document: URL
        let pages: URL?
    }
    
    public struct Layout {
        let pages: [Page]
    }
    
    public struct Page {
        
        let number: Int
        let images: [(quality: String, url: URL)]
        
        //swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case number = "pageNumber"
            case images
        }
        
    }
}

// MARK: - Decodable

extension Document: Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let compositeDocuments = try container.decodeIfPresent([CompositeDocument].self, forKey: .compositeDocuments)
        let creationDate = try container.decode(Date.self, forKey: .creationDate)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let origin = try container.decode(Origin.self, forKey: .origin)
        let pageCount = try container.decode(Int.self, forKey: .pageCount)
        let pages = try container.decodeIfPresent([Page].self, forKey: .pages)
        let links = try container.decode(Links.self, forKey: .links)
        let partialDocuments = try container.decodeIfPresent([PartialDocumentInfo].self, forKey: .partialDocuments)
        let progress = try container.decode(Progress.self, forKey: .progress)
        let sourceClassification = try container.decode(SourceClassification.self,
                                                        forKey: .sourceClassification)

        self.init(compositeDocuments: compositeDocuments,
                  creationDate: creationDate,
                  id: id,
                  name: name,
                  origin: origin,
                  pageCount: pageCount,
                  pages: pages,
                  links: links,
                  partialDocuments: partialDocuments,
                  progress: progress,
                  sourceClassification: sourceClassification)
    }
}

extension Document.Links: Decodable {
    
}

extension Document.Layout: Decodable {
    
}
