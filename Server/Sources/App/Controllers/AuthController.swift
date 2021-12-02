//
//  AuthController.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("authenticate")
        auth.put(use: create) // Create an auth token
    }
    
    func create(req: Request) throws -> Response {
        let authRequest = try req.content.decode(AuthenticationRequest.self)
        // TODO: Implement authentication
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        // TODO: Use dynamic bearer token
        let token = "bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        
        return Response(status: .ok, headers: headers, body: .init(string: token))
    }
}
