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
    
    func index(request: Request) async throws -> [ProjectPackage.Metadata] {
        guard let versionRequests = try? request.content.decode([ProjectPackageRequest].self) else { throw Abort(.badRequest) }
        
        let offset = request.query["offset"] ?? 1
        guard offset <= 0 else { throw Abort(.badRequest) } // Offset needs to be a positive value
        
        var nextPageToken: String? = nil
        var matchingMetadata: [ProjectPackage.Metadata] = []
        
        do {
            // Get the documents that match
            repeat {
                let query = constructQuery(nextPageToken: nextPageToken)

                // TODO: Add mask to only use metadata
                let packagesList: Firestore.List.Response<FirestoreProjectPackage> = try await client.listDocumentsPaginated(path: "packages", query: query).get()
                
                nextPageToken = packagesList.nextPageToken
                
                // Add documents to delete
                let packages = packagesList.documents.compactMap { $0.fields?.asProjectPackage() }
                
                // Transform to metadata only
                // Filter by specified name
                let currentMatchingValues = packages
                    .map(\.metadata)
                    .filter { isMatchingPackageVersion(requests: versionRequests, metadata: $0) }
                
                matchingMetadata.append(contentsOf: currentMatchingValues)
            } while (nextPageToken != nil)
            
            
            // Only take the given offset
            
            if matchingMetadata.isEmpty { return [] }
            
            let beginningIndex = (offset * 10) - 10 // Page Size is 10
            let numElements = matchingMetadata.count
            let lastPossibleIndex = numElements - 1
            
            if beginningIndex > lastPossibleIndex {
                // The window is too far right
                // 0 1 2 3
                //         [ ]
                // This page doesn't exist
                throw Abort(.notFound)
            } else {
                // The window contains up to a full set of values
                // 0 1 2 3 4 5 6 7 8
                //      [
                // Return the values
                return Array(matchingMetadata.dropFirst(beginningIndex).prefix(10)) // Page size is 10
            }
        } catch {
            print(error)
        }
        
        throw Abort(.internalServerError)
    }
}

extension PackagesController {
    private func isMatchingPackageVersion(
        requests: [ProjectPackageRequest],
        metadata: ProjectPackage.Metadata
    ) -> Bool {
        // TODO: Implement this
        return true
    }
    
    private func constructQuery(nextPageToken: String?) -> String {
        guard let nextPageToken = nextPageToken else { return "" }
        return "pageToken=\(nextPageToken)"
    }
}

extension Response {
    static let internalError: Response = {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        return Response(
            status: .internalServerError,
            headers: headers,
            body: InternalError.unexpectedError.asResponseBody()
        )
    }()
}
