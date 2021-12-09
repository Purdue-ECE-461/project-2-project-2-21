//
//  ResetController.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor
import VaporFirestore

struct ResetController: RouteCollection {

    private var client: FirestoreResource

    init(app: Application) {
        self.client = app.firestoreService.firestore
    }

    func boot(routes: RoutesBuilder) throws {
        routes.group("reset") { route in
            route.delete(use: reset)
        }
    }

    func reset(req: Request) async -> Response {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")

        do {
            // Verify that a user is an admin
            // If not, user doesn't have permission to reset the registry.
            let payload = try req.jwt.verify(as: AuthJWTPayload.self)
            guard payload.isAdmin else { return Response(status: .unauthorized, headers: headers) }

            let documents: [Firestore.Document<FirestoreProjectPackage>] = try await client.listDocuments(
                path: "packages"
            ).get()

            for document in documents {
                let id = document.id
                _ = try await client.deleteDocument(path: "packages/\(id)").get() as [String: String]
            }

            return Response(status: .ok, headers: headers)
        } catch {
            return Response(status: .internalServerError, headers: headers)
        }
    }
}
