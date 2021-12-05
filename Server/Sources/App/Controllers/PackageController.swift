//
//  PackageController.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor
import VaporFirestore

struct PackageController: RouteCollection {
    
    private var client: FirestoreResource
    
    init(app: Application) {
        self.client = app.firestoreService.firestore
    }
        
    func boot(routes: RoutesBuilder) throws {
        let package = routes.grouped("package")
        package.post(use: create) // Create or ingest a package
        package.get(":id", use: index) // Get a package by ID
        package.put(":id", use: update) // Update a package by ID
        package.delete(":id", use: delete) // Deleta a package by ID
        package.get(":id", "rate", use: rate) // Rate a package by ID
        
        package.group("byName") { route in
            route.get(":name", use: getPackageByName) // Package By Name Get
            route.delete(":name", use: deletePackageByName) // Delete all versions of this package.
        }
    }
    
    func create(req: Request) async throws -> Response {
        // TODO: Implement create
        // TODO: Implement ingest
        let package = try req.content.decode(ProjectPackage.self)
        let firestorePackage = package.asFirestoreProjectPackage()
        
        do {
            let _ = try await client.createDocument(path: "packages", name: package.metadata.id, fields: firestorePackage).get()
            
            var headers = HTTPHeaders()
            headers.add(name: .contentType, value: "application/json")
            
            let metadataResponseBody = try package.metadata.asResponseBody()
            return Response(status: .created, headers: headers, body: metadataResponseBody)
        } catch {
            if let firestoreError = error as? FirestoreErrorResponse, firestoreError.error.status == "ALREADY_EXISTS" {
                return Response(status: .forbidden)
            }
        }
        
        return Response(status: .badRequest)
    }
    
    func index(req: Request) async -> Response {
        if let packageID = req.parameters.get("id") {
            let path = "packages/\(packageID)"
            
            if let document: Firestore.Document<FirestoreProjectPackage> = try? await client.getDocument(path: path).get(),
               let package = document.fields?.asProjectPackage(),
               let responseBody = try? package.asResponseBody() {
                var headers = HTTPHeaders()
                headers.add(name: .contentType, value: "application/json")
                
                return Response(status: .ok, headers: headers, body: responseBody)
            }
        }
        
        return Response.noSuchPackageError
    }
    
    func update(request: Request) async -> Response {
        // TODO: Check that id, version, and name match
        // TODO: Should the PUT request return 500 if non-existent
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")
        
        do {
            let package = try request.content.decode(ProjectPackage.self)
            let firestorePackage = package.asFirestoreProjectPackage()
            let path = "packages/\(firestorePackage.id)"
            let _ = try await client.updateDocument(path: path, fields: firestorePackage, updateMask: nil).get()
            return Response(status: .ok, headers: headers)
        } catch {
            return Response(status: .internalServerError, headers: headers)
        }
    }
    
    func delete(request: Request) throws -> String {
        // TODO: Implement
        let package = try request.content.decode(ProjectPackage.self)
        return "Should delete package named \(package.metadata.name)!"
    }
    
    func rate(request: Request) throws -> PackageScore {
        // TODO: Implement
        return PackageScore.mock
    }
    
    func getPackageByName(request: Request) throws -> [PackageHistoryItem] {
        // TODO: Implement get package history by name
        
        guard let _ = request.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        
        // TODO: Remove mock
        return PackageHistoryItem.items
    }
    
    func deletePackageByName(request: Request) throws -> Response {
        // TODO: Implement
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")
        return Response(status: .ok, headers: headers)
    }
    
}
