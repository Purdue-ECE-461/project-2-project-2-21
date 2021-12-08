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
    
    private func constructQuery(offset: Int, nextPageToken: String?) -> String? {
        #warning("Change to 10")
        let query = "pageSize=10" // Per documentation, page size is default 10
        
        // Check if first page
        // On first page, don't add next page token
        if offset == 1 {
            return query
        }
        
        // If not first page, check that next page token exists.
        // If next page token exists, append and return.
        // Otherwise, return nil to indicate error.
        guard let nextPageToken = nextPageToken else {
            return nil
        }
        
        return query.appending("&pageToken=\(nextPageToken)")
    }
    
    func index(request: Request) async -> Response {
        // TODO: Add offset
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        
        let offset = request.query["offset"] ?? 1
        var nextPageToken: String? = nil
            
        do {
            let requestedPackages = try request.content.decode([ProjectPackageRequest].self)
            
            for currentOffset in 1...offset {
                if currentOffset != 1, nextPageToken == nil { return Response.internalError }
                let query = constructQuery(offset: offset, nextPageToken: nextPageToken)
                
                typealias PaginatedList = Firestore.List.Response<FirestoreProjectPackage>
                
                // Iterate through to get next page token
                let packagesList: PaginatedList = try await client.listDocumentsPaginated(path: "packages", query: query).get()
                
                if currentOffset != offset {
                    // Get the next page token
                    guard let token = packagesList.nextPageToken else { return Response.internalError }
                    nextPageToken = token
                } else {
                    // Got last page
                    let packages = packagesList.documents.compactMap { $0.fields?.asProjectPackage() }
                    let documentsMetadata = packages.map(\.metadata)
                    let metadataListData = try JSONEncoder().encode(documentsMetadata)
                    return Response(status: .ok, headers: headers, body: .init(data: metadataListData))
                }
            }
        } catch {
            return Response.internalError
        }
        
        return Response.internalError
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
