//
//  GiniSDKTests.swift
//  Gini-Unit-Tests
//
//  Created by Alpár Szotyori on 03.04.20.
//

import XCTest
@testable import Gini

// swiftlint:disable force_cast

final class GiniSDKTests: XCTestCase {
    
    func testBuildWithCustomApiDomain() {
        let giniSdk = GiniSDK.Builder(client: Client(id: "", secret: "", domain: ""),
                                      api: .custom(domain: "custom-api.domain.com", tokenSource: nil),
                                      logLevel: .none)
            .build()
        
        let documentService: DefaultDocumentService = giniSdk.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")
    }
    
    func testBuildWithCustomUserDomain() {
        let giniSdk = GiniSDK.Builder(client: Client(id: "", secret: "", domain: ""),
                                      userApi: .custom(domain: "custom-user.domain.com"),
                                      logLevel: .none)
            .build()
        
        let documentService: DefaultDocumentService = giniSdk.documentService()
        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, "custom-user.domain.com")
    }
    
    func testBuildWithCustomApiAndUserDomain() {
        let giniSdk = GiniSDK.Builder(client: Client(id: "", secret: "", domain: ""),
                                      api: .custom(domain: "custom-api.domain.com", tokenSource: nil),
                                      userApi: .custom(domain: "custom-user.domain.com"),
                                      logLevel: .none)
            .build()
        
        let documentService: DefaultDocumentService = giniSdk.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")
        
        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertEqual(sessionManager.userDomain.domainString, "custom-user.domain.com")
    }
    
    func testWithCustomApiDomainAndAlternativeTokenSource() {
        let tokenSource = TokenSource()
        let giniSdk = GiniSDK.Builder(customApiDomain: "custom-api.domain.com",
                                      alternativeTokenSource: tokenSource,
                                      logLevel: .none)
            .build()
        
        let documentService: DefaultDocumentService = giniSdk.documentService()
        XCTAssertEqual(documentService.apiDomain.domainString, "custom-api.domain.com")
        
        let sessionManager: SessionManager = documentService.sessionManager as! SessionManager
        XCTAssertNotNil(sessionManager.alternativeTokenSource)
    }
    
    private class TokenSource: AlternativeTokenSource {
        func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
        }
    }
}
