//
//  PackageIDController.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor

struct PackageIDController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let package = routes.grouped("package")
        package.post(use: create)
        package.get(":id", use: index)
        package.put(":id", use: update)
        package.delete(":id", use: delete)
        package.get("id", "rate", use: rate)
    }
    
    func create(req: Request) throws -> ProjectPackage.Metadata {
        // TODO: Implement
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
    
}
