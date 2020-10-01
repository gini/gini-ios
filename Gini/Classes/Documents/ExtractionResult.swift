//
//  ExtractionResult.swift
//  Gini
//
//  Created by Maciej Trybilo on 13.02.20.
//

import Foundation

/**
* Data model for a document extraction result.
*/
@objcMembers final public class ExtractionResult: NSObject {

    /// The specific extractions.
    public let extractions: [Extraction]
    
    /// The extraction candidates.
    public let candidates: [String: [Extraction.Candidate]]
        
    public init(extractions: [Extraction], candidates: [String: [Extraction.Candidate]]) {
        self.extractions = extractions
        self.candidates = candidates
        
        super.init()
    }
    
    convenience init(extractionsContainer: ExtractionsContainer) {
        
        self.init(extractions: extractionsContainer.extractions,
                  candidates: extractionsContainer.candidates)
    }
}
