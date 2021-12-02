//
//  PackageController.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor

struct PackageController: RouteCollection {
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
    
    func create(req: Request) throws -> ProjectPackage.Metadata {
        // TODO: Implement create
        // TODO: Implement ingest
        let package = try req.content.decode(ProjectPackage.self)
        return package.metadata
    }
    
    func index(req: Request) throws -> ProjectPackage {
        guard let _ = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        
        // TODO: Remove mock response
        return ProjectPackage.mock
    }
    
    func update(request: Request) throws -> String {
        // TODO: Implement
        let package = try request.content.decode(ProjectPackage.self)
        return "Should update package named \(package.metadata.name)!"
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
