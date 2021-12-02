//
//  AuthenticationRequest.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor

struct AuthenticationRequest: Content, Codable {
    let user: User
    let secret: Secret
    
    enum CodingKeys: String, CodingKey {
        case user = "User"
        case secret = "Secret"
    }
}

extension AuthenticationRequest {
    struct User: Codable {
        let name: String
        let isAdmin: Bool
    }
    
    struct Secret: Codable {
        let password: String
    }
}

#if DEBUG
extension AuthenticationRequest {
    static let mock = AuthenticationRequest(
        user: User(
            name: "ece461defaultadmin",
            isAdmin: true
        ),
        secret: Secret(
            password: "correcthorsebatterystaple123(!__+@**(A"
        )
    )
}
#endif
