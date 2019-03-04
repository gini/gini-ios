//
//  GiniError.swift
//  GiniAPISDK
//
//  Created by Enrique del Pozo Gómez on 1/24/18.
//

import Foundation

public enum GiniError: Error {
    case badRequest, noResponse, parseError, unauthorized, unknown
}
