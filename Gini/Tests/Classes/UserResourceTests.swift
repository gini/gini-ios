//
//  UserResourceTests.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import Gini

class UserResourceTests: XCTestCase {
    
    let baseUserCenterAPIURLString = "https://user.gini.net"
    let requestParameters = RequestParameters(method: .get,
                                              headers: ["Accept": "application/vnd.gini.v1+json"])
    
    func testTokenResourceWithClientCredentials() {
        let resource = UserResource<Token>(method: .token(grantType: .clientCredentials), httpMethod: .get)
        let urlString: String = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/oauth/token?grant_type=client_credentials")
    }
    
    func testTokenResourceWithPassword() {
        let resource = UserResource<Token>(method: .token(grantType: .password), httpMethod: .get)
        let urlString: String = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/oauth/token?grant_type=password")
    }
    
    func testUsersResource() {
        let resource = UserResource<Token>(method: .users, httpMethod: .post)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/api/users")
    }
    
}