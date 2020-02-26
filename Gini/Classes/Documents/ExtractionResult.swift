//
//  ExtractionResult.swift
//  Gini
//
//  Created by Maciej Trybilo on 13.02.20.
//

import Foundation

@objcMembers final public class ExtractionResult: NSObject {

    public let extractions: [Extraction]
    public var lineItems: [[Extraction]]?
    
    public init(extractions: [Extraction], lineItems: [[Extraction]]?) {
        self.extractions = extractions
        self.lineItems = lineItems
        
        super.init()
    }
    
    convenience init(extractionsContainer: ExtractionsContainer) {
        
        self.init(extractions: extractionsContainer.extractions,
                  lineItems: extractionsContainer.compoundExtractions?["lineItems"])
    }
}
