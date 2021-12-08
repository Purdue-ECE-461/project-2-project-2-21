//
//  AuthenticationRequest.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor
import VaporFirestore
import JWT

struct FirestoreAuth: Content, Codable {
    @Firestore.StringValue var token: String
}

// JWT payload structure.
struct AuthJWTPayload: JWTPayload {
    // Maps the longer Swift property names to the
    // shortened keys used in the JWT payload.
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case isAdmin = "admin"
        case username
        case password
    }
    
    // The "sub" (subject) claim identifies the principal that is the
    // subject of the JWT.
    var subject: SubjectClaim
    
    // The "exp" (expiration time) claim identifies the expiration time on
    // or after which the JWT MUST NOT be accepted for processing.
    var expiration: ExpirationClaim
    
    // Custom data.
    // If true, the user is an admin.
    var isAdmin: Bool
    
    let username: String
    let password: String
    
    // Run any additional verification logic beyond
    // signature verification here.
    // Since we have an ExpirationClaim, we will
    // call its verify method.
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}

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

// TODO: Remove this
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
    
    static func new() -> AuthenticationRequest {
        AuthenticationRequest(
            user: User(
                name: UUID().uuidString,
                isAdmin: true
            ),
            secret: Secret(
                password: "correcthorsebatterystaple123(!__+@**(A"
            )
        )
    }
}
