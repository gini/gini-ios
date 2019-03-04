//
//  UserResourceTests.swift
//  GiniAPISDKExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniAPISDK

class UserResourceTests: XCTestCase {
    
    let baseUserCenterAPIURLString = "https://user.gini.net"
    let requestParameters = RequestParameters(method: .get,
                                              headers: ["Accept": "application/vnd.gini.v1+json"])
    
    func testTokenResourceWithClientCredentials() {
        let resource: UserResource<Token> = UserResource.token(grantType: "client_credentials",
                                         requestParameters: requestParameters)
        let urlString: String = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/oauth/token?grant_type=client_credentials")
    }
    
    func testTokenResourceWithPassword() {
        let resource: UserResource<Token> = UserResource.token(grantType: "password",
                                                                     requestParameters: requestParameters)
        let urlString: String = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/oauth/token?grant_type=password")
    }
    
    func testUsersResource() {
        // TODO: this is not the correct type (AccessToken)
        let resource: UserResource<Token> = UserResource.users(requestParameters: requestParameters)
        let urlString = resource.url.absoluteString
        XCTAssertEqual(urlString, baseUserCenterAPIURLString + "/api/users")
    }
    
}
