//
//  AuthController.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import JWT
import Vapor
import VaporFirestore

struct AuthController: RouteCollection {
    
    private var app: Application
    private var client: FirestoreResource

    init(app: Application) {
        self.app = app
        self.client = app.firestoreService.firestore
    }

    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("authenticate")
        auth.put(use: getBearerToken) // Create/Get an auth token
    }

    func getBearerToken(req: Request) async throws -> Response {
        let authRequest = try req.content.decode(AuthenticationRequest.self)

        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")

        let path = "users/\(authRequest.user.name)"

        let localPayload = AuthJWTPayload(
            subject: "461-Project-User",
            expiration: ExpirationClaim(value: Date(timeIntervalSince1970: 1_640_908_800)),
            isAdmin: authRequest.user.isAdmin,
            username: authRequest.user.name,
            password: authRequest.secret.password
        )

        do {
            // Check if user exists
            let existingFirestoreAuth: Firestore.Document<FirestoreAuth> = try await client.getDocument(
                path: path
            ).get()

            // User exists
            do {
                // Retreived token
                guard let retreivedToken = existingFirestoreAuth.fields?.token else {
                    return Response(status: .internalServerError, headers: headers)
                }

                // Retreived credentials
                let firebaseAuthPayload = try app.jwt.signers.verify(retreivedToken, as: AuthJWTPayload.self)
                
                guard firebaseAuthPayload.username == localPayload.username,
                      firebaseAuthPayload.password == localPayload.password,
                      firebaseAuthPayload.isAdmin == localPayload.isAdmin,
                      firebaseAuthPayload.expiration == localPayload.expiration else {
                          let localToken = try? app.jwt.signers.sign(localPayload)
                          
                          // User is not authorized
                          Logger(label: "Unauthorized-Logger")
                              .critical("Bearer tokens don't match. Got \(localToken ?? "nil"), but expected \(retreivedToken).")

                          return Response(
                              status: .unauthorized,
                              headers: headers,
                              body: .init(string: "The given bearer token is invalid.")
                          )
                      }
                
                var jsonHeaders = HTTPHeaders()
                jsonHeaders.add(name: .contentType, value: "application/json")

                return Response(status: .ok, headers: jsonHeaders, body: .init(string: "bearer \(retreivedToken)"))
            } catch {
                print(error)
                return Response(status: .internalServerError)
            }
        } catch {
            Logger(label: "Unauthorized-Logger").report(error: error)

            return Response(
                status: .unauthorized,
                headers: headers,
                body: .init(string: "The provided user information is invalid.")
            )
        }
    }
}
