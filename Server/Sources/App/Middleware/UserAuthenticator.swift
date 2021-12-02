//
//  UserAuthenticator.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor

struct UserAuthenticator: AsyncBearerAuthenticator {
    typealias User = App.User
    
    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) async throws {
        if bearer.token == "foo" {
            request.auth.login(User(name: "Vapor"))
        }
    }
}
