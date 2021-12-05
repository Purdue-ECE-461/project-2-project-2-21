//
//  PackagesController.swift
//  
//
//  Created by Charles Pisciotta on 12/5/21.
//

import Foundation
import Vapor
import VaporFirestore

struct PackagesController: RouteCollection {
    
    private var client: FirestoreResource
    
    init(app: Application) {
        self.client = app.firestoreService.firestore
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("packages") { route in
            route.post(use: index)
        }
    }
    
    func index(request: Request) async -> Response {
        // TODO: Add offset
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
    
        do {
            // TODO: Handle requested packages
            let requestedPackages = try request.content.decode([ProjectPackageRequest].self)
            
            let documents: [Firestore.Document<FirestoreProjectPackage>] = try await client.listDocuments(path: "packages").get()
            let packages = documents.compactMap { $0.fields?.asProjectPackage() }
            let documentsMetadata = packages.map(\.metadata)
            let metadataListData = try JSONEncoder().encode(documentsMetadata)
            return Response(status: .ok, headers: headers, body: .init(data: metadataListData))
        } catch {
            return Response(
                status: .internalServerError,
                headers: headers,
                body: InternalError.unexpectedError.asResponseBody()
            )
        }
    }

}
