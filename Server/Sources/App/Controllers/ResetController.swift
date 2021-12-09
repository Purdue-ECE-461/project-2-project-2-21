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

    func reset(req: Request) async throws -> Response {
        // TODO: Check if authorized user (isAdmin)

        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")

        do {
            let documents: [Firestore.Document<FirestoreProjectPackage>] = try await client.listDocuments(path: "packages").get()

            for document in documents {
                let id = document.id
                let _ : [String: String] = try await client.deleteDocument(path: "packages/\(id)").get()
            }

            return Response(status: .ok, headers: headers, body: .init())
        } catch {
            return Response(status: .internalServerError, headers: headers)
        }
    }
}
