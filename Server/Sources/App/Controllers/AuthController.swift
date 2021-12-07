//
//  AuthController.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor
import VaporFirestore
import JWT

struct AuthController: RouteCollection {
    
    private var client: FirestoreResource
    
    init(app: Application) {
        self.client = app.firestoreService.firestore
    }
       
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("authenticate")
        auth.put(use: getBearerToken) // Create an auth token
        auth.post(use: create) // Create a user
    }
    
    func create(req: Request) async throws -> Response {
        let authRequest = try req.content.decode(AuthenticationRequest.self)
        
        let payload = AuthJWTPayload(
            subject: "461-Project-User",
            expiration: ExpirationClaim(value: .distantFuture),
            isAdmin: authRequest.user.isAdmin,
            username: authRequest.user.name,
            password: authRequest.secret.password
        )
        
        do {
            let bearerToken = try req.jwt.sign(payload)
            let firebasePayload = FirestoreAuth(token: bearerToken)
            let _ = try await client.createDocument(path: "users", name: authRequest.user.name, fields: firebasePayload).get()
            
            var headers = HTTPHeaders()
            headers.add(name: .contentType, value: "application/json")

            return Response(status: .created, headers: headers, body: .init(string: bearerToken))
        } catch {
            print(error)
            return Response(status: .internalServerError)
        }
    }
    
    func getBearerToken(req: Request) async throws -> Response {
        // TODO: Change auth implementation
        
        let authRequest = try req.content.decode(AuthenticationRequest.self)
        
        let localPayload = AuthJWTPayload(
            subject: "461-Project-User",
            expiration: ExpirationClaim(value: .distantFuture),
            isAdmin: authRequest.user.isAdmin,
            username: authRequest.user.name,
            password: authRequest.secret.password
        )
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        do {
            let localToken = try req.jwt.sign(localPayload)
            
            let path = "users/\(authRequest.user.name)"
            let firestoreAuth: Firestore.Document<FirestoreAuth> = try await client.getDocument(path: path).get()
            
            guard let firestoreToken = firestoreAuth.fields?.token else {
                throw Abort(.internalServerError)
            }
            
            guard localToken == firestoreToken else {
                throw Abort(.internalServerError)
            }
            
            return Response(status: .ok, headers: headers, body: .init(string: "bearer \(localToken)"))
        } catch {
            return Response(status: .internalServerError)
        }
    }
}
