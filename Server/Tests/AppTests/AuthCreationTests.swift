//
//  AuthCreationTests.swift
//
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import XCTest
import XCTVapor
@testable import App

final class AuthCreationTests: XCTestCase {
    
    private var app: Application!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testDecodeAuthCreation() throws {
        guard let fileURL = Bundle.module.url(forResource: "ece461DefaultAdmin", withExtension: "json", subdirectory: "MockData/Authentication") else {
            XCTFail("File not found")
            return
        }
        
        let data = try Data(contentsOf: fileURL)
        let auth = try JSONDecoder().decode(AuthenticationRequest.self, from: data)
        
        XCTAssertEqual(auth.user.name, "ece461defaultadmin")
        XCTAssertTrue(auth.user.isAdmin)
        XCTAssertEqual(auth.secret.password, "correcthorsebatterystaple123(!__+@**(A")
    }
    
    func testCreateUser() throws {
        try app.test(.POST, "authenticate", beforeRequest: { req in
            try req.content.encode(AuthenticationRequest.new())
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            XCTAssertEqual(res.headers.contentType, .json)
            print(res.body.string)
        })
    }
    
    func testCreateExistingUser() throws {
        try app.test(.POST, "authenticate", beforeRequest: { req in
            try req.content.encode(AuthenticationRequest.mock)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .internalServerError)
        })
    }
    
    func testPUTUserToken() throws {
        try app.test(.PUT, "authenticate", beforeRequest: { req in
            try req.content.encode(AuthenticationRequest.mock)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)
            print(res.body.string)
        })
    }
}
