//
//  UserAuthenticator.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor
import VaporFirestore

struct UserAuthenticator: AsyncMiddleware {

    let client: FirestoreResource

    init(app: Application) {
        self.client = app.firestoreService.firestore
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {

        typealias FSAuth = Firestore.Document<FirestoreAuth>

        // Determine if the request is attempting to create a bearer token.
        // If so, a user should not be subject to auth.
        if isPutAuthenticate(request: request) {
            return try await next.respond(to: request)
        }

        do {
            guard let authPayload = try? request.jwt.verify(as: AuthJWTPayload.self) else {
                return Response(
                    status: .unauthorized,
                    body: .init(string: "The given bearer token is invalid.")
                )
            }

            let token = request.headers.bearerAuthorization?.token
            let firebaseToken: FSAuth = try await client.getDocument(path: "users/\(authPayload.username)").get()

            if let givenToken = token,
               let retrievedToken = firebaseToken.fields?.token,
               givenToken == retrievedToken {
                return try await next.respond(to: request)
            }

            // Error occurred
            // swiftlint:disable line_length
            Logger(label: "Unauthorized-Logger-Middleware")
                .critical("Middleware bearer tokens don't match. Got \(token ?? ""), but expected \(firebaseToken.fields?.token ?? "").")
            // swiftlint:enable line_length

            return Response(
                status: .unauthorized,
                body: .init(string: "The given bearer token is invalid.")
            )
        } catch {
            // Error occurred
            Logger(label: "Unauthorized-Logger-Middleware")
                .report(error: error)

            return Response(
                status: .unauthorized,
                body: .init(string: "The given bearer token is invalid.")
            )
        }
    }

    /// Checks if a request is attempting to create a bearer token. If so, a request does not need a bearer token.
    /// - Parameter request: The URL request.
    /// - Returns: A boolean indicating if the request is a `PUT` to the `authenticate` endpoint.
    private func isPutAuthenticate(request: Request) -> Bool {
        if request.method == .PUT, request.route?.path.string == "authenticate" {
            return true
        }

        return false
    }
}
