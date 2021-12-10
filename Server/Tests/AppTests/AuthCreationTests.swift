//
//  AuthCreationTests.swift
//
//
//  Created by Charles Pisciotta on 12/2/21.
//

@testable import App
import Foundation
import XCTest
import XCTVapor

final class AuthCreationTests: XCTestCase {
    private var app: Application!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = Application(.testing)
        try configure(app)
    }

    override func tearDownWithError() throws {
        app.shutdown()
        try super.tearDownWithError()
    }

    func testDecodeAuthCreation() throws {
        guard let fileURL = Bundle.module.url(
            forResource: "ece461DefaultAdmin",
            withExtension: "json",
            subdirectory: "MockData/Authentication"
        ) else {
            XCTFail("File not found")
            return
        }

        let data = try Data(contentsOf: fileURL)
        let auth = try JSONDecoder().decode(AuthenticationRequest.self, from: data)

        XCTAssertEqual(auth.user.name, "ece461defaultadmin")
        XCTAssertTrue(auth.user.isAdmin)
        XCTAssertEqual(auth.secret.password, "correcthorsebatterystaple123(!__+@**(A")
    }

    func testPUTAdminUserToken() throws {
        try app.test(.PUT, "authenticate", beforeRequest: { req in
            try req.content.encode(AuthenticationRequest.mockAdmin)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)
        })
    }

    func testPUTNonAdminUserToken() throws {
        try app.test(.PUT, "authenticate", beforeRequest: { req in
            try req.content.encode(AuthenticationRequest.mockNonAdmin)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)
        })
    }

    func testPUTNotAUser() throws {
        try app.test(.PUT, "authenticate", beforeRequest: { req in
            try req.content.encode(AuthenticationRequest.new())
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertEqual(res.headers.contentType, .plainText)
        })
    }
}
