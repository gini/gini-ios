//
//  ContentType.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 3/5/19.
//

import Foundation

enum ContentType: String {
    case json = "application/json"
    case v1Json = "application/vnd.gini.v1+json"
    case v2Json = "application/vnd.gini.v2+json"
    case formUrlEncoded = "application/x-www-form-urlencoded"

}
