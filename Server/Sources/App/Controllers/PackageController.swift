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
    
    func delete(request: Request) async -> Response {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")
        
        if let packageID = request.parameters.get("id") {
            let path = "packages/\(packageID)"
            
            // Check package exists
            // Delete package
            // Check empty dictionary
            // TODO: Determine if empty dictionary returned on failure/succses
            if let _: Firestore.Document<FirestoreProjectPackage> = try? await client.getDocument(path: path).get(),
               let deleteResponse: [String: String] = try? await client.deleteDocument(path: path).get(),
               deleteResponse.isEmpty {
                // TODO: Determine if actual success
                return Response(status: .ok, headers: headers)
            }
        }
        
        return Response(status: .badRequest, headers: headers)
    }
    
    func rate(request: Request) async throws -> PackageScore {
        guard let name = request.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        
        let path = "scores/\(name)"
        
        guard let document: Firestore.Document<PackageScore> = try? await client.getDocument(path: path, query: nil).get(),
              let score = document.fields else {
                  throw Abort(.internalServerError)
              }
        
        return score
    }
    
    func getPackageByName(request: Request) async throws -> [PackageHistoryItem] {
        // TODO: Implement this
        return []
    }
    
    func deletePackageByName(request: Request) async -> Response {
        guard let name = request.parameters.get("name") else { return Response(status: .badRequest) }
        
        var docIDsToDelete: [String] = []
        var nextPageToken: String? = nil
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")
        
        do {
            // Get the documents to delete
            repeat {
                let query = constructQuery(nextPageToken: nextPageToken)

                let packagesList: Firestore.List.Response<FirestoreProjectPackage> = try await client.listDocumentsPaginated(path: "packages", query: query).get()
                
                nextPageToken = packagesList.nextPageToken
                
                // Add documents to delete
                let packages = packagesList.documents.compactMap { $0.fields?.asProjectPackage() }
                
                // Filter by specified name
                // Transform to list of IDs
                let ids = packages.filter { $0.metadata.name == name }.map(\.metadata.id)
                
                docIDsToDelete.append(contentsOf: ids)
            } while (nextPageToken != nil)
            
            // Delete the documents
            for documentID in docIDsToDelete {
                let _ : [String: String] = try await client.deleteDocument(path: "packages/\(documentID)").get()
            }
            
            return Response(status: .ok, headers: headers)
        } catch {
            print(error)
        }
        
        return Response(status: .internalServerError, headers: headers)
    }
    
}

extension PackageController {
    private func constructQuery(nextPageToken: String?) -> String {
        guard let nextPageToken = nextPageToken else { return "" }
        return "pageToken=\(nextPageToken)"
    }
}
