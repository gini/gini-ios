//
//  SessionManagerMock.swift
//  GiniAPISDKExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import Foundation
@testable import GiniAPISDK

final class SessionManagerMock: SessionManagerProtocol {
    let urlResponse = HTTPURLResponse(url: URL(string: "http://www.gini.net")!,
                                      statusCode: 200,
                                      httpVersion: "1.2",
                                      headerFields: [:])!
    
    init(authService: AuthServiceProtocol) {
        
    }
    
    func load<T: Resource>(resource: T, completion: @escaping (Result<T.ResponseType>) -> Void) {
        var data: Data?
        if let resource = resource as? UserResource<Token> {
            switch resource {
            case .token:
                data = ("{\"access_token\":\"1eb7ca49-d99f-40cb-b86d-8dd689ca2345\"," +
                    "\"token_type\":\"bearer\",\"expires_in\":43199,\"scope\":\"read\"}").data(using: .utf8)!
 
            default: break
            }
        } else if let resource = resource as? UserResource<Token> {
            switch resource {
            case .users:
                data = "https://user.gini.net/api/users/c1e60c6b-a0a4-4d80-81eb-c1c6de729a0e".data(using: .utf8)!
            default: break
            }
        }
        
        if let data = data {
            let result: T.ResponseType = resource.parsedResponse(data: data, urlResponse: urlResponse)!
            completion(.success(result))
        } else {
            completion(.failure(.unknown))
        }

    }
}
