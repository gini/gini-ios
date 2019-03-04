//
//  ExtractionsParser.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

/** TODO
 Add explanation
 http://developer.gini.net/gini-api/html/documents.html#retrieving-extractions
 */
final class ExtractionsParser {
    
    func parse(extractionsJSON: Data) -> [Extraction] {
        guard let json = try? JSONSerialization.jsonObject(with: extractionsJSON,
                                                           options: []),
            let jsonDict = json as? [String: Any],
            let extractionsDict = jsonDict["extractions"] as? [String: Any] else {
                return []
        }
        
        return extractionsFrom(dict: extractionsDict, withCandidates: jsonDict["candidates"] as? [String: Any])
    }
    
    fileprivate func extractionsFrom(dict: [String: Any],
                                     withCandidates candidates: [String: Any]?) -> [Extraction] {
        var extractions: [Extraction] = []
        dict.forEach {(key, value) in
            guard let extractionJSON = value as? [String: Any] else {
                return
            }
            if let extraction = extractionFor(json: extractionJSON, withName: key) {
                var extraction = extraction
                if let candidateReference = extraction.candidatesReference,
                    let candidates = candidates {
                    extraction.candidates = candidateExtractions(withReference: candidateReference,
                                                                 name: key,
                                                                 in: candidates)
                }
                extractions.append(extraction)
            }
        }
        
        return extractions
    }
    
    fileprivate func candidateExtractions(withReference reference: String,
                                          name: String,
                                          in candidatesDict: [String: Any]) -> [Extraction] {
        var candidates: [Extraction] = []
        if let candidateExtractions = candidatesDict[reference] as? [[String: Any]] {
            candidateExtractions.forEach { json in
                if let extraction = extractionFor(json: json, withName: name) {
                    candidates.append(extraction)
                }
            }
        }
        return candidates
    }
    
    fileprivate func extractionFor(json: [String: Any], withName name: String) -> Extraction? {
        var json = json
        json["name"] = name
        if let extractionJSONData = try? JSONSerialization.data(withJSONObject: json, options: []) {
            return try? JSONDecoder().decode(Extraction.self, from: extractionJSONData)
        }
        return nil
    }
}
