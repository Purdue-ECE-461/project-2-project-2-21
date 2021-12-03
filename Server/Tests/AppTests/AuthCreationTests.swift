//
//  AuthCreationTests.swift
//
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import XCTest
@testable import App

final class AuthCreationTests: XCTestCase {
    
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
    
}
