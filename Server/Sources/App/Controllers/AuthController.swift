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
    private var client: FirestoreResource

    init(app: Application) {
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
            let localToken = try req.jwt.sign(localPayload)

            // Check if user exists
            guard let existingFirestoreAuth: Firestore.Document<FirestoreAuth> = try? await client.getDocument(
                path: path
            ).get() else {
                // User doesn't exist
                return Response(status: .unauthorized, headers: headers)
            }

            // Retreived token
            guard let retreivedToken = existingFirestoreAuth.fields?.token else {
                return Response(status: .internalServerError, headers: headers)
            }

            guard localToken == retreivedToken else {
                // User is not authorized
                return Response(status: .unauthorized, headers: headers)
            }

            var jsonHeaders = HTTPHeaders()
            jsonHeaders.add(name: .contentType, value: "application/json")

            return Response(status: .ok, headers: jsonHeaders, body: .init(string: "bearer \(localToken)"))
        } catch {
            print(error)
            return Response(status: .internalServerError)
        }
    }
}
