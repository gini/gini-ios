//
//  AuthServiceTests.swift
//  GiniAPISDKExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import XCTest
@testable import GiniAPISDK

final class AuthServiceTests: XCTestCase {
    
    let authService: AuthService = {
        let client = Client(id: "client_id", password: "client_password")
        
        // Preload the keychain with the given credentials
        let keychainStore = KeychainStoreMock()
        keychainStore.save(credentials: client)
        
        let authService = AuthService(clientId: client.id,
                                      keyStore: keychainStore)
        return authService
    }()
    
    func testInitialization() {
        let client = authService.client
        XCTAssertEqual(client.id, "client_id", "client id should match")
        XCTAssertEqual(client.password, "client_password", "password should match")
        let user = authService.user
        XCTAssertNil(user?.id, "user id should be nil")
        XCTAssertNil(user?.password, "user password should be nil")
    }
    
    func testInitializationWithUser() {
        let client = Client(id: "client_id", password: "client_password")
        let user = User(email: "test@email.com", password: "testPassword")
        
        // Preload the keychain with the given credentials
        let keychainStore = KeychainStoreMock()
        keychainStore.save(credentials: client)
        keychainStore.save(credentials: user)
        
        let authService = AuthService(clientId: client.id,
                                      userId: user.id,
                                      keyStore: keychainStore)
        let clientService = authService.client
        XCTAssertEqual(clientService.id, "client_id", "client id should match")
        XCTAssertEqual(clientService.password, "client_password", "password should match")
        let userService = authService.user
        XCTAssertEqual(userService?.id, "test@email.com", "user id should match")
        XCTAssertEqual(userService?.password, "testPassword", "user password should match")
    }
    
    func testObtainClientToken() {
        let tokenExpectation = expectation(description: "wait until get token")
        authService.obtainUserCenterToken(sessionManager: SessionManagerMock(authService: authService)) { token in
            switch token {
            case .success(let token):
                XCTAssertEqual(token.accessToken, "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                               "token should match the one obtained in the session manager")
            case .failure:
                XCTFail("this request should not fail")
            }
            tokenExpectation.fulfill()
        }
        wait(for: [tokenExpectation], timeout: 5)
    }
    
    func testCreateUser() {
        let tokenExpectation = expectation(description: "wait until create user")
        let user = User(email: "test@test.com", password: "passwordTest")
        let data = ("{\"access_token\":\"1eb7ca49-d99f-40cb-b86d-8dd689ca2345\"," +
            "\"token_type\":\"bearer\",\"expires_in\":43199,\"scope\":\"read\"}").data(using: .utf8)!
        let accessToken = try? JSONDecoder().decode(Token.self, from: data)
        
        authService.create(user: user, withToken: accessToken!,
                           sessionManager: SessionManagerMock(authService: authService)) { result in
            switch result {
            case .success:
                XCTAssert(true, "the request should not fail")
            case .failure:
                XCTFail("this request should not fail")
            }

            tokenExpectation.fulfill()
        }
        wait(for: [tokenExpectation], timeout: 5)
    }
    
    func testLoginAsUser() {
        let tokenExpectation = expectation(description: "wait until logged in as user")
        let user = User(email: "test@test.com", password: "passwordTest")
        
        authService.login(asUser: user,
                          sessionManager: SessionManagerMock(authService: authService)) { token in
            switch token {
            case .success(let token):
                XCTAssertEqual(token.accessToken, "1eb7ca49-d99f-40cb-b86d-8dd689ca2345",
                               "token should match the one obtained in the session manager")
            case .failure:
                XCTFail("this request should not fail")
            }
            
            tokenExpectation.fulfill()
        }
        wait(for: [tokenExpectation], timeout: 5)
    }
}
